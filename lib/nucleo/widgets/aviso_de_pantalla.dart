import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';

/// Un aviso que ocupa el lugar de toda una pantalla cuando no se puede
/// seguir: "No hay internet", "Todavía no se abre la caja". Lleva un icono
/// ámbar, un título, una explicación y un botón para salir del atorón.
class AvisoDePantalla extends StatelessWidget {
  const AvisoDePantalla({
    super.key,
    required this.icono,
    required this.titulo,
    required this.explicacion,
    required this.textoDelBoton,
    required this.alTocarBoton,
  });

  final IconData icono;
  final String titulo;
  final String explicacion;
  final String textoDelBoton;
  final VoidCallback alTocarBoton;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colores.alerta.fondo,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(icono, color: Colores.alerta.tinta, size: 36),
                ),
              ),
              const SizedBox(height: 0),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: Tipografia.titulo(30),
              ),
              TextoDeAyuda(explicacion, tamano: 17, centrado: true),
              const SizedBox(height: 2),
              BotonDeContorno(texto: textoDelBoton, alTocar: alTocarBoton),
            ],
          ),
        ),
      ),
    );
  }
}
