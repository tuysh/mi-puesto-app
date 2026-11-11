import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';
import 'package:mi_puesto/datos/modelos/presentacion.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/servidor_simulado.dart';
import 'package:mi_puesto/nucleo/fechas.dart';

/// Las ventas, en memoria. Sigue las mismas reglas que el servidor: sin
/// caja no se vende, quien vende solo ve lo suyo y solo la dueña corrige.
class RepositorioDeVentasSimulado implements RepositorioDeVentas {
  RepositorioDeVentasSimulado(this._servidor);

  final ServidorSimulado _servidor;

  /// El historial de cada venta, por su `id`.
  final Map<String, List<EventoDeVenta>> _eventos = {};

  @override
  Future<Venta> registrarVenta({
    required List<LineaPorCobrar> lineas,
    required MetodoDePago metodoDePago,
    Dinero? montoRecibido,
    String nota = '',
  }) async {
    final perfil = await _servidor.atenderAAlguien();
    final caja = _servidor.exigirCajaAbierta();

    final renglones = [for (final linea in lineas) _renglonDe(linea)];
    final total = sumarDinero(renglones.map((renglon) => renglon.subtotal));
    final esEfectivo = metodoDePago == MetodoDePago.efectivo;
    // Sin monto recibido se entiende que pagó exacto.
    final recibido = montoRecibido ?? total;
    if (esEfectivo && recibido < total) {
      throw const ErrorDelServidor(
        'Pagó con menos del total.',
        codigoHttp: 400,
      );
    }

    final venta = Venta(
      id: _servidor.idNuevo(),
      creadaEn: DateTime.now(),
      perfilId: perfil.id,
      metodoDePago: metodoDePago,
      total: total,
      lineas: renglones,
      // Con tarjeta no hay billetes ni cambio.
      montoRecibido: esEfectivo ? recibido : null,
      cambio: esEfectivo ? recibido - total : null,
      nota: nota,
    );
    _servidor.ventas.add(venta);
    _servidor.cajaDeCadaVenta[venta.id] = caja.id;
    return venta;
  }

  @override
  Future<VentasDelDia> obtenerVentasDelDia(DateTime fecha) async {
    final perfil = await _servidor.atenderAAlguien();

    final visibles = [
      // `reversed`: de la más nueva a la más vieja.
      for (final venta in _servidor.ventas.reversed)
        if (esElMismoDia(venta.creadaEn, fecha) && _puedeVer(perfil, venta))
          venta,
    ];
    final queCuentan = visibles.where((venta) => !venta.estaCancelada);

    return VentasDelDia(
      fecha: soloElDia(fecha),
      total: sumarDinero(queCuentan.map((venta) => venta.total)),
      cuantas: queCuentan.length,
      canceladas: visibles.length - queCuentan.length,
      ventas: visibles,
    );
  }

  @override
  Future<Venta> obtenerVenta(String ventaId) async {
    final perfil = await _servidor.atenderAAlguien();

    final venta = _buscar(ventaId);
    if (!_puedeVer(perfil, venta)) {
      throw const ErrorDelServidor('No existe esa venta.', codigoHttp: 404);
    }
    return _conDetalle(venta, perfil);
  }

  @override
  Future<Venta> editarVenta(
    String ventaId, {
    List<LineaPorCobrar>? lineas,
    MetodoDePago? metodoDePago,
    String? nota,
  }) async {
    final perfil = await _servidor.atenderALaDuena();
    final actual = _buscar(ventaId);
    _revisarQueSePuedaCambiar(actual);

    final renglones = lineas == null
        ? actual.lineas
        : [for (final linea in lineas) _renglonDe(linea, ventaActual: actual)];
    final total = sumarDinero(renglones.map((renglon) => renglon.subtotal));
    final metodo = metodoDePago ?? actual.metodoDePago;
    final esEfectivo = metodo == MetodoDePago.efectivo;
    // Se conserva lo que pagó si todavía alcanza; si no, queda exacto.
    final pagoAnterior = actual.montoRecibido;
    final recibido = (pagoAnterior != null && pagoAnterior >= total)
        ? pagoAnterior
        : total;

    final editada = Venta(
      id: actual.id,
      creadaEn: actual.creadaEn,
      perfilId: actual.perfilId,
      metodoDePago: metodo,
      total: total,
      lineas: renglones,
      montoRecibido: esEfectivo ? recibido : null,
      cambio: esEfectivo ? recibido - total : null,
      nota: nota ?? actual.nota,
      editadaEn: DateTime.now(),
    );
    _reemplazar(editada);
    _anotarEvento(editada, TipoDeEvento.edicion, perfil);
    return _conDetalle(editada, perfil);
  }

