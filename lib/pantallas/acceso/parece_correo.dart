/// Revisión rápida de que [texto] tiene forma de correo: algo, una arroba
/// y un dominio con punto. La revisión de verdad la hace el servidor.
bool pareceCorreo(String texto) {
  final partes = texto.trim().split('@');
  if (partes.length != 2) return false;

  final usuario = partes[0];
  final dominio = partes[1];
  return usuario.isNotEmpty &&
      dominio.contains('.') &&
      !dominio.startsWith('.') &&
      !dominio.endsWith('.') &&
      !texto.trim().contains(' ');
}
