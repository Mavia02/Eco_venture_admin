class Validators {
  // Email Validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  // Password Validator
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Must contain at least 1 uppercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Must contain at least 1 number";
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Must contain at least 1 special character";
    }
    return null;
  }

  // Confirm Password Validator
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return "Confirm your password";
    }
    if (value != password) {
      return "Passwords do not match";
    }
    return null;
  }

  // First Name Validator
  static String? firstName(String? value) {
    if (value == null || value.isEmpty) {
      return "First name is required";
    }
    if (!RegExp(r"^[a-zA-Z]+$").hasMatch(value)) {
      return "Only letters allowed";
    }
    return null;
  }

  // Last Name Validator
  static String? lastName(String? value) {
    if (value == null || value.isEmpty) {
      return "Last name is required";
    }
    if (!RegExp(r"^[a-zA-Z]+$").hasMatch(value)) {
      return "Only letters allowed";
    }
    return null;
  }

  // Phone Number Validator
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return "Phone number is required";
    }
    if (!RegExp(r"^[0-9]{10,15}$").hasMatch(value)) {
      return "Enter valid phone number (10–15 digits)";
    }
    return null;
  }
}
