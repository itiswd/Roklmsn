import 'package:flutter/material.dart';

import '../../../../services/user_service/chapter_service.dart';
import 'chapter_list_page.dart';

class CodePage extends StatefulWidget {
  static const String pageName = '/CodePage';
  const CodePage({Key? key}) : super(key: key);

  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  void _redeemAndNavigate() async {
    final code = codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ادخل رقم الكارت')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result =
          await ChapterService.redeemCode(code); // هتكون RedeemResult

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChapterListPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        isLoading = false;
        codeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              const Text('ادخل الرقم', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'ادخل رقم الكارت هنا',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.code),
                suffixIcon: Icon(Icons.check),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(color: Colors.grey),
                errorStyle: TextStyle(color: Colors.red),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
                errorMaxLines: 3,
                counterText: '',
                counterStyle: TextStyle(color: Colors.grey),
                prefixStyle: TextStyle(color: Colors.grey),
                suffixStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _redeemAndNavigate,
                    child: const Text('عرض الفصول'),
                  ),
          ],
        ),
      ),
    );
  }
}
