import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../controller/banner_controller.dart';

class AddBannerPage extends StatefulWidget {
  final Map<String, dynamic>? bannerData;

  const AddBannerPage({super.key, this.bannerData});

  @override
  State<AddBannerPage> createState() => _AddBannerPageState();
}

class _AddBannerPageState extends State<AddBannerPage> {
  final _formKey = GlobalKey<FormState>();

  String mediaType = "Image";
  String? pageType;
  String status = "Active";

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final videoUrlController = TextEditingController();
  final displayOrderController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? imageFile;
  File? videoFile;

  YoutubePlayerController? ytController;
  VideoPlayerController? previewController;

  String? imageUrl;

  bool isImageRemoved = false;
  bool isVideoRemoved = false;
  bool isVideoLoading = false;

  /// ================= PREFILL =================
  @override
  void initState() {
    super.initState();

    if (widget.bannerData != null) {
      final data = widget.bannerData!;

      titleController.text = data["title"] ?? "";
      descController.text = data["description"] ?? "";
      displayOrderController.text =
          data["display_order"]?.toString() ?? "";

      status =
      data["status"] == "active" ? "Active" : "Inactive";

      pageType = _mapPageType(data["page_type"]);

      /// IMAGE
      if ((data["image"] ?? "").isNotEmpty) {
        mediaType = "Image";
        imageUrl = data["image"].startsWith("http")
            ? data["image"]
            : "https://cocomastudios.com/${data["image"]}";
      }

      /// VIDEO
      if ((data["video"] ?? "").isNotEmpty) {
        mediaType = "Video";
        initVideo(
          data["video"].startsWith("http")
              ? data["video"]
              : "https://cocomastudios.com/${data["video"]}",
        );
      }

      /// YOUTUBE
      if ((data["video_url"] ?? "").isNotEmpty) {
        mediaType = "Video URL";
        videoUrlController.text = data["video_url"];
        loadVideo();
      }
    }
  }

  String? _mapPageType(String? raw) {
    switch (raw) {
      case "home":
        return "Home";
      case "about_us":
        return "About Us";
      case "service":
        return "Services";
      case "our_work":
        return "Our Work";
      case "solution":
        return "Solutions";
      case "blog":
        return "Blog";
      case "career":
        return "Careers";
      default:
        return null;
    }
  }

  String _mapPageTypeToApi(String? value) {
    return value?.toLowerCase().replaceAll(" ", "_") ?? "";
  }

  /// ================= VIDEO =================
  Future<void> initVideo(String url) async {
    setState(() => isVideoLoading = true);

    await previewController?.dispose();

    final controller =
    VideoPlayerController.networkUrl(Uri.parse(url));

    await controller.initialize();

    setState(() {
      previewController = controller;
      isVideoLoading = false;
    });
  }

  void loadVideo() {
    final id =
    YoutubePlayer.convertUrlToId(videoUrlController.text);
    if (id != null) {
      ytController = YoutubePlayerController(
        initialVideoId: id,
        flags: const YoutubePlayerFlags(autoPlay: false),
      );
      setState(() {});
    }
  }

