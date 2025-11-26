import 'package:flutter/material.dart';
import 'package:webinar/common/common.dart';

import '../../../../models/chapter_model .dart';
import '../../../../services/user_service/chapter_service.dart';
import '../quizzes_page/quiz_page.dart';
import 'chapter_details_page.dart';

class ChapterListPage extends StatefulWidget {
  static const String pageName = '/ChapterListPage';

  const ChapterListPage({Key? key}) : super(key: key);

  @override
  State<ChapterListPage> createState() => _ChapterListPageState();
}

class _ChapterListPageState extends State<ChapterListPage> {
  List<ChapterModel>? chapterModels;
  bool isLoading = true;

  int? openedIndex; // 👈 لتتبع العنصر المفتوح

  @override
  void initState() {
    super.initState();
    loadChapters();
  }

  void loadChapters() async {
    setState(() => isLoading = true);

    try {
      final result = await ChapterService.getChaptersData();
      setState(() {
        chapterModels = result ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        chapterModels = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('قائمة الفصول')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الفصول'),
        // لون خلفية AppBar من ثيم التطبيق
        backgroundColor: theme.primaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: chapterModels!.length,
        itemBuilder: (context, index) {
          final course = chapterModels![index];
          final chapter = course.items;
          final items = chapter ?? [];

          return Column(
            children: [
              Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: theme.cardColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  leading: Icon(
                    Icons.book,
                    color: theme.primaryColor,
                    size: 32,
                  ),
                  title: GestureDetector(
                    onTap: () {
                      setState(() {
                        openedIndex = openedIndex == index ? null : index;
                      });
                    },
                    child: Text(
                      course.title ?? 'فصل غير متوفر',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),

              if (openedIndex == index)
                ...items.map((item) => GestureDetector(
                      onTap: () {
                        if(item.type == 'quiz'){
                     nextRoute(QuizPage.pageName,arguments: [item.id]);
                        }else{
                        nextRoute(ChapterDetailsPage.pageName,arguments: {
                          "chapterId": item.id,
                        });

                        }

                      },
                  child: Card(
                        color: theme.colorScheme.secondary.withOpacity(0.1), // لون فاتح من الثيم
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            item?.title ?? 'بدون عنوان',
                            style: theme.textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            'نوع: ${item.type ?? 'غير معروف'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                )),
            ],
          );
        },
      ),
    );
  }
}
