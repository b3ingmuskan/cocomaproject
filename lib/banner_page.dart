import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart';

import 'add_banner_page.dart';
import 'video_player_page.dart';
import 'controller/banner_controller.dart';
import 'model/banner_model.dart';

class BannerPage extends StatefulWidget {
  const BannerPage({super.key});

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {

  String? categoryFilter = "All";
  String? statusFilter = "All";

  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<BannerController>(context, listen: false)
            .fetchBanners());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  String mapCategory(String value) {
    switch (value) {
      case "Home":
        return "home";
      case "Blog":
        return "blog";
      case "Careers":
        return "careers";
      case "Solutions":
        return "solutions";
      case "About Us":
        return "about";
      case "Services":
        return "service";
      case "Our Work":
        return "work";
      default:
        return "";
    }
  }


  void _showStatusDialog(BuildContext context, BannerModel banner) {
    String newStatus =
    banner.status == "active" ? "inactive" : "active";

    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// 🔵 ICON
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// TITLE
                    const Text(
                      "Confirm Status Change",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// MESSAGE WITH BADGES
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87),
                        children: [

                          const TextSpan(
                              text: "Do you want to update About Us banner status from ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)
                          ),

                          /// OLD STATUS
                          WidgetSpan(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: banner.status == "active"
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                banner.status.toUpperCase(),
                                style: TextStyle(
                                  color: banner.status == "active"
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const TextSpan(text: " to "),

                          /// NEW STATUS
                          WidgetSpan(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: newStatus == "active"
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                newStatus.toUpperCase(),
                                style: TextStyle(
                                  color: newStatus == "active"
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const TextSpan(text: " ?"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// BUTTONS
                    Row(
                      children: [

                        /// CANCEL
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Cancel"),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// CONFIRM
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {

                              setState(() {
                                isLoading = true;
                              });

                              bool success =
                              await Provider.of<BannerController>(
                                  context,
                                  listen: false)
                                  .toggleStatus(banner);

                              Navigator.pop(dialogContext);

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(success
                                      ? "Status updated successfully ✅"
                                      : "Failed to update ❌"),
                                  backgroundColor: success
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text("Confirm Update"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<BannerController>(context);

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FB),

      appBar: AppBar(title: const Text("Banner")),

      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<BannerController>(context, listen: false)
              .fetchBanners();
        },
        child:  SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // 🔥 IMPORTANT

          child: Padding(
            padding: const EdgeInsets.all(12),

            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADER
                  const Text("Banner",
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 5),

                  const Text("Manage your Banner offerings",
                      style: TextStyle(color: Colors.grey)),

                  const SizedBox(height: 15),


                  Row(
                    children: [

                      /// ➕ ADD BANNER BUTTON
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddBannerPage()),
                          );

                          if (result == true) {
                            controller.fetchBanners();
                          }
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Add Banner",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffF4B400),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // 🔥 same round
                          ),
                          elevation: 3,
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// 🔴 CLEAR BUTTON (ONLY WHEN FILTER APPLIED)
                      if (searchController.text.isNotEmpty ||
                          (categoryFilter != null && categoryFilter != "All") ||
                          (statusFilter != null && statusFilter != "All"))

                        ElevatedButton.icon(
                          onPressed: () {

                            /// 🔥 RESET SEARCH
                            searchController.clear();

                            /// 🔥 RESET FILTERS
                            setState(() {
                              categoryFilter = "All";
                              statusFilter = "All";
                            });

                            /// 🔥 RESET CONTROLLER
                            controller.search = "";
                            controller.pageType = "";
                            controller.status = "all";

                            /// 🔥 REFRESH DATA
                            controller.fetchBanners();
                          },

                          icon: const Icon(Icons.close, color: Colors.white),

                          label: const Text(
                            "Clear",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // 🔴 red color
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // same round
                            ),
                            elevation: 3,
                          ),
                        ),

                    ],
                  ),

                  const SizedBox(height: 20),

                  /// SEARCH
                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {}); //

                      if (_debounce?.isActive ?? false) _debounce!.cancel();

                      _debounce = Timer(const Duration(milliseconds: 700   ), () {
                        controller.search = value;
                        controller.fetchBanners();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search Banner...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// CATEGORY
                  DropdownButtonFormField<String>(
                    value: categoryFilter,
                    decoration: InputDecoration(
                      hintText: "Filter by category...",
                      prefixIcon: const Icon(Icons.filter_list),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "All", child: Text("All")),
                      DropdownMenuItem(value: "Home", child: Text("Home")),
                      DropdownMenuItem(value: "Blog", child: Text("Blog")),
                      DropdownMenuItem(value: "Careers", child: Text("Careers")),
                      DropdownMenuItem(value: "About Us", child: Text("About Us")),
                      DropdownMenuItem(value: "Services", child: Text("Services")),
                      DropdownMenuItem(value: "Our Work", child: Text("Our Work")),
                      DropdownMenuItem(value: "Solutions", child: Text("Solutions")),
                    ],
                    onChanged: (value) {
                      setState(() => categoryFilter = value);
                      controller.pageType =
                      value == "All" ? "" : mapCategory(value!);
                      controller.fetchBanners();
                    },
                  ),

                  const SizedBox(height: 15),

                  /// STATUS
                  DropdownButtonFormField<String>(
                    value: statusFilter,
                    decoration: InputDecoration(
                      hintText: "Filter by status...",
                      prefixIcon: const Icon(Icons.filter_alt),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "All", child: Text("All")),
                      DropdownMenuItem(value: "active", child: Text("Active")),
                      DropdownMenuItem(value: "inactive", child: Text("Inactive")),
                    ],
                    onChanged: (value) {
                      setState(() => statusFilter = value);
                      controller.status =
                      value == "All" ? "all" : value!;
                      controller.fetchBanners();
                    },
                  ),

                  const SizedBox(height: 20),

                  /// TABLE
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(

                      columnSpacing: 40,
                      dataRowMinHeight: 80,
                      dataRowMaxHeight: 140,

                      columns: const [
                        DataColumn(label: Text("Actions",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),)),
                        DataColumn(label: Text("Title",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),)),
                        DataColumn(label: Text("Description",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),)),
                        DataColumn(label: Text("Image",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),)),
                        DataColumn(label: Text("Video",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),)),
                        DataColumn(label: Text("Page Type",style: TextStyle(fontSize:16, fontWeight: FontWeight.bold),)),
                        DataColumn(label: Text("Status",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),)),
                        DataColumn(label: Text("Order",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),)),
                      ],

                      /// ✅ SHIMMER ONLY IN ROWS
                      rows: controller.isLoading
                          ? List.generate(6, (index) => _buildShimmerRow())
                          : controller.banners.map((banner) {
                        return DataRow(cells: [


                          DataCell(
                            Row(
                              children: [

                                /// ✏️ EDIT
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () async {

                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddBannerPage(
                                          bannerData: banner.toJson(),
                                        ),
                                      ),
                                    );

                                    if (result == true) {
                                      Provider.of<BannerController>(context, listen: false)
                                          .fetchBanners();
                                    }
                                  },
                                ),

                                const SizedBox(width: 8),

                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {

                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Consumer<BannerController>(
                                          builder: (context, controller, child) {

                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(20),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [

                                                    /// 🔴 ICON
                                                    const CircleAvatar(
                                                      radius: 30,
                                                      backgroundColor: Color(0xffFEE2E2),
                                                      child: Icon(Icons.delete, color: Colors.red, size: 30),
                                                    ),

                                                    const SizedBox(height: 15),

                                                    /// TITLE
                                                    const Text(
                                                      "Delete Banner",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 8),

                                                    /// MESSAGE
                                                    const Text(
                                                      "Are you sure you want to delete this banner?",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: Colors.grey),
                                                    ),

                                                    const SizedBox(height: 20),

                                                    /// BUTTONS
                                                    Row(
                                                      children: [

                                                        /// CANCEL
                                                        Expanded(
                                                          child: OutlinedButton(
                                                            onPressed: controller.isDeleting
                                                                ? null
                                                                : () {
                                                              Navigator.pop(context);
                                                            },
                                                            child: const Text("Cancel"),
                                                          ),
                                                        ),

                                                        const SizedBox(width: 10),

                                                        /// DELETE WITH LOADER
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: controller.isDeleting
                                                                ? null
                                                                : () async {

                                                              await controller.deleteBanner(banner.id!);

                                                              Navigator.pop(context);

                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text("Deleted successfully"),
                                                                  backgroundColor: Colors.green,
                                                                ),
                                                              );
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.red,
                                                            ),

                                                            child: controller.isDeleting
                                                                ? const SizedBox(
                                                              height: 18,
                                                              width: 18,
                                                              child: CircularProgressIndicator(
                                                                color: Colors.white,
                                                                strokeWidth: 2,
                                                              ),
                                                            )
                                                                : const Text("Delete"),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),








                              ],
                            ),
                          ),



                          DataCell(SizedBox(
                            width: 150,
                            child: Text(banner.title,style: TextStyle(fontWeight: FontWeight.bold),),
                          )),

                          DataCell(SizedBox(
                            width: 200,
                            child: Text(banner.description,style: TextStyle(fontWeight: FontWeight.bold),),
                          )),

                         /* DataCell(
                            banner.image.isNotEmpty
                                ? Image.network(banner.image,
                                width: 80, height: 60)
                                : const Icon(Icons.image),
                          ),*/

                          DataCell(
                            banner.image.isNotEmpty
                                ? Builder(
                              builder: (context) {
                                String img = banner.image;

                                if (!img.startsWith("http")) {
                                  img = "https://cocomastudios.com/$img";
                                }

                                return Image.network(
                                  img,
                                  width: 80,
                                  height: 60,
                                  errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                                );
                              },
                            )
                                : const Icon(Icons.image),
                          ),

                          DataCell(
                            banner.video.isNotEmpty
                                ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VideoPlayerPage(
                                      videoUrl: banner.video,
                                    ),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: 80,
                                height: 60,
                                child: _VideoPreview(url: banner.video),
                              ),
                            )
                                : const SizedBox(),
                          ),

                          DataCell(Text(banner.pageType,style: TextStyle(fontWeight: FontWeight.bold),)),



                          DataCell(
                            Row(
                              children: [

                                Switch(
                                  value: banner.status == "active",

                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.red,
                                  inactiveTrackColor: Colors.red.withOpacity(0.4),

                                  onChanged: (value) {
                                    _showStatusDialog(context, banner);
                                  },
                                ),

                                const SizedBox(width: 6),

                                Text(
                                  banner.status,
                                  style: TextStyle(
                                    color: banner.status == "active"
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),



                          DataCell(Text(banner.displayOrder.toString())),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 SHIMMER ROW
  DataRow _buildShimmerRow() {
    return DataRow(cells: [
      DataCell(Row(children: [
        shimmerCircle(20),
        const SizedBox(width: 8),
        shimmerCircle(20),
      ])),
      DataCell(shimmerBox(width: 120, height: 12)),
      DataCell(shimmerBox(width: 180, height: 12)),
      DataCell(shimmerBox(width: 60, height: 60)),
      DataCell(shimmerBox(width: 60, height: 60)),
      DataCell(shimmerPill(width: 70, height: 25)),
      DataCell(shimmerPill(width: 60, height: 25)),
      DataCell(shimmerBox(width: 20, height: 12)),
    ]);
  }
}

/// SHIMMER HELPERS

Widget shimmerBox({required double width, required double height}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );
}

Widget shimmerCircle(double size) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    ),
  );
}

Widget shimmerPill({required double width, required double height}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}


/// VIDEO PREVIEW
class _VideoPreview extends StatefulWidget {
  final String url;

  const _VideoPreview({required this.url});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  VideoPlayerController? controller;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  Future<void> initVideo() async {
    try {
      print("VIDEO URL: ${widget.url}");

      controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.url));

      await controller!.initialize();

      controller!.setVolume(0);
      controller!.setLooping(true);
      controller!.play();

      if (mounted) setState(() {});
    } catch (e) {
      print("VIDEO ERROR: $e");
      isError = true;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isError) {
      return const Icon(Icons.error, color: Colors.red);
    }

    if (controller == null || !controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: controller!.value.aspectRatio,
            child: VideoPlayer(controller!),
          ),
          const Icon(
            Icons.play_circle_fill,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }
}




