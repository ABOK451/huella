bool isValidEmail(String email) {
  final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
  return emailRegex.hasMatch(email);
}

// Validación simple de contraseña (>=8 y al menos un número)
bool isValidPasswordSimple(String password) {
  final passRegex = RegExp(r'^(?=.*\d).{8,}$');
  return passRegex.hasMatch(password);
}
