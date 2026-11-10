import 'package:image_picker/image_picker.dart';
import 'package:mi_puesto/datos/modelos/foto_nueva.dart';

/// Le pide una foto a la persona: con la cámara ([conCamara] en `true`) o
/// de su galería. Devuelve `null` si se arrepintió y no eligió ninguna.
///
/// Es un tipo de función para que las pruebas puedan poner otra en su
/// lugar (ahí no hay cámara ni galería); ver `Dependencias.pedirFoto`.
typedef PedirFoto = Future<FotoNueva?> Function({required bool conCamara});

/// La manera de verdad de pedir una foto: abre la cámara o la galería del
/// dispositivo.
Future<FotoNueva?> pedirFotoDelDispositivo({required bool conCamara}) async {
  final archivo = await ImagePicker().pickImage(
    source: conCamara ? ImageSource.camera : ImageSource.gallery,
    // El servidor la guarda de 512 puntos por lado: no hace falta mandarla
    // enorme. Reducirla aquí ahorra datos y, en iPhone, la convierte a JPG.
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 85,
  );
  if (archivo == null) return null;

  return FotoNueva(
    bytes: await archivo.readAsBytes(),
    nombreDeArchivo: archivo.name.isEmpty ? 'foto.jpg' : archivo.name,
  );
}
