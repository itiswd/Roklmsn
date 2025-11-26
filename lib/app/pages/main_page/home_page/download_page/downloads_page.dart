import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webinar/common/common.dart';
import '../../../../../common/components.dart';

class DownloadsPage extends StatefulWidget {
  static const String pageName = '/downloads';
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  List<FileSystemEntity> downloadedFiles = [];

  @override
  void initState() {
    super.initState();
    fetchDownloads();
  }

  Future<void> fetchDownloads() async {
    PermissionStatus res = await Permission.storage.request();
    if (!res.isGranted) {
      print("❌ الإذن مرفوض، لا يمكن الوصول إلى الملفات.");
      return;
    }

    try {
      String directory = (await getApplicationSupportDirectory()).path;
      List<FileSystemEntity> allFiles = Directory(directory).listSync();

      setState(() {
        downloadedFiles = allFiles;
      });

      print("📂 تم العثور على ${downloadedFiles.length} ملفات.");
    } catch (e) {
      print("❌ خطأ أثناء جلب الملفات: $e");
    }
  }

  void deleteFile(FileSystemEntity file) async {
    try {
      await file.delete();
      setState(() {
        downloadedFiles.remove(file);
      });
      print("🗑️ تم حذف الملف: ${file.path}");
      showSnackBarMessage("تم حذف الملف بنجاح");
    } catch (e) {
      print("❌ خطأ أثناء حذف الملف: $e");
      showSnackBarMessage("فشل حذف الملف");
    }
  }

  void showSnackBarMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  Icon getFileIcon(String path) {
    if (path.endsWith('.pdf')) {
      return Icon(Icons.picture_as_pdf, size: 30, color: Colors.red);
    } else if (path.endsWith('.mp4') || path.endsWith('.avi') || path.endsWith('.mov')) {
      return Icon(Icons.video_library, size: 30, color: Colors.blue);
    } else if (path.endsWith('.mp3') || path.endsWith('.wav')) {
      return Icon(Icons.audiotrack, size: 30, color: Colors.green);
    } else {
      return Icon(Icons.insert_drive_file, size: 30, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Scaffold(
        appBar: appbar(title: "📂 الملفات المحملة", context: context),
        body: downloadedFiles.isEmpty
            ? const Center(child: Text("لا توجد ملفات متاحة"))
            : ListView.builder(
          itemCount: downloadedFiles.length,
          itemBuilder: (context, index) {
            FileSystemEntity file = downloadedFiles[index];
            String fileName = file.path.split('/').last;

            return ListTile(
              leading: getFileIcon(file.path),
              title: Text(fileName, style: const TextStyle(fontSize: 16)),
              onTap: () {
                print("📂 فتح الملف: $fileName");
                // OpenFile.open(file.path);
              },
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  deleteFile(file);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}