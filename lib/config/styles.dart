import 'package:flutter/material.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/locator.dart';

TextStyle style48Bold() {
  return TextStyle(
    fontFamily: !locator<AppLanguage>().isRtl() ? 'Kufam-Regular' : 'Kufam-Regular',
    color: grey33,
    fontSize: 48
  );
}
TextStyle style24Bold() => style48Bold().copyWith(fontSize: 24);
TextStyle style22Bold() => style48Bold().copyWith(fontSize: 22);
TextStyle style20Bold() => style48Bold().copyWith(fontSize: 20);
TextStyle style16Bold() => style48Bold().copyWith(fontSize: 16);
TextStyle style13Bold() => style48Bold().copyWith(fontSize: 13);
TextStyle style14Bold() => style48Bold().copyWith(fontSize: 14);
TextStyle style12Bold() => style48Bold().copyWith(fontSize: 12);



TextStyle style16Regular() {
  return TextStyle(
    fontFamily: !locator<AppLanguage>().isRtl() ? 'Kufam-Regular' : 'Kufam-Regular',
    color: grey33,
    fontSize: 16
  );
}

TextStyle style16RegularKufam() {
  return TextStyle(
      fontFamily: !locator<AppLanguage>().isRtl() ? 'Kufam-Regular' : 'Kufam-Regular',
      color: grey33,
      fontSize: 16
  );
}

TextStyle style16RegularSora() {
  return TextStyle(
      fontFamily: !locator<AppLanguage>().isRtl()
          ? 'Sora-Regular'
          : 'Sora-Regular',
      color: grey33,
      fontSize: 16
  );
}

TextStyle style14Regular() => style16RegularKufam().copyWith(fontSize: 14);
TextStyle style14RegularKufam() => style16RegularKufam().copyWith(fontSize: 14);
TextStyle style14RegularSora() => style16RegularSora().copyWith(fontSize: 14);
TextStyle style12Regular() => style16RegularKufam().copyWith(fontSize: 12);
TextStyle style10Regular() => style16RegularKufam().copyWith(fontSize: 10);
TextStyle style10RegularKufam() => style16RegularKufam().copyWith(fontSize: 10);




//
// import 'package:flutter/material.dart';
// import 'package:webinar/common/data/app_language.dart';
// import 'package:webinar/locator.dart';
//
// // Bold Text Styles
// TextStyle style48Bold(BuildContext context) {
//   return TextStyle(
//     fontFamily: !locator<AppLanguage>().isRtl() ? 'Kufam-Regular' : 'Kufam-Regular',
//     color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
//     fontSize: 48,
//     fontWeight: FontWeight.bold,
//   );
// }
//
// TextStyle style24Bold(BuildContext context) => style48Bold(context).copyWith(fontSize: 24);
// TextStyle style22Bold(BuildContext context) => style48Bold(context).copyWith(fontSize: 22);
// TextStyle style20Bold(BuildContext context) => style48Bold(context).copyWith(fontSize: 20);
// TextStyle style16Bold(BuildContext context) => style48Bold(context).copyWith(fontSize: 16);
// TextStyle style14Bold(BuildContext context) => style48Bold(context).copyWith(fontSize: 14);
// TextStyle style13Bold(BuildContext context) => style48Bold(context).copyWith(fontSize: 13);
// TextStyle style12Bold(BuildContext context) => style48Bold(context).copyWith(fontSize: 12);
//
// // Regular Text Styles
// TextStyle style16Regular(BuildContext context) {
//   return TextStyle(
//     fontFamily: !locator<AppLanguage>().isRtl() ? 'Kufam-Regular' : 'Kufam-Regular',
//     color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
//     fontSize: 16,
//   );
// }
//
// TextStyle style16RegularKufam(BuildContext context) {
//   return TextStyle(
//     fontFamily: !locator<AppLanguage>().isRtl() ? 'Kufam-Regular' : 'Kufam-Regular',
//     color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
//     fontSize: 16,
//   );
// }
//
// TextStyle style16RegularSora(BuildContext context) {
//   return TextStyle(
//     fontFamily: !locator<AppLanguage>().isRtl() ? 'Sora-Regular' : 'Sora-Regular',
//     color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
//     fontSize: 16,
//   );
// }
//
// // Derived Regular Styles
// TextStyle style14Regular(BuildContext context) => style16RegularKufam(context).copyWith(fontSize: 14);
// TextStyle style14RegularKufam(BuildContext context) => style16RegularKufam(context).copyWith(fontSize: 14);
// TextStyle style14RegularSora(BuildContext context) => style16RegularSora(context).copyWith(fontSize: 14);
// TextStyle style12Regular(BuildContext context) => style16RegularKufam(context).copyWith(fontSize: 12);
// TextStyle style10Regular(BuildContext context) => style16RegularKufam(context).copyWith(fontSize: 10);
// TextStyle style10RegularKufam(BuildContext context) => style16RegularKufam(context).copyWith(fontSize: 10);