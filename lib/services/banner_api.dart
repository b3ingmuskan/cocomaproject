import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlogApi {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://cocomastudios.com/cocoma_api/api",
      headers: {"Accept": "application/json"},
    ),
  );

  /// 🔥 TOKEN
  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    return {
      "Authorization": "Bearer $token",
    };
  }

  /// ================= GET =================
  static Future<List> getCategories() async {
    try {
      final response = await dio.get(
        "/blog-categories",
        options: Options(headers: await getHeaders()),
      );

      print("BLOG RESPONSE: ${response.data}");

      return response.data["data"] is List
          ? response.data["data"]
          : response.data["data"]?["data"] ?? [];

    } catch (e) {
      print("❌ GET ERROR: $e");
      return [];
    }
  }

  /// ================= CREATE =================
  static Future<bool> createCategory({
    required String title,
    required String slug,
    required String status,
    required String displayOrder,
    File? iconFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "title": title,
        "slug": slug,
        "status": status,
        "display_order": displayOrder,
        if (iconFile != null)
          "icon": await MultipartFile.fromFile(iconFile.path),
      });

      final response = await dio.post(
        "/blog-categories",
        data: formData,
        options: Options(headers: await getHeaders()),
      );

      return response.statusCode == 201;

    } catch (e) {
      print("❌ CREATE ERROR: $e");
      return false;
    }
  }

  /// ================= UPDATE =================
  static Future<bool> updateCategory({
    required int id,
    required String title,
    required String slug,
    required String status,
    required String displayOrder,
    File? iconFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "title": title,
        "slug": slug,
        "status": status,
        "display_order": displayOrder,
        if (iconFile != null)
          "icon": await MultipartFile.fromFile(iconFile.path),
      });

      final response = await dio.post(
        "/blog-categories/$id",
        data: formData,
        options: Options(headers: await getHeaders()),
      );

      return response.statusCode == 200;

    } catch (e) {
      print("❌ UPDATE ERROR: $e");
      return false;
    }
  }

  /// ================= DELETE =================
  static Future<bool> deleteCategory(int id) async {
    try {
      final response = await dio.delete(
        "/blog-categories/$id",
        options: Options(headers: await getHeaders()),
      );

      return response.statusCode == 200;

    } catch (e) {
      print("❌ DELETE ERROR: $e");
      return false;
    }
  }

  /// ================= STATUS =================
  static Future<bool> updateStatus(int id, String status) async {
    try {
      final response = await dio.post(
        "/blog-categories/$id",
        data: {"status": status},
        options: Options(headers: await getHeaders()),
      );

      return response.statusCode == 200;

    } catch (e) {
      print("❌ STATUS ERROR: $e");
      return false;
    }
  }
}