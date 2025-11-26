import 'package:flutter/material.dart';

class Constants {
  
  static const dommain = 'https://eslam-elsaidy.com';
  // static const dommain = 'https://appmrdoctor.anmka.com';
  // static const dommain = 'https://app.rocket-soft.org';
  static const baseUrl = '$dommain/api/development/';

  // static const baseUrl = '$dommain/api/';
  static const apiKey = '1234';
  static const scheme = 'academyapp';
  
  static final RouteObserver<ModalRoute<void>> singleCourseRouteObserver = RouteObserver<ModalRoute<void>>();
  static final RouteObserver<ModalRoute<void>> contentRouteObserver = RouteObserver<ModalRoute<void>>();

}

