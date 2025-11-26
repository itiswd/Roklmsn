import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/common/common.dart';
import 'dart:convert';

import '../../../../../common/components.dart';
import '../../../../../common/utils/constants.dart';
import '../../../../../common/utils/object_instance.dart';
import '../../../../../config/assets.dart';
import '../../../../../config/colors.dart';
import '../../../../providers/drawer_provider.dart';
import '../../../../services/guest_service/course_service.dart';

class EnrollmentPage extends StatefulWidget {
  static const String pageName = '/enrollment';

  const EnrollmentPage({super.key});

  @override
  State<EnrollmentPage> createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends State<EnrollmentPage> {
  TextEditingController _codeController = TextEditingController();

  bool isLoading = false;

  Future<void> sendCode(String code) async {
    setState(() {
      isLoading = true;
    });
    final url = '${Constants.baseUrl}panel/use-code-course';

    // إرسال البيانات في الـ body
    bool response = await CourseService.enrollment(url, code);
    // التحقق من الاستجابة
    if (response) {
      nextRoute(
        MainPage.pageName,
      );
      // يمكنك هنا إضافة كود للعرض الناجح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code sent successfully!')),
      );
    } else {
      // يمكنك هنا إضافة كود للخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send code!')),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawerProvider>(builder: (context, drawerProvider, _) {
      return ClipRRect(
        borderRadius:
            borderRadius(radius: drawerProvider.isOpenDrawer ? 20 : 0),
        child: Scaffold(
          appBar: appbar(
            title: 'ادخل رقم الكارت هنا', context: context,
            // leftIcon: AppAssets.menuSvg,
            // onTapLeftIcon: (){
            //   print("menu");
            //   drawerController.showDrawer();
            // }
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'ادخل الرقم هنا',
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
                SizedBox(height: 20),
                if (isLoading)
                  CircularProgressIndicator(
                    color: mainColor(),
                  )
                else
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(mainColor()),
                    ),
                    onPressed: () {
                      String code = _codeController.text.trim();
                      if (code.isNotEmpty) {
                        sendCode(code); // إرسال الكود
                      } else {
                        // إذا الكود فارغ
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter a code')),
                        );
                      }
                    },
                    child: Text('تفعيل'),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
