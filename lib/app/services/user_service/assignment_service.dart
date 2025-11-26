import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart';
import 'package:webinar/app/models/assignment_model.dart';
import 'package:webinar/app/models/instructor_assignment_model.dart';
import 'package:webinar/common/utils/http_handler.dart';
import '../../../common/data/app_data.dart';
import '../../../common/data/app_language.dart';
import '../../../common/enums/error_enum.dart';
import '../../../common/utils/constants.dart';
import '../../../common/utils/error_handler.dart';
import '../../../locator.dart';
import '../../models/chat_model.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';



class AssignmentService{

  static Future<List<AssignmentModel>> getAssignments()async{
    List<AssignmentModel> data = [];
    try{
      String url = '${Constants.baseUrl}panel/my_assignments';


      Response res = await httpGetWithToken(
        url, 
      );
      

      var jsonResponse = jsonDecode(res.body);
      log("getAssignments => ${jsonResponse.toString()}");
      
      if(jsonResponse['success']){
        jsonResponse['data']['assignments'].forEach((json){
          data.add(AssignmentModel.fromJson(json));
        });
        
        return data;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return data;
      }

    }catch(e){
      return data;
    }
  }


  static Future<InstructorAssignmentModel?> getAllAssignmentsInstructor()async{
    try{
      String url = '${Constants.baseUrl}instructor/assignments';


      Response res = await httpGetWithToken(
        url, 
      );
      

      var jsonResponse = jsonDecode(res.body);
      if(jsonResponse['success']){

        return InstructorAssignmentModel.fromJson(jsonResponse['data']);
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }

    }catch(e){
      return null;
    }
  }
  
  static Future<List<AssignmentModel>> getStudents(int assignmentId)async{
    List<AssignmentModel> data = [];

    try{
      String url = '${Constants.baseUrl}instructor/assignments/$assignmentId/students';


      Response res = await httpGetWithToken(
        url, 
      );
      

      var jsonResponse = jsonDecode(res.body);
      if(jsonResponse['success']){
        jsonResponse['data'].forEach((json){
          data.add(AssignmentModel.fromJson(json));
        });

        return data;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return data;
      }

    }catch(e){
      return data;
    }
  }
  
  
  static Future<bool> setGrade(int historyId, int grade)async{

    try{
      String url = '${Constants.baseUrl}instructor/assignments/histories/$historyId/rate';


      Response res = await httpPostWithToken(
        url, 
        {
          "grade": grade
        }
      );
      

      var jsonResponse = jsonDecode(res.body);
      
      if(jsonResponse['success']){
        ErrorHandler().showError(ErrorEnum.success, jsonResponse,readMessage: true);
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }

    }catch(e){
      return false;
    }
  }
  

  static Future<List<ChatModel>> getHistory(int assignmentId, int studentId)async{
    List<ChatModel> data = [];

    try{
      String url = '${Constants.baseUrl}panel/assignments/$assignmentId/messages?student_id=$studentId';

      Response res = await httpGetWithToken(
        url, 
      );
      

      var jsonResponse = jsonDecode(res.body);
      if(jsonResponse['success']){
        jsonResponse['data'].forEach((json){
          data.add(ChatModel.fromJson(json));
        });

        return data;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return data;
      }

    }catch(e){
      return data;
    }
  }
  
  


static Future<bool> newQuestion(int id, String fileTitle, String desc, File? file, int studentId) async {
  print("newQuestion => $id, $fileTitle, $desc, $file, $studentId");
  try {
    String url = '${Constants.baseUrl}panel/assignments/$id/messages';
    var uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);

    // إضافة الحقول العادية
    request.fields['message'] = desc;
    request.fields['student_id'] = studentId.toString();
    if (fileTitle.isNotEmpty) {
      request.fields['file_title'] = fileTitle;
    }

    // إضافة الملف إذا موجود
    if (file != null) {
      var multipartFile = await http.MultipartFile.fromPath('file_path', file.path);
      request.files.add(multipartFile);
    }

    // جلب التوكن
    String token = await AppData.getAccessToken();

    // تحضير الهيدرز كاملة
    Map<String, String> headers = {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
      'x-api-key': Constants.apiKey,
      'x-locale': locator<AppLanguage>().currentLanguage.toLowerCase(),
    };

    request.headers.addAll(headers);

    // إرسال الطلب
    var streamedResponse = await request.send();

    // الحصول على الرد الكامل
    var response = await http.Response.fromStream(streamedResponse);
    print("Response status: ${response.statusCode}");
    log("Response body: ${response.body}");
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print("newQuestion => $jsonResponse");

      if (jsonResponse['success']) {
        ErrorHandler().showError(ErrorEnum.success, jsonResponse, readMessage: true);
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } else {
      print('Server responded with status: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error in newQuestion: $e');
    return false;
  }
}




}