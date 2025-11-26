/*
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/pages/authentication_page/verify_code_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/web_view_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/services/guest_service/guest_service.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_widget.dart';
import 'package:webinar/app/widgets/authentication_widget/country_code_widget/code_country.dart';
import 'package:webinar/app/widgets/authentication_widget/register_widget/register_widget.dart';
import 'package:webinar/app/widgets/main_widget/main_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/config/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../common/enums/page_name_enum.dart';
import '../../../config/assets.dart';
import '../../../config/colors.dart';
import '../../../common/components.dart';
import '../../../locator.dart';
import '../../providers/page_provider.dart';

class RegisterPage extends StatefulWidget {
  static const String pageName = '/register';
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final List<String> egyptianGovernorates = [
    "القاهرة", "الجيزة", "الإسكندرية", "الدقهلية", "الشرقية", "القليوبية",
    "البحيرة", "الغربية", "المنوفية", "كفر الشيخ", "الفيوم", "بني سويف",
    "المنيا", "أسيوط", "سوهاج", "قنا", "الأقصر", "أسوان", "دمياط", "بورسعيد",
    "الإسماعيلية", "السويس", "شمال سيناء", "جنوب سيناء", "مطروح", "البحر الأحمر",
    "الوادي الجديد"
  ];
  String? selectedCity;

  // TextEditingController firstNameController = TextEditingController();
  // FocusNode firstNameNode = FocusNode();
  TextEditingController nameController = TextEditingController();
  FocusNode nameNode = FocusNode();



  TextEditingController secondNameController = TextEditingController();
  FocusNode secondNameNode = FocusNode();

  TextEditingController thirdNameController = TextEditingController();
  FocusNode thirdNameNode = FocusNode();

  TextEditingController fourthNameController = TextEditingController();
  FocusNode fourthNameNode = FocusNode();

  TextEditingController mailController = TextEditingController();
  FocusNode mailNode = FocusNode();
  TextEditingController phoneController = TextEditingController();
  FocusNode phoneNode = FocusNode();
  TextEditingController parentPhoneNumberController = TextEditingController();
  FocusNode parentPhoneNumberNode = FocusNode();
  
  TextEditingController cityController = TextEditingController();
  FocusNode cityNode = FocusNode();

  TextEditingController passwordController = TextEditingController();

  FocusNode passwordNode = FocusNode();
  TextEditingController retypePasswordController = TextEditingController();
  FocusNode retypePasswordNode = FocusNode();

  bool isEmptyInputs=true;
  bool isPhoneNumber=false;
  bool isSendingData=false;


  CountryCode countryCode = CountryCode(
    code: "US",
    dialCode: "+1",
    flagUri: "${AppAssets.flags}en.png",
    name: "United States"
  );

  // user
  // teacher
  // organization
  String accountType = 'user';
  bool isLoadingAccountType = false;

  String? otherRegisterMethod;
  RegisterConfigModel? registerConfig;

  List<dynamic> selectRolesDuringRegistration = [];

  @override
  void initState() {
    
    super.initState();

    if(PublicData.apiConfigData['selectRolesDuringRegistration'] != null){
      selectRolesDuringRegistration = ((PublicData.apiConfigData['selectRolesDuringRegistration']) as List<dynamic>).toList();
    }

    if((PublicData.apiConfigData?['register_method'] ?? '') == 'email'){
      isPhoneNumber = false;
      otherRegisterMethod = 'email';
    }else{
      isPhoneNumber = true;
      otherRegisterMethod = 'phone';
    }



    nameController.addListener(() {
      if( (nameController.text.trim().isNotEmpty || mailController.text.trim().isNotEmpty || phoneController.text.trim().isNotEmpty) && passwordController.text.trim().isNotEmpty && retypePasswordController.text.trim().isNotEmpty){
        if(isEmptyInputs){
          isEmptyInputs = false;
          setState(() {});
        }
      }else{
        if(!isEmptyInputs){
          isEmptyInputs = true;
          setState(() {});
        }
      }
    });

        secondNameController.addListener(() {
      if( (secondNameController.text.trim().isNotEmpty || nameController.text.trim().isNotEmpty || mailController.text.trim().isNotEmpty || phoneController.text.trim().isNotEmpty) && passwordController.text.trim().isNotEmpty && retypePasswordController.text.trim().isNotEmpty){
        if(isEmptyInputs){
          isEmptyInputs = false;
          setState(() {});
        }
      }else{
        if(!isEmptyInputs){
          isEmptyInputs = true;
          setState(() {});
        }
      }
    });

    thirdNameController.addListener(() {
      if( (thirdNameController.text.trim().isNotEmpty || secondNameController.text.trim().isNotEmpty || nameController.text.trim().isNotEmpty || mailController.text.trim().isNotEmpty || phoneController.text.trim().isNotEmpty) && passwordController.text.trim().isNotEmpty && retypePasswordController.text.trim().isNotEmpty){
        if(isEmptyInputs){
          isEmptyInputs = false;
          setState(() {});
        }
      }else{
        if(!isEmptyInputs){
          isEmptyInputs = true;
          setState(() {});
        }
      }
    });

        fourthNameController.addListener(() {
      if( (fourthNameController.text.trim().isNotEmpty || thirdNameController.text.trim().isNotEmpty || secondNameController.text.trim().isNotEmpty || nameController.text.trim().isNotEmpty || mailController.text.trim().isNotEmpty || phoneController.text.trim().isNotEmpty) && passwordController.text.trim().isNotEmpty && retypePasswordController.text.trim().isNotEmpty){
        if(isEmptyInputs){
          isEmptyInputs = false;
          setState(() {});
        }
      }else{
        if(!isEmptyInputs){
          isEmptyInputs = true;
          setState(() {});
        }
      }
    });


    mailController.addListener(() {
      if( (fourthNameController.text.trim().isNotEmpty || thirdNameController.text.trim().isNotEmpty || secondNameController.text.trim().isNotEmpty || nameController.text.trim().isNotEmpty || mailController.text.trim().isNotEmpty || phoneController.text.trim().isNotEmpty) && passwordController.text.trim().isNotEmpty && retypePasswordController.text.trim().isNotEmpty){
        if(isEmptyInputs){
          isEmptyInputs = false;
          setState(() {});
        }
      }else{
        if(!isEmptyInputs){
          isEmptyInputs = true;
          setState(() {});
        }
      }
    });

    phoneController.addListener(() {
      if( (fourthNameController.text.trim().isNotEmpty || thirdNameController.text.trim().isNotEmpty || secondNameController.text.trim().isNotEmpty || nameController.text.trim().isNotEmpty || mailController.text.trim().isNotEmpty || phoneController.text.trim().isNotEmpty) && passwordController.text.trim().isNotEmpty && retypePasswordController.text.trim().isNotEmpty){
        if(isEmptyInputs){
          isEmptyInputs = false;
          setState(() {});
        }
      }else{
        if(!isEmptyInputs){
          isEmptyInputs = true;
          setState(() {});
        }
      }
    });

    passwordController.addListener(() {
      if( (fourthNameController.text.trim().isNotEmpty || thirdNameController.text.trim().isNotEmpty || secondNameController.text.trim().isNotEmpty || nameController.text.trim().isNotEmpty || mailController.text.trim().isNotEmpty || phoneController.text.trim().isNotEmpty) && passwordController.text.trim().isNotEmpty && retypePasswordController.text.trim().isNotEmpty){
        if(isEmptyInputs){
          isEmptyInputs = false;
          setState(() {});
        }
      }else{
        if(!isEmptyInputs){
          isEmptyInputs = true;
          setState(() {});
        }
      }
    });

    retypePasswordController.addListener(() {
      if( (fourthNameController.text.trim().isNotEmpty || thirdNameController.text.trim().isNotEmpty || secondNameController.text.trim().isNotEmpty || nameController.text.trim().isNotEmpty || mailController.text.trim().isNotEmpty || phoneController.text.trim().isNotEmpty) && passwordController.text.trim().isNotEmpty && retypePasswordController.text.trim().isNotEmpty){
        if(isEmptyInputs){
          isEmptyInputs = false;
          setState(() {});
        }
      }else{
        if(!isEmptyInputs){
          isEmptyInputs = true;
          setState(() {});
        }
      }
    });
    
    getAccountTypeFileds();

  }

  
  getAccountTypeFileds() async {
    
    setState(() {
      isLoadingAccountType = true;
    });

    registerConfig = await GuestService.registerConfig(accountType);

    setState(() {
      isLoadingAccountType = false;
    });
  }


  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      onPopInvoked: (re){
        MainWidget.showExitDialog();
      },
      child: directionality(
        child: Scaffold(
          backgroundColor: const Color(0xFF191026),
          body: Stack(
            children: [
      
              Positioned.fill(
                child: Image.asset(
                  AppAssets.introBgPng,
                  width: getSize().width,
                  height: getSize().height,
                  fit: BoxFit.cover,
                )
              ),

      
      
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: padding(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
      
                      space(getSize().height * .11),
      
                      // title
                      Row(
                        children: [
      
                          Text(
                            appText.createAccount,
                            style: style24Bold(),
                          ),
      
                          space(0,width: 4),
      
                          SvgPicture.asset(AppAssets.emoji2Svg)
                        ],
                      ),
      
                      // desc
                      Text(
                        appText.createAccountDesc,
                        style: style14Regular().copyWith(color: greyA5),
                      ),
      
                      space(50),
      
                      // google and facebook
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //
                      //     if(registerConfig?.showGoogleLoginButton ?? false)...{
                      //
                      //       socialWidget(AppAssets.googleSvg, () async {
                      //
                      //         final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
                      //         final GoogleSignInAuthentication gAuth = await gUser!.authentication;
                      //
                      //
                      //         if(gAuth.accessToken != null){
                      //
                      //           setState(() {
                      //             isSendingData = true;
                      //           });
                      //
                      //           try{
                      //             bool res = await AuthenticationService.google(
                      //               gUser.email,
                      //               gAuth.accessToken ?? '',
                      //               gUser.displayName ?? ''
                      //             );
                      //
                      //             if(res){
                      //               nextRoute(MainPage.pageName,isClearBackRoutes: true);
                      //             }
                      //           }catch(_){}
                      //
                      //           setState(() {
                      //             isSendingData = false;
                      //           });
                      //
                      //
                      //         }
                      //
                      //       }),
                      //
                      //       space(0,width: 20),
                      //     },
                      //
                      //     if(registerConfig?.showFacebookLoginButton ?? false)...{
                      //       socialWidget(AppAssets.facebookSvg, () async {
                      //         try{
                      //           final LoginResult result = await FacebookAuth.instance.login(permissions: ['email']);
                      //
                      //           if (result.status == LoginStatus.success) {
                      //             final AccessToken accessToken = result.accessToken!;
                      //
                      //             setState(() {
                      //               isSendingData = true;
                      //             });
                      //
                      //             FacebookAuth.instance.getUserData().then((value) async {
                      //
                      //               String email = value['email'];
                      //               String name = value['name'] ?? '';
                      //
                      //               try{
                      //                 bool res = await AuthenticationService.facebook(email, accessToken.tokenString, name);
                      //
                      //                 if(res){
                      //                   nextRoute(MainPage.pageName,isClearBackRoutes: true);
                      //                 }
                      //               }catch(_){}
                      //
                      //               setState(() {
                      //                 isSendingData = false;
                      //               });
                      //             });
                      //
                      //           } else {}
                      //         }catch(_){}
                      //       }),
                      //
                      //     }
                      //   ],
                      // ),
      
                      // space(24),


                      // account types
                      // Text(
                      //   appText.accountType,
                      //   style: style14Regular().copyWith(color: greyB2),
                      // ),
                      //
                      // space(8),
      
                      // // account types
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: borderRadius()
                      //   ),
                      //
                      //   width: getSize().width,
                      //   height:  52,
                      //
                      //   child: Row(
                      //     children: [
                      //
                      //       // student
                      //       AuthWidget.accountTypeWidget(appText.student, accountType, PublicData.userRole, (){
                      //         setState(() {
                      //           accountType = PublicData.userRole;
                      //         });
                      //         getAccountTypeFileds();
                      //       }),
                      //
                      //
                      //
                      //       // instructor
                      //       if(selectRolesDuringRegistration.contains(PublicData.teacherRole))...{
                      //         AuthWidget.accountTypeWidget(appText.instrcutor, accountType, PublicData.teacherRole, (){
                      //           setState(() {
                      //             accountType = PublicData.teacherRole;
                      //           });
                      //           getAccountTypeFileds();
                      //         }),
                      //       },
                      //
                      //
                      //       // organization
                      //       if(selectRolesDuringRegistration.contains(PublicData.organizationRole))...{
                      //         AuthWidget.accountTypeWidget(appText.organization, accountType, PublicData.organizationRole, (){
                      //           setState(() {
                      //             accountType = PublicData.organizationRole;
                      //           });
                      //           getAccountTypeFileds();
                      //         }),
                      //       }
                      //
                      //
                      //     ],
                      //   ),
                      // ),
                      
      
                      // Other Register Method
                      // if(registerConfig?.showOtherRegisterMethod != null)...{
                      //   space(15),
                      //
                      //   Container(
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: borderRadius()
                      //     ),
                      //
                      //     width: getSize().width,
                      //     height:  52,
                      //
                      //     child: Row(
                      //       children: [
                      //
                      //         // email
                      //         AuthWidget.accountTypeWidget(appText.email, otherRegisterMethod ?? '', 'email', (){
                      //           setState(() {
                      //             otherRegisterMethod = 'email';
                      //             isPhoneNumber = false;
                      //           });
                      //         }),
                      //
                      //         // phone
                      //         // AuthWidget.accountTypeWidget(appText.phone, otherRegisterMethod ?? '', 'phone', (){
                      //
                      //         //   setState(() {
                      //         //     registerConfig?.registerMethod = 'mobile';
                      //         //     otherRegisterMethod = 'phone';
                      //         //     isPhoneNumber = true;
                      //         //   });
                      //         // }),
                      //
                      //       ],
                      //     )
                      //   )
                      // },
      
                      space(13),

                      input(nameController, nameNode, appText.name, iconPathLeft: AppAssets.passwordSvg,leftIconSize: 14,isPassword: false),
                      space(16),
                      input(secondNameController, secondNameNode, appText.secondName, iconPathLeft: AppAssets.passwordSvg,leftIconSize: 14,isPassword: false),
                      space(16),
                      input(thirdNameController, thirdNameNode, appText.thirdName, iconPathLeft: AppAssets.passwordSvg,leftIconSize: 14,isPassword: false),
                      space(16),
                      input(fourthNameController, fourthNameNode, appText.fourthName, iconPathLeft: AppAssets.passwordSvg,leftIconSize: 14,isPassword: false),
                      space(5),
                      Text(
                        appText.nameNote,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black45, // لون مستوحى من واتساب
                        ),
                        // textDirection: TextDirection.rtl, // لضبط الاتجاه من اليمين لليسار
                      ),
                      space(16),


                      Row(
                        children: [

                          // // country code
                          // GestureDetector(
                          //   onTap: () async {
                          //     CountryCode? newData = await RegisterWidget.showCountryDialog();
                          //
                          //     if(newData != null){
                          //       countryCode = newData;
                          //       setState(() {});
                          //     }
                          //   },
                          //   behavior: HitTestBehavior.opaque,
                          //   child: Container(
                          //     width: 52,
                          //     height: 52,
                          //     decoration: BoxDecoration(
                          //         color: Colors.white,
                          //         borderRadius: borderRadius()
                          //     ),
                          //     alignment: Alignment.center,
                          //     child: ClipRRect(
                          //       borderRadius: borderRadius(radius: 50),
                          //       child: Image.asset(
                          //         countryCode.flagUri ?? '',
                          //         width: 21,
                          //         height: 19,
                          //         fit: BoxFit.cover,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          //
                          // space(0,width: 15),

                          Expanded(child: input(phoneController, phoneNode, appText.phoneNumber))
                        ],
                      ),
                      space(4),
                      Text(
                        appText.phoneNumberNote,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black45, // لون مستوحى من واتساب
                        ),
                        // textDirection: TextDirection.rtl, // لضبط الاتجاه من اليمين لليسار
                      ),

                      space(16),
                      Row(
                        children: [

                          // country code
                          // GestureDetector(
                          //   onTap: () async {
                          //     CountryCode? newData = await RegisterWidget.showCountryDialog();
                          //
                          //     if(newData != null){
                          //       countryCode = newData;
                          //       setState(() {});
                          //     }
                          //   },
                          //   behavior: HitTestBehavior.opaque,
                          //   child: Container(
                          //     width: 52,
                          //     height: 52,
                          //     decoration: BoxDecoration(
                          //         color: Colors.white,
                          //         borderRadius: borderRadius()
                          //     ),
                          //     alignment: Alignment.center,
                          //     child: ClipRRect(
                          //       borderRadius: borderRadius(radius: 50),
                          //       child: Image.asset(
                          //         countryCode.flagUri ?? '',
                          //         width: 21,
                          //         height: 19,
                          //         fit: BoxFit.cover,
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          // space(0,width: 15),

                          Expanded(child: input(parentPhoneNumberController, parentPhoneNumberNode, appText.parentPhoneNumber))
                        ],
                      ),

                      // if(isPhoneNumber)...{
                      //
                      //   Row(
                      //     children: [
                      //
                      //       // country code
                      //       GestureDetector(
                      //         onTap: () async {
                      //           CountryCode? newData = await RegisterWidget.showCountryDialog();
                      //
                      //           if(newData != null){
                      //             countryCode = newData;
                      //             setState(() {});
                      //           }
                      //         },
                      //         behavior: HitTestBehavior.opaque,
                      //         child: Container(
                      //           width: 52,
                      //           height: 52,
                      //           decoration: BoxDecoration(
                      //             color: Colors.white,
                      //             borderRadius: borderRadius()
                      //           ),
                      //           alignment: Alignment.center,
                      //           child: ClipRRect(
                      //             borderRadius: borderRadius(radius: 50),
                      //             child: Image.asset(
                      //               countryCode.flagUri ?? '',
                      //               width: 21,
                      //               height: 19,
                      //               fit: BoxFit.cover,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //
                      //       space(0,width: 15),
                      //
                      //       Expanded(child: input(phoneController, phoneNode, appText.phoneNumber))
                      //     ],
                      //   ),
                      //   space(4),
                      //   Text(
                      //     appText.phoneNumberNote,
                      //     style: TextStyle(
                      //       fontSize: 12,
                      //       fontWeight: FontWeight.bold,
                      //       color: Colors.black45, // لون مستوحى من واتساب
                      //     ),
                      //     // textDirection: TextDirection.rtl, // لضبط الاتجاه من اليمين لليسار
                      //   )
                      //
                      // }else...{
                      //   input(mailController, mailNode, appText.yourEmail, iconPathLeft: AppAssets.mailSvg,leftIconSize: 14),
                      // },
      
                      space(16),
                      
                      // input(cityController, cityNode, appText.city, iconPathLeft: AppAssets.passwordSvg,leftIconSize: 14,isPassword: false),

DropdownButtonFormField<String>(
  value: selectedCity,
  decoration: InputDecoration(
    labelText: appText.city,
    labelStyle: TextStyle(
      color: Theme.of(context).colorScheme.surface,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.secondary,
        width: 2,
      ),
    ),
    prefixIcon: Padding(
      padding: const EdgeInsets.all(10),
      child: SvgPicture.asset(
        AppAssets.passwordSvg,
        width: 14,
        color: Theme.of(context).iconTheme.color,
      ),
    ),
  ),
  dropdownColor: Theme.of(context).cardColor,
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    color: Theme.of(context).colorScheme.onSurface,
  ),
  iconEnabledColor: Theme.of(context).iconTheme.color,
  items: egyptianGovernorates.map((String city) {
    return DropdownMenuItem<String>(
      value: city,
      child: Text(
        city,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: greyA5,
        ),
      ),
    );
  }).toList(),
  onChanged: (String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedCity = newValue;
      });
    }
  },
)
,
                      space(16),

                      input(passwordController, passwordNode, appText.password, iconPathLeft: AppAssets.passwordSvg,leftIconSize: 14,isPassword: true),

                      space(16),
                      
                      input(retypePasswordController, retypePasswordNode, appText.retypePassword, iconPathLeft: AppAssets.passwordSvg,leftIconSize: 14,isPassword: true),
      
      
                      isLoadingAccountType
                    ? loading()
                    : Column(
                        children: [
                          
                          ...List.generate(registerConfig?.formFields?.fields?.length ?? 0, (index) {
                            return registerConfig?.formFields?.fields?[index].getWidget() ?? const SizedBox();
                          })
                        ],
                      ),
      
                      space(32),
      
                      Center(
                        child: button(
                          onTap: () async {
                            
                            if(!isEmptyInputs){

                                  if (nameController.text.trim().isEmpty) {
      showSnackBar(ErrorEnum.alert, 'يرجى إدخال الاسم الأول');
      return;
    }
    if (secondNameController.text.trim().isEmpty) {
      showSnackBar(ErrorEnum.alert, 'يرجى إدخال الاسم الثاني');
      return;
    }
    if (thirdNameController.text.trim().isEmpty) {
      showSnackBar(ErrorEnum.alert, 'يرجى إدخال الاسم الثالث');
      return;
    }
    if (fourthNameController.text.trim().isEmpty) {
      showSnackBar(ErrorEnum.alert, 'يرجى إدخال الاسم الرابع');
      return;
    }

                              
      
                              if(registerConfig?.formFields?.fields != null){
                                for (var i = 0; i < (registerConfig?.formFields?.fields?.length ?? 0); i++) {
                                  if(registerConfig?.formFields?.fields?[i].isRequired == 1 && registerConfig?.formFields?.fields?[i].userSelectedData == null){
      
                                    if(registerConfig?.formFields?.fields?[i].type != 'toggle'){
                                      
                                      showSnackBar(ErrorEnum.alert, '${appText.pleaseReview} ${registerConfig?.formFields?.fields?[i].getTitle()}');
                                      return;
                                    }
                                    
                                  }
                                }
                              }
      
      
                              if(passwordController.text.trim().compareTo(retypePasswordController.text.trim()) == 0 ){
      
                                setState(() {
                                  isSendingData = true;
                                });
                                
                                if(registerConfig?.registerMethod == 'email'){
                                  Map? res = await AuthenticationService.registerWithEmail( // email
                                    registerConfig?.registerMethod ?? '',
                                    mailController.text.trim(), 
                                    passwordController.text.trim(), 
                                    retypePasswordController.text.trim(),
                                    accountType,
                                    registerConfig?.formFields?.fields,
                                    // countryCode.dialCode.toString(),
                                    phoneController.text.trim(),
                                    parentPhoneNumberController.text.trim(),
                                    // cityController.text.trim(),
                                      selectedCity?.trim(),
                                      nameController.text.trim() + secondNameController.text.trim() + thirdNameController.text.trim() + fourthNameController.text.trim(),

                            );
      
                                  
                                  if(res != null){
      
                                    if(res['step'] == 'stored' || res['step'] == 'go_step_2'){
                                           locator<PageProvider>().setPage(PageNames.home);

                                      nextRoute(MainPage.pageName, arguments: res['user_id']);

                                      // nextRoute(VerifyCodePage.pageName, arguments: {
                                      //   'user_id' : res['user_id'],
                                      //   'email': mailController.text.trim(),
                                      //   'password': passwordController.text.trim(),
                                      //   'retypePassword': retypePasswordController.text.trim(),
                                      //   "fields":registerConfig?.formFields?.fields,
                                      //   "mobile":registerConfig?.formFields?.fields,
                                      //   "parentPhoneNumber":registerConfig?.formFields?.fields,
                                      //   "city":registerConfig?.formFields?.fields,
                                      //   "fullName": nameController.text.trim() + ' '+ secondNameController.text.trim() + ' '+ thirdNameController.text.trim() + ' '+ fourthNameController.text.trim(),
                                      // });
                                      // locator<PageProvider>().setPage(PageNames.home);
                                      // nextRoute(MainPage.pageName, arguments: res['user_id']);
                                    }
                                    else if(res['step'] == 'go_step_3'){
                                      nextRoute(MainPage.pageName, arguments: res['user_id']);
                                    }else{
                                     nextRoute(MainPage.pageName, arguments: res['user_id']);

                                    }
                                  }
      
                                }
                                else{

                                  Map? res = await AuthenticationService.registerWithEmail( // email
                                    registerConfig?.registerMethod ?? '',
                                    mailController.text.trim(),
                                    passwordController.text.trim(),
                                    retypePasswordController.text.trim(),
                                    accountType,
                                    registerConfig?.formFields?.fields,
                                    // countryCode.dialCode.toString(),
                                    phoneController.text.trim(),
                                    parentPhoneNumberController.text.trim(),
                                      selectedCity?.trim(),
                                    nameController.text.trim() + ' '+ secondNameController.text.trim() + ' '+ thirdNameController.text.trim() + ' '+ fourthNameController.text.trim(),
                                  );
                                  // Map? res = await AuthenticationService.registerWithPhone( // mobile
                                  //   registerConfig?.registerMethod ?? '',
                                  //   countryCode.dialCode.toString(),
                                  //   phoneController.text.trim(),
                                  //   passwordController.text.trim(),
                                  //   retypePasswordController.text.trim(),
                                  //   accountType,
                                  //   registerConfig?.formFields?.fields
                                  // );

                                  if(res != null){

                                    if(res['step'] == 'stored' || res['step'] == 'go_step_2'){
                                      // locator<PageProvider>().setPage(PageNames.home);
                                      // nextRoute(MainPage.pageName, arguments: res['user_id']);

                                      // nextRoute(VerifyCodePage.pageName, arguments: {
                                      //   'user_id' : res['user_id'],
                                      //   'countryCode': countryCode.dialCode.toString(),
                                      //   'phone': phoneController.text.trim(),
                                      //   'password': passwordController.text.trim(),
                                      //   'retypePassword': retypePasswordController.text.trim(),
                                      //   "fullName":nameController.text.trim() + ' '+ secondNameController.text.trim() + ' '+ thirdNameController.text.trim() + ' '+ fourthNameController.text.trim(),
                                      //   'parentPhoneNumber': parentPhoneNumberController.text.trim(),
                                      //   'city': selectedCity?.trim()
                                      // });
                                      locator<PageProvider>().setPage(PageNames.home);

                                      nextRoute(MainPage.pageName, arguments: res['user_id']);

                                    }else if(res['step'] == 'go_step_3'){
                                      locator<PageProvider>().setPage(PageNames.home);
                                      nextRoute(MainPage.pageName, arguments: res['user_id']);
                                    }else{
                                     nextRoute(MainPage.pageName, arguments: res['user_id']);

                                    }
                                  }
                                }
                        
                                setState(() {
                                  isSendingData = false;
                                });
                              }
                      
                            }
      
                          }, 
                          width: getSize().width, 
                          height: 52, 
                          text: appText.createAnAccount, 
                          bgColor: isEmptyInputs ? greyCF : mainColor(),
                          textColor: Colors.white, 
                          borderColor: Colors.transparent,
                          isLoading: isSendingData
                        ),
                      ),
      
                      space(16),
      
                      // termsPoliciesDesc
                      Center(
                        child: GestureDetector(
                          onTap: (){
                            nextRoute(WebViewPage.pageName, arguments: ['${Constants.dommain}/pages/app-terms', appText.webinar, false, LoadRequestMethod.get]);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            appText.termsPoliciesDesc,
                            style: style14Regular().copyWith(color: greyA5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
      
                      space(80),
      
                      // haveAnAccount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appText.haveAnAccount,
                            style: style16Regular(),
                          ),
      
                          space(0,width: 2),
      
                          GestureDetector(
                            onTap: (){
                              nextRoute(LoginPage.pageName, isClearBackRoutes: true);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Text(
                              appText.login,
                              style: style16Regular(),
                            ),
                          )
                        ],
                      ),
      
                      space(25),
      
      
                    ],
                  ),
                )
              )
            ],
          ),
        )
      ),
    );
  }


  


  Widget socialWidget(String icon,Function onTap){
    return GestureDetector(
      onTap: (){
        onTap();
      },
      child: Container(
        width: 98,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius(radius: 16),
        ),

        child: SvgPicture.asset(icon,width: 30,),
      ),
    );
  }


}
*/
