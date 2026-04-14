import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../model/banner_model.dart';
import '../services/dio_client.dart';

class BannerController extends ChangeNotifier {

  /// ✅ USE ONLY THIS DIO (INTERCEPTOR ENABLED)
  final dio = DioClient.dio;

  List<BannerModel> banners = [];

  bool isLoading = false;
  bool isDeleting = false;
  bool isCreating = false;
  bool isUpdating = false;

  /// 🔥 FILTERS
  String search = "";
  String pageType = "";
  String status = "all";

  /// ================= FETCH =================
  Future<void> fetchBanners() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await dio.get(
        "/admin/banners",
        queryParameters: {
          "limit": 1000,
          "offset": 0,
          "search": search,
          "page_type": pageType,
          "status": status,
        },
      );

      List data = response.data["data"] ?? [];

      banners = data.map((e) => BannerModel.fromJson(e)).toList();

    } catch (e) {
      print("❌ FETCH ERROR: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ================= CREATE =================
  Future<bool> createBanner({
    required String title,
    required String description,
    required String pageType,
    required String status,
    required String displayOrder,
    required String videoUrl,
    File? imageFile,
    File? videoFile,
  }) async {
    try {
      isCreating = true;
      notifyListeners();

      FormData formData = FormData.fromMap({
        "title": title,
        "description": description,
        "page_type": pageType,
        "status": status,
        "display_order": displayOrder,
        "video_url": videoUrl,
        if (imageFile != null)
          "image": await MultipartFile.fromFile(imageFile.path),
        if (videoFile != null)
          "video": await MultipartFile.fromFile(videoFile.path),
      });

      final response = await dio.post(
        "/admin/banners",
        data: formData,
      );

      if (response.statusCode == 201) {
        await fetchBanners();
        return true;
      }

      return false;

    } catch (e) {
      print("❌ CREATE ERROR: $e");
      return false;
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  /// ================= DELETE =================
  Future<void> deleteBanner(int id) async {
    try {
      isDeleting = true;
      notifyListeners();

      await dio.delete("/admin/banners/$id");

      await fetchBanners();

    } catch (e) {
      print("❌ DELETE ERROR: $e");
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  /// ================= UPDATE =================
  Future<bool> updateBanner({
    required int id,
    required String title,
    required String description,
    required String pageType,
    required String status,
    required String displayOrder,
    required String videoUrl,
    File? imageFile,
    File? videoFile,
    bool isImageRemoved = false,
    bool isVideoRemoved = false,
  }) async {
    try {
      isUpdating = true;
      notifyListeners();

      FormData formData = FormData.fromMap({
        "title": title,
        "description": description,
        "page_type": pageType,
        "status": status,
        "display_order": displayOrder,
        "video_url": videoUrl,

        /// 🔥 REMOVE SUPPORT
        if (isImageRemoved) "image": "",
        if (isVideoRemoved) "video": "",

        if (imageFile != null)
          "image": await MultipartFile.fromFile(imageFile.path),

        if (videoFile != null)
          "video": await MultipartFile.fromFile(videoFile.path),
      });

      final response = await dio.post(
        "/admin/banners/$id",
        data: formData,
      );

      if (response.statusCode == 200) {
        await fetchBanners();
        return true;
      }

      return false;

    } catch (e) {
      print("❌ UPDATE ERROR: $e");
      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  /// ================= STATUS =================
  Future<bool> toggleStatus(BannerModel banner) async {
    try {
      String newStatus =
      banner.status == "active" ? "inactive" : "active";

      bool success = await updateBanner(
        id: banner.id,
        title: banner.title,
        description: banner.description,
        pageType: banner.pageType,
        status: newStatus,
        displayOrder: banner.displayOrder.toString(),
        videoUrl: banner.videoUrl,
      );

      if (success) {
        banner.status = newStatus;
        notifyListeners();
        return true;
      }

      return false;

    } catch (e) {
      print("❌ STATUS ERROR: $e");
      return false;
    }
  }

  /// ================= FILTER =================
  void applySearch(String value) {
    search = value;
    fetchBanners();
  }

  void applyPageType(String value) {
    pageType = value == "All" ? "" : value;
    fetchBanners();
  }

  void applyStatus(String value) {
    status = value == "All" ? "all" : value;
    fetchBanners();
  }

  /// ================= REFRESH =================
  Future<void> refresh() async {
    await fetchBanners();
  }
}