  /// ================= PICK =================
  Future pickImage() async {
    final picked =
    await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
        imageUrl = null;
        isImageRemoved = false;
      });
    }
  }

  Future pickVideo() async {
    final picked =
    await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      videoFile = File(picked.path);
      initVideo(videoFile!.path);
      isVideoRemoved = false;
    }
  }

  @override
  void dispose() {
    previewController?.dispose();
    ytController?.dispose();
    super.dispose();
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bannerData == null
            ? "Add Banner"
            : "Update Banner"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              /// TITLE
              TextFormField(
                controller: titleController,
                validator: (v) =>
                v!.isEmpty ? "Enter title" : null,
                decoration:
                const InputDecoration(labelText: "Title"),
              ),

              const SizedBox(height: 15),

              /// DESC
              TextField(
                controller: descController,
                maxLines: 3,
                decoration:
                const InputDecoration(labelText: "Description"),
              ),

              const SizedBox(height: 15),

              /// MEDIA TYPE
              Row(
                children: [
                  _chip("Image"),
                  _chip("Video"),
                  _chip("Video URL"),
                ],
              ),

              const SizedBox(height: 15),

              /// IMAGE
              if (mediaType == "Image") ...[
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey)),
                    child: imageFile != null
                        ? Image.file(imageFile!, fit: BoxFit.cover)
                        : imageUrl != null
                        ? Image.network(imageUrl!,
                        fit: BoxFit.cover)
                        : const Center(
                        child: Text("Choose Image")),
                  ),
                ),

                if (imageFile != null || imageUrl != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        imageFile = null;
                        imageUrl = null;
                        isImageRemoved = true;
                      });
                    },
                    child: const Text("Remove Image"),
                  ),
              ],

              /// VIDEO
              if (mediaType == "Video") ...[
                Container(
                  height: 200,
                  child: previewController != null &&
                      previewController!.value.isInitialized
                      ? VideoPlayer(previewController!)
                      : const Center(child: Text("Choose Video")),
                ),

                ElevatedButton(
                  onPressed: pickVideo,
                  child: const Text("Pick Video"),
                ),

                if (videoFile != null || previewController != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        videoFile = null;
                        previewController?.dispose();
                        previewController = null;
                        isVideoRemoved = true;
                      });
                    },
                    child: const Text("Remove Video"),
                  ),
              ],

              /// YOUTUBE
              if (mediaType == "Video URL") ...[
                TextField(
                  controller: videoUrlController,
                  decoration:
                  const InputDecoration(labelText: "YouTube URL"),
                ),
                ElevatedButton(
                  onPressed: loadVideo,
                  child: const Text("Preview"),
                ),
                if (ytController != null)
                  YoutubePlayer(controller: ytController!)
              ],

              const SizedBox(height: 15),

              /// PAGE TYPE
              DropdownButtonFormField<String>(
                value: pageType,
                items: const [
                  DropdownMenuItem(value: "Home", child: Text("Home")),
                  DropdownMenuItem(
                      value: "About Us", child: Text("About Us")),
                  DropdownMenuItem(
                      value: "Services", child: Text("Services")),
                  DropdownMenuItem(
                      value: "Our Work", child: Text("Our Work")),
                  DropdownMenuItem(
                      value: "Solutions", child: Text("Solutions")),
                  DropdownMenuItem(value: "Blog", child: Text("Blog")),
                  DropdownMenuItem(
                      value: "Careers", child: Text("Careers")),
                ],
                onChanged: (v) => setState(() => pageType = v),
              ),

              const SizedBox(height: 15),

              /// DISPLAY ORDER
              TextFormField(
                controller: displayOrderController,
                keyboardType: TextInputType.number,
                validator: (v) =>
                v!.isEmpty ? "Enter order" : null,
                decoration: const InputDecoration(
                    labelText: "Display Order"),
              ),

              const SizedBox(height: 15),

              /// STATUS
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(
                      value: "Active", child: Text("Active")),
                  DropdownMenuItem(
                      value: "Inactive", child: Text("Inactive")),
                ],
                onChanged: (v) => setState(() => status = v!),
              ),

              const SizedBox(height: 20),

              /// BUTTON
              Consumer<BannerController>(
                builder: (context, controller, child) {
                  bool loading = widget.bannerData == null
                      ? controller.isCreating
                      : controller.isUpdating;

                  return ElevatedButton(
                    onPressed: loading
                        ? null
                        : () async {

                      if (!_formKey.currentState!.validate()) return;

                      if (pageType == null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                            content: Text("Select page type")));
                        return;
                      }

                      bool success;

                      if (widget.bannerData == null) {
                        success = await controller.createBanner(
                          title: titleController.text,
                          description: descController.text,
                          pageType: _mapPageTypeToApi(pageType),
                          status: status.toLowerCase(),
                          displayOrder:
                          displayOrderController.text,
                          videoUrl: videoUrlController.text,
                          imageFile: imageFile,
                          videoFile: videoFile,
                        );
                      } else {
                        success = await controller.updateBanner(
                          id: widget.bannerData!["id"],
                          title: titleController.text,
                          description: descController.text,
                          pageType: _mapPageTypeToApi(pageType),
                          status: status.toLowerCase(),
                          displayOrder:
                          displayOrderController.text,
                          videoUrl: videoUrlController.text,
                          imageFile: imageFile,
                          videoFile: videoFile,
                          isImageRemoved: isImageRemoved,
                          isVideoRemoved: isVideoRemoved,
                        );
                      }

                      if (success) Navigator.pop(context, true);
                    },
                    child: loading
                        ? const CircularProgressIndicator()
                        : Text(widget.bannerData == null
                        ? "Create"
                        : "Update"),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return ChoiceChip(
      label: Text(text),
      selected: mediaType == text,
      onSelected: (_) => setState(() => mediaType = text),
    );
  }
}