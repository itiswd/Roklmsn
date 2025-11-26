import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:webinar/app/models/chapter_youtube_model.dart';
import 'package:webinar/common/components.dart';

import '../../../common/enums/error_enum.dart';
import '../../../common/utils/constants.dart';
import '../../../common/utils/error_handler.dart';
import '../../../common/utils/http_handler.dart';
import '../../models/chapter_model .dart';

class RedeemResult {
  final bool success;
  final String message;

  RedeemResult({required this.success, required this.message});
}

class ChapterService {
  static Future<RedeemResult> redeemCode(String code) async {
    String url = '${Constants.baseUrl}panel/subscription-code-chapters/redeem';

    Response res = await httpPostWithToken(url, {'code': code});
    var jsonRes = jsonDecode(res.body);

    if (jsonRes['success'] == true) {
      return RedeemResult(success: true, message: jsonRes['message'] ?? 'تم استرداد الكود بنجاح');
    } else if (jsonRes['status'] == "CODE_REDEEMED") {
      return RedeemResult(success: true, message: jsonRes['message'] ?? 'الكود مستخدم مسبقاً');
    } else {
      throw Exception(jsonRes['message'] ?? 'حدث خطأ غير معروف');
    }
  }





  static Future<ChapterDetails?> getChaptersDetails({required String chapterId})async{

    String url = '${Constants.baseUrl}panel/files/$chapterId';
    print(url);
    print("url getChaptersDetails");

    Response res = await httpGetWithToken(
        url,
        );

    print(res.body);
    print("res getChaptersDetails");
    var jsonRes = jsonDecode(res.body);
    print(jsonRes);
    print("jsonRes");

    if (jsonRes['success'] ?? false) {
      print("jsonRes['data'] ${jsonRes['data']}");
      
      return ChapterDetails.fromJson(jsonRes);
    }else{
      ErrorHandler().showError(ErrorEnum.error, jsonRes, readMessage: true);
      return null;
    }
  }

  static Future<List<ChapterModel>?> getChaptersData() async {
  String url = '${Constants.baseUrl}panel/chapters';
  print(url);
  print("url getChaptersData");

  Response res = await httpGetWithToken(url);

  log("getChaptersData=> ${res.body.toString()}");
  print("res getChaptersData");
  var jsonRes = jsonDecode(res.body);
  print(jsonRes);
  print("jsonRes getChaptersData");

  if (jsonRes['success'] ?? false) {
    List<dynamic> dataList = jsonRes['data'];
    // إذا ChapterModel يمثل عنصر واحد، لازم تحول كل عنصر في القائمة إلى ChapterModel
    return dataList.map((e) => ChapterModel.fromJson(e)).toList();
  } else {
    ErrorHandler().showError(ErrorEnum.error, jsonRes, readMessage: true);
    return null;
  }
}

 
}