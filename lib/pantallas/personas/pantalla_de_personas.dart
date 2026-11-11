import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/avatar_de_inicial.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/fila_de_lista.dart';
import 'package:mi_puesto/nucleo/widgets/lista_en_tarjeta.dart';
import 'package:mi_puesto/nucleo/widgets/marco_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/personas/pantalla_de_persona.dart';

/// Pantalla 5.6: todas las personas del negocio, también las desactivadas
/// (que se ven apagadas). Al tocar una se edita; abajo se agrega otra.
class PantallaDePersonas extends StatefulWidget {
  const PantallaDePersonas({super.key});

  @override
  State<PantallaDePersonas> createState() => _EstadoDePantallaDePersonas();
}

class _EstadoDePantallaDePersonas extends State<PantallaDePersonas> {
  /// Cambia cada vez que se vuelve de agregar o editar a alguien, para que
  /// la lista se pida otra vez.
  int _version = 0;

  Future<void> _abrir(Perfil? perfil) async {
    final sesion = Dependencias.de(context).sesion;

    await abrirPantalla(context, PantallaDePersona(perfil: perfil));
    // "¿Quién vende hoy?" y los nombres de las ventas salen de la sesión.
    await sesion.recargar();
    if (mounted) setState(() => _version++);
  }

  @override
  Widget build(BuildContext context) {
    final dependencias = Dependencias.de(context);

    return MarcoDePantalla(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          const EncabezadoConVolver(titulo: 'Personas'),
          const TextoDeAyuda(
            'Quien vende contigo entra con su propio PIN. Solo puede vender '
            'y ver las ventas que registró.',
            tamano: 15,
          ),
          Expanded(
            child: CargadorDeFuturo<List<Perfil>>(
              key: ValueKey(_version),
              cargar: dependencias.conexiones.perfiles.obtenerPerfiles,
              construir: (context, perfiles) => SingleChildScrollView(
                child: ListaEnTarjeta(
                  children: [
                    for (final perfil in perfiles)
                      Opacity(
                        // Una persona desactivada se ve apagada.
                        opacity: perfil.activo ? 1 : 0.55,
                        child: FilaDeLista(
                          altoMinimo: 68,
                          tamanoDeTitulo: 17,
                          alInicio: AvatarDeInicial(
                            inicial: perfil.inicial,
                            colores: perfil.colores,
                            tamano: 44,
                          ),
                          titulo: perfil.nombre,
                          detalle: _papelDe(perfil),
                          alTocar: () => _abrir(perfil),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          BotonPrincipal(
            texto: 'Agregar persona',
            icono: Icons.add_rounded,
            alTocar: () => _abrir(null),
          ),
        ],
      ),
    );
  }

  /// "Dueña · tú", "Vende" o "Desactivada".
  String _papelDe(Perfil perfil) {
    if (!perfil.activo) return 'Desactivada';
    if (!perfil.esDueno) return 'Vende';

    final soyYo = perfil.id == Dependencias.de(context).sesion.perfil?.id;
    return soyYo ? 'Dueña · tú' : 'Dueña';
  }
}