  @override
  Future<Venta> cancelarVenta(String ventaId) async {
    final perfil = await _servidor.atenderALaDuena();
    final actual = _buscar(ventaId);
    _revisarQueSePuedaCambiar(actual);

    final cancelada = Venta(
      id: actual.id,
      creadaEn: actual.creadaEn,
      perfilId: actual.perfilId,
      metodoDePago: actual.metodoDePago,
      total: actual.total,
      lineas: actual.lineas,
      montoRecibido: actual.montoRecibido,
      cambio: actual.cambio,
      nota: actual.nota,
      editadaEn: actual.editadaEn,
      canceladaEn: DateTime.now(),
    );
    _reemplazar(cancelada);
    _anotarEvento(cancelada, TipoDeEvento.cancelacion, perfil);
    return _conDetalle(cancelada, perfil);
  }

  /// Convierte lo que manda la aplicación (qué producto y cuántos) en un
  /// renglón con nombre y precio, como hace el servidor.
  ///
  /// Al editar, los renglones que ya estaban en [ventaActual] conservan el
  /// precio con el que se cobraron.
  LineaDeVenta _renglonDe(LineaPorCobrar linea, {Venta? ventaActual}) {
    for (final anterior in ventaActual?.lineas ?? <LineaDeVenta>[]) {
      final esElMismo =
          anterior.productoId == linea.productoId &&
          anterior.presentacionId == linea.presentacionId;
      if (esElMismo) return anterior.conCantidad(linea.cantidad);
    }

    final producto = _servidor.productos.firstWhere(
      (producto) => producto.id == linea.productoId,
      orElse: () => throw const ErrorDelServidor(
        'Hay un producto que ya no existe.',
        codigoHttp: 400,
      ),
    );
    if (!producto.disponible) {
      throw ErrorDelServidor('Hoy no hay ${producto.nombre}.', codigoHttp: 400);
    }

    Presentacion? presentacion;
    if (producto.tieneTamanos) {
      presentacion = producto.presentaciones.firstWhere(
        (presentacion) => presentacion.id == linea.presentacionId,
        orElse: () => throw ErrorDelServidor(
          'Elige el tamaño de ${producto.nombre}.',
          codigoHttp: 400,
        ),
      );
    }

    final precio = presentacion?.precio ?? producto.precio ?? Dinero.cero;
    return LineaDeVenta(
      productoId: producto.id,
      presentacionId: presentacion?.id,
      nombreDelProducto: producto.nombre,
      nombreDelTamano: presentacion?.nombre ?? '',
      cantidad: linea.cantidad,
      precioUnitario: precio,
      subtotal: precio * linea.cantidad,
    );
  }

  /// La dueña ve todas las ventas; quien vende, solo las suyas.
  bool _puedeVer(Perfil perfil, Venta venta) {
    return perfil.esDueno || venta.perfilId == perfil.id;
  }

  bool _suCajaSigueAbierta(Venta venta) {
    final cajaAbierta = _servidor.cajaAbierta;
    return cajaAbierta != null &&
        _servidor.cajaDeCadaVenta[venta.id] == cajaAbierta.id;
  }

  void _revisarQueSePuedaCambiar(Venta venta) {
    if (venta.estaCancelada) {
      throw const ErrorDelServidor(
        'Esa venta ya está cancelada.',
        codigoHttp: 409,
        codigo: 'venta_cancelada',
      );
    }
    if (!_suCajaSigueAbierta(venta)) {
      throw const ErrorDelServidor(
        'La caja de ese día ya se cerró.',
        codigoHttp: 409,
        codigo: 'caja_cerrada',
      );
    }
  }

  /// La venta como la entrega el servidor al pedir UNA: con su historial y
  /// con el permiso para cambiarla.
  Venta _conDetalle(Venta venta, Perfil perfil) {
    return Venta(
      id: venta.id,
      creadaEn: venta.creadaEn,
      perfilId: venta.perfilId,
      metodoDePago: venta.metodoDePago,
      total: venta.total,
      lineas: venta.lineas,
      montoRecibido: venta.montoRecibido,
      cambio: venta.cambio,
      nota: venta.nota,
      editadaEn: venta.editadaEn,
      canceladaEn: venta.canceladaEn,
      eventos: List.unmodifiable(_eventos[venta.id] ?? []),
      sePuedeCambiar:
          perfil.esDueno && !venta.estaCancelada && _suCajaSigueAbierta(venta),
    );
  }

  void _anotarEvento(Venta venta, TipoDeEvento tipo, Perfil perfil) {
    final eventos = _eventos.putIfAbsent(venta.id, () => []);
    eventos.add(
      EventoDeVenta(tipo: tipo, perfilId: perfil.id, ocurrioEn: DateTime.now()),
    );
  }

  Venta _buscar(String ventaId) {
    return _servidor.ventas.firstWhere(
      (venta) => venta.id == ventaId,
      orElse: () =>
          throw const ErrorDelServidor('No existe esa venta.', codigoHttp: 404),
    );
  }

  void _reemplazar(Venta venta) {
    final posicion = _servidor.ventas.indexWhere((v) => v.id == venta.id);
    _servidor.ventas[posicion] = venta;
  }
}
