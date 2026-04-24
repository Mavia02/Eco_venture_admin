import 'dart:convert';
import 'dart:io';
import 'package:eco_venture_admin_portal/services/shared_preferences_helper.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';


class CloudinaryService {
  final String cloudName = "dosvc174j";

  // --- SEPARATE PRESETS FOR ADMIN MODULES ---
  // You must create these Unsigned presets in your Cloudinary Dashboard
  final String stemPreset = "eco_admin_stem";
  final String quizPreset = "eco_admin_quiz";
  final String multimediaPreset = "eco_admin_multimedia";
  final String qrHuntPreset = "eco_admin_qr";
  final String profilePreset = "eco_admin_profile";

  // --- 1. CORE UPLOAD LOGIC (Private) ---
  Future<String?> _upload(File file, String preset, {bool isVideo = false, String? folderContext}) async {
    try {
      // 1. Get Admin ID for folder organization
      final adminUid = await SharedPreferencesHelper.instance.getAdminId() ?? 'unknown_admin';

      // 2. Determine Type
      final mimeType = lookupMimeType(file.path) ?? (isVideo ? 'video/mp4' : 'image/jpeg');
      final fileType = mimeType.split('/');
      final resourceType = isVideo ? 'video' : 'image';

      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload");

      // 3. Construct Request
      final request = http.MultipartRequest("POST", uri)
        ..fields['upload_preset'] = preset
      // Optional: Organize into folders by Admin ID
        ..fields['folder'] = folderContext != null
            ? "Admin/$adminUid/$folderContext"
            : "Admin/$adminUid/uploads"
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            contentType: MediaType(fileType[0], fileType[1]),
          ),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        return jsonResponse['secure_url'];
      } else {
        print("Cloudinary upload failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("⚠ Cloudinary Error: $e");
      return null;
    }
  }

  // ==================================================
  //  MODULE SPECIFIC UPLOAD FUNCTIONS
  // ==================================================

  // 1. STEM CHALLENGES (Images)
  Future<String?> uploadStemImage(File file) async {
    return await _upload(file, stemPreset, folderContext: "stem_challenges");
  }

  // 2. QUIZZES (Images)
  Future<String?> uploadQuizImage(File file) async {
    return await _upload(file, quizPreset, folderContext: "quizzes");
  }

  // 3. MULTIMEDIA (Videos & Thumbnails)
  Future<String?> uploadMultimediaFile(File file, {bool isVideo = false}) async {
    return await _upload(file, multimediaPreset, isVideo: isVideo, folderContext: "multimedia");
  }

  // 4. QR TREASURE HUNT (Cover Images/Maps - Not the QR code itself)
  Future<String?> uploadQrHuntImage(File file) async {
    return await _upload(file, qrHuntPreset, folderContext: "qr_hunts");
  }

  // 5. ADMIN PROFILE
  Future<String?> uploadProfileImage(File file) async {
    return await _upload(file, profilePreset, folderContext: "profile");
  }

  // --- DELETE LOGIC ---
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Note: Deleting usually requires signed uploads (API Key/Secret)
      // This is a placeholder if you implement backend deletion.
      print("Request to delete: $imageUrl");
    } catch (e) {
      print("Error deleting image: $e");
    }
  }
}