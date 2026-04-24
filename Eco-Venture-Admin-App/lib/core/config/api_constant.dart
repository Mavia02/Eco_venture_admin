class ApiConstants {
  // Use your deployed Render backend (Removed trailing slash)
  static const String baseUrl = "https://eco-venture-backend.onrender.com";

  // Endpoints (Add leading slash here)
  static const String notifyByRoleEndPoints = '$baseUrl/notify-by-role';
  static const String notifyTeacherEndpoints = '$baseUrl/admin/verify-teacher';
}