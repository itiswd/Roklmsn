import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../../../common/common.dart';
import '../../../../../common/utils/constants.dart';
import '../../../../models/chapter_youtube_model.dart';
import '../../../../services/user_service/chapter_service.dart';
import '../../../../widgets/main_widget/home_widget/single_course_widget/course_video_player.dart';
import '../../../../widgets/main_widget/home_widget/single_course_widget/custom_video_player.dart';
import '../single_course_page/single_content_page/pdf_viewer_page.dart';

class ChapterDetailsPage extends StatefulWidget {
  static const String pageName = '/ChapterDetailsPage';

  const ChapterDetailsPage({super.key});

  @override
  State<ChapterDetailsPage> createState() => _ChapterDetailsPageState();
}

class _ChapterDetailsPageState extends State<ChapterDetailsPage> {
  ChapterDetails? chapterDetails;
  bool isLoading = true;
  String? chapterId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final argChapterId = args != null ? args['chapterId']?.toString() : null;

    if (argChapterId != null && argChapterId != chapterId) {
      chapterId = argChapterId;
      loadChapterDetails();
    }
  }

  void loadChapterDetails() async {
    setState(() {
      isLoading = true;
    });
    final details =
        await ChapterService.getChaptersDetails(chapterId: chapterId!);
    log("details: ${details.toString()}");
    log("details?.data?.id: ${details?.data?.id.toString()}");
    setState(() {
      chapterDetails = details;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الفصل')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (chapterDetails == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الفصل')),
        body: const Center(child: Text('لا توجد تفاصيل لهذا الفصل')),
      );
    }

    return Scaffold(
      appBar:
          AppBar(title: Text(chapterDetails!.data?.title ?? 'تفاصيل الفصل')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'الوصف: ${chapterDetails!.data?.description ?? "لا يوجد وصف"}'),
              const SizedBox(height: 10),
              if (chapterDetails?.data?.storage == "youtube")
                PodVideoPlayerDev(
                  chapterDetails!.data?.file ?? '',
                  chapterDetails!.data?.storage ?? '',
                  Constants.contentRouteObserver,
                  name: chapterDetails!.data?.title ?? '',
                ),
              if (chapterDetails!.data?.fileType == "pdf")
                ElevatedButton.icon(
                  onPressed: () {
                    nextRoute(
                      PdfViewerPage.pageName,
                      arguments: [
                        chapterDetails!.data?.file,
                        chapterDetails!.data?.title,
                      ],
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("عرض الملف PDF"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                ),
              if (chapterDetails?.data?.storage == "upload")
                CourseVideoPlayer(
                  chapterDetails!.data?.file ?? '',
                  '',
                  Constants.contentRouteObserver,
                  name: chapterDetails!.data?.title ?? '',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
