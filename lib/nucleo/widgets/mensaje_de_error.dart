import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/aviso_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';

/// Lo que se ve cuando los datos no se pudieron cargar, con un botón para
/// intentarlo otra vez.
///
/// Si la causa es que no hay internet, muestra el aviso grande de "No hay
/// internet"; si no, un mensaje con la explicación del servidor.
class MensajeDeError extends StatelessWidget {
  const MensajeDeError({super.key, required this.alReintentar, this.error});

  /// Lo que falló. Si es `null` se muestra un texto general.
  final Object? error;

  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    final error = this.error;

    if (error is ErrorDeConexion) {
      return AvisoDePantalla(
        icono: Icons.wifi_off_rounded,
        titulo: 'No hay internet',
        explicacion:
            'Sin internet no se pueden registrar ventas ni gastos. Revisa '
            'tu wifi o tus datos; lo que ya registraste está guardado.',
        textoDelBoton: 'Intentar otra vez',
        alTocarBoton: alReintentar,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(
              // Si el servidor explicó qué pasó, se muestra su explicación.
              error is ErrorDelServidor
                  ? error.mensaje
                  : 'No se pudo cargar la información',
              textAlign: TextAlign.center,
              style: Tipografia.texto(17, color: Colores.tintaSuave),
            ),
            BotonDeContorno(
              texto: 'Intentar otra vez',
              icono: Icons.refresh_rounded,
              alTocar: alReintentar,
            ),
          ],
        ),
      ),
    );
  }
}
