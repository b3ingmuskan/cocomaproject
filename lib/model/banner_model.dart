class BannerModel {
  final int id;
  final String title;
  final String description;
  final String image;
  final String video;
  final String videoUrl;
  final int displayOrder;
  String status;
  final String pageType;
  final String? createdAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.video,
    required this.videoUrl,
    required this.displayOrder,
    required this.status,
    required this.pageType,
    this.createdAt,
  });

  /// 🔥 COMMON URL FIX FUNCTION
  static String fixUrl(String url) {
    if (url.isEmpty) return "";

    /// ❌ case: double URL
    if (url.contains("https://cocomastudios.com/https")) {
      return url.replaceFirst("https://cocomastudios.com/", "");
    }

    /// ✅ already full URL
    if (url.startsWith("http")) return url;

    /// ✅ relative path
    return "https://cocomastudios.com/$url";
  }

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? "",
      description: json['description']?.toString() ?? "",
      image: fixUrl(json['image']?.toString() ?? ""),
      video: fixUrl(json['video']?.toString() ?? ""),
      videoUrl: json['video_url']?.toString() ?? "",
      displayOrder:
      int.tryParse(json['display_order'].toString()) ?? 0,
      status: json['status']?.toString() ?? "",
      pageType: json['page_type']?.toString() ?? "",
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "image": image,
      "video": video,
      "video_url": videoUrl,
      "display_order": displayOrder,
      "status": status,
      "page_type": pageType,
      "created_at": createdAt,
    };
  }
}