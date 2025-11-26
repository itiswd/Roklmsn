import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';

class IntroPage extends StatefulWidget {
  static const String pageName = '/intro';
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {


  PageController pageController = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    AppData.saveIsFirst(false);
  }

  @override
  Widget build(BuildContext context) {
    
    return directionality(
      child: Scaffold(
          backgroundColor: const Color(0xFF402a6c),
          body: Stack(
          children: [

            Positioned.fill(
              child: PageView(
                controller: pageController,
                onPageChanged: (i){
                  setState(() {
                    currentPage = i;
                  });
                },
                physics: const CustomPageViewScrollPhysics(),
                children: [

                  _buildImagePage(AppAssets.rkt1Png),
 
                  _buildImagePage(AppAssets.rkt2Png),
 
                  _buildImagePage(AppAssets.rkt3Png),
 
                  _buildImagePage(AppAssets.rkt4Png),

                ],
              )
            ),

            Positioned(
              bottom: 20,
              right: 30,
              left: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  GestureDetector(
                    onTap: (){
                      nextRoute(MainPage.pageName, isClearBackRoutes: true);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      appText.skip,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // indecator
                  Row(
                    children: List.generate(4, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: padding(horizontal: 1.5),
                        width: 6,
                        height: 6,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentPage == index ? mainColor() : greyA5.withOpacity(.5)
                        ),
                      );
                    }),
                  ),

                  GestureDetector(
                    onTap: (){

                      if(currentPage == 3){
                        nextRoute(MainPage.pageName, isClearBackRoutes: true);
                      }else{
                        pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.linearToEaseOut);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      appText.next,
                       style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                ],
              )
            ),
          ],
        )
      )
    );
  }

  Widget _buildImagePage(String imagePath) {
    return Center(
      child: Image.asset(
        imagePath,
        width: 300,
        height: 300,
        fit: BoxFit.contain,
      ),
    );
  }
}