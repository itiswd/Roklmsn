import 'dart:convert';
import 'dart:developer';
import 'dart:io'; //mahmoud
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //mahmoud
import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/common/utils/error_handler.dart';
import 'package:webinar/common/utils/http_handler.dart';
import 'package:http/http.dart';

class AuthenticationService {
  static Future google(String email, String token, String name) async {
    try {
      String url = '${Constants.baseUrl}google/callback';

      Response res = await httpPost(url, {
        'email': email,
        'name': name,
        'id': token,
      });

      print(res.body);

      if (res.statusCode == 200) {
        await AppData.saveAccessToken(jsonDecode(res.body)['data']['token']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future facebook(String email, String token, String name) async {
    try {
      String url = '${Constants.baseUrl}facebook/callback';

      Response res =
          await httpPost(url, {'id': token, 'name': name, 'email': email});

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        await AppData.saveAccessToken(jsonDecode(res.body)['data']['token']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future login(String username, String password) async {
    try {
      String url = '${Constants.baseUrl}login';

      Response res = await httpPost(
        url,
        {'mobile': username, 'password': password},
        // headers: {
        //   'x-api-key' : Constants.apiKey,
        //   'Content-Type' : 'application/json',
        //   'Accept' : 'application/json',
        //
        // }
      );

      log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        print('loged in from service');
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        print(jsonResponse['data']['user_id']);
        print("jsonResponse['data']['user_id']");
        await AppData.saveEmail(username);
        await AppData.saveName('');
        return true;
      } else {
        ErrorHandler()
            .showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

/*
  static Future<Map?> registerWithEmail(
    String registerMethod,
    String email,
    String password,
    String repeatPassword,
    String? accountType,
    List<Fields>? fields,
    // String? countryCode,
    String? mobile,
    String? parentPhoneNumber,
    String? city,
    String? fullName,
  ) async {
    try {
      String url = '${Constants.baseUrl}register/step/1';

      Map body = {
        "register_method": registerMethod,
        'email': email,
        'password': password,
        'password_confirmation': repeatPassword,
        // "country_code": countryCode,
        'mobile': mobile,
        'parent_phone_number': parentPhoneNumber,
        'city': city,
        "full_name": fullName
      };

      print(body);
      if (fields != null) {
        Map bodyFields = {};
        for (var i = 0; i < fields.length; i++) {
          if (fields[i].type != 'upload') {
            bodyFields.addEntries({
              fields[i].id: (fields[i].type == 'toggle')
                  ? fields[i].userSelectedData == null
                      ? 0
                      : 1
                  : fields[i].userSelectedData
            }.entries);
          }
        }

        body.addEntries({'fields': bodyFields.toString()}.entries);
      }

      Response res = await httpPost(url, body);
      print(res.body);
      print("res after httpPost");

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success'] ||
          jsonResponse['status'] == 'go_step_2' ||
          jsonResponse['status'] == 'go_step_3') {
            print( "success => ${jsonResponse['data']['token']}");
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        await AppData.saveName(fullName ?? '');
        return {
          'user_id': jsonResponse['data']['user_id'],
          'step': jsonResponse['status']
        };
      } else {
        showSnackBar(ErrorEnum.error, jsonResponse['message'] ?? 'An error occurred');
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  */

///////// mahmoud
  static Future<Map?> registerWithEmail(
    String registerMethod,
    String email,
    String password,
    String repeatPassword,
    String? accountType,
    List<Fields>? fields,
    // String? countryCode,
    String? mobile,
    String? parentPhoneNumber,
    String? city,
    String? fullName,
    File? nationalIdImage, // Added national ID image parameter
  ) async {
    try {
      String url = '${Constants.baseUrl}register/step/1';

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add text fields
      request.fields['register_method'] = registerMethod;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['password_confirmation'] = repeatPassword;
      // request.fields['country_code'] = countryCode ?? '';
      request.fields['mobile'] = mobile ?? '';
      request.fields['parent_phone_number'] = parentPhoneNumber ?? '';
      request.fields['city'] = city ?? '';
      request.fields['full_name'] = fullName ?? '';

      // Add national ID image if provided
      if (nationalIdImage != null) {
        var imageStream = http.ByteStream(nationalIdImage.openRead());
        var imageLength = await nationalIdImage.length();

        var multipartFile = http.MultipartFile(
          'national_id', // Use 'national_id' as the field name
          imageStream,
          imageLength,
          filename: 'national_id_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
        request.headers['x-api-key'] = '1234';
      }

      // Add fields if any
      if (fields != null) {
        Map bodyFields = {};
        for (var i = 0; i < fields.length; i++) {
          if (fields[i].type != 'upload') {
            bodyFields.addEntries({
              fields[i].id: (fields[i].type == 'toggle')
                  ? fields[i].userSelectedData == null
                      ? 0
                      : 1
                  : fields[i].userSelectedData
            }.entries);
          }
        }
        request.fields['fields'] = bodyFields.toString();
      }

      // Send the request
      var streamedResponse = await request.send();
      var res = await http.Response.fromStream(streamedResponse);

      print(res.body);
      print("res after multipart request");

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success'] ||
          jsonResponse['status'] == 'go_step_2' ||
          jsonResponse['status'] == 'go_step_3') {
        print("success => ${jsonResponse['data']['token']}");
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        await AppData.saveName(fullName ?? '');
        return {
          'user_id': jsonResponse['data']['user_id'],
          'step': jsonResponse['status']
        };
      } else {
        showSnackBar(
            ErrorEnum.error, jsonResponse['message'] ?? 'An error occurred');
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }
    } catch (e) {
      print('Error in registerWithEmail: $e');
      return null;
    }
  }

  ///

  static Future<Map?> registerWithPhone(
    String registerMethod,
    String countryCode,
    String mobile,
    String password,
    String repeatPassword,
    String? accountType,
    List<Fields>? fields,
    String? parentPhoneNumber,
    String? city,
  ) async {
    // try{
    String url = '${Constants.baseUrl}register/step/1';

    Map body = {
      "register_method": registerMethod,
      "country_code": countryCode,
      'mobile': mobile,
      'password': password,
      'password_confirmation': repeatPassword,
      'parent_phone_number': parentPhoneNumber,
      'city': city,
    };

    if (fields != null) {
      Map bodyFields = {};
      for (var i = 0; i < fields.length; i++) {
        if (fields[i].type != 'upload') {
          bodyFields.addEntries({
            fields[i].id: (fields[i].type == 'toggle')
                ? fields[i].userSelectedData == null
                    ? 0
                    : 1
                : fields[i].userSelectedData
          }.entries);
        }
      }

      body.addEntries({'fields': bodyFields.toString()}.entries);
    }

    Response res = await httpPost(url, body);

    print(res.body);
    print("res.body Phone");

    var jsonResponse = jsonDecode(res.body);
    if (jsonResponse['success'] ||
        jsonResponse['status'] == 'go_step_2' ||
        jsonResponse['status'] == 'go_step_3') {
      // || stored

      return {
        'user_id': jsonResponse['data']['user_id'],
        'step': jsonResponse['status']
      };
    } else {
      ErrorHandler().showError(ErrorEnum.error, jsonResponse);
      return null;
    }

    // }catch(e){
    //   return null;
    // }
  }

  static Future<bool> forgetPassword(String email) async {
    try {
      String url = '${Constants.baseUrl}forget-password';

      Response res = await httpPost(url, {"email": email});

      log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        ErrorHandler()
            .showError(ErrorEnum.success, jsonResponse, readMessage: true);
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> verifyCode(int userId, String code) async {
    try {
      String url = '${Constants.baseUrl}register/step/2';

      Response res = await httpPost(url, {
        "user_id": userId.toString(),
        "code": code,
      });

      log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> registerStep3(
      int userId, String name, String referralCode) async {
    try {
      String url = '${Constants.baseUrl}register/step/3';

      Response res = await httpPost(url, {
        "user_id": userId.toString(),
        "full_name": name,
        "referral_code": referralCode
      });

      var jsonResponse = jsonDecode(res.body);
      print(jsonResponse);
      print("jsonResponse registerStep3");
      if (jsonResponse['success']) {
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        await AppData.saveName(name);
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
