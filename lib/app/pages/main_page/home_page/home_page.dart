import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/home_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/utils/app_text.dart';

import '../../../models/category_model.dart';
import '../../../models/course_model.dart';
import '../../../providers/app_language_provider.dart';
import '../../../services/guest_service/categories_service.dart';
import '../categories_page/categories_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String token = '';
  String name = '';

  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();

  late AnimationController appBarController;
  late Animation<double> appBarAnimation;

  double appBarHeight = 230;

  ScrollController scrollController = ScrollController();

  PageController sliderPageController = PageController();
  int currentSliderIndex = 0;

  PageController adSliderPageController = PageController();
  int currentAdSliderIndex = 0;

  bool isLoadingFeaturedListData = false;
  List<CourseModel> featuredListData = [];

  bool isLoadingNewsetListData = false;
  List<CourseModel> newsetListData = [];

  bool isLoadingBestRatedListData = false;
  List<CourseModel> bestRatedListData = [];

  bool isLoadingBestSellingListData = false;
  List<CourseModel> bestSellingListData = [];

  bool isLoadingDiscountListData = false;
  List<CourseModel> discountListData = [];

  bool isLoadingFreeListData = false;
  List<CourseModel> freeListData = [];

  bool isLoadingBundleData = false;
  List<CourseModel> bundleData = [];

  final List<String> bannerImages = [
    'assets/image/png/banner2.jpeg',
    'assets/image/png/banner1.jpeg',
    'assets/image/png/banner3.jpg',
  ];

  @override
  void initState() {
    super.initState();

    getToken();

    appBarController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    appBarAnimation = Tween<double>(
      begin: 150 + MediaQuery.of(navigatorKey.currentContext!).viewPadding.top,
      end: 80 + MediaQuery.of(navigatorKey.currentContext!).viewPadding.top,
    ).animate(appBarController);

    _setupScrollController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        if (AppData.canShowFinalizeSheet) {
          AppData.canShowFinalizeSheet = false;
        }
      }
    });

    getData();
  }

  void _setupScrollController() {
    scrollController.addListener(() {
      // App bar animation logic
      if (scrollController.position.pixels > 100) {
        if (!appBarController.isAnimating) {
          if (appBarController.status == AnimationStatus.dismissed) {
            appBarController.forward();
          }
        }
      } else if (scrollController.position.pixels < 50) {
        if (!appBarController.isAnimating) {
          if (appBarController.status == AnimationStatus.completed) {
            appBarController.reverse();
          }
        }
      }

      // Prevent over-scrolling at the bottom
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        // Optional: Add haptic feedback or load more data here
        // HapticFeedback.lightImpact();
        print("Reached bottom of list");
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    searchNode.dispose();
    appBarController.dispose();
    sliderPageController.dispose();
    adSliderPageController.dispose();
    super.dispose();
  }

  bool isLoading = true;

  getData() {
    isLoadingFeaturedListData = true;
    isLoadingNewsetListData = true;
    isLoadingBundleData = true;
    isLoadingBestRatedListData = true;
    isLoadingBestSellingListData = true;
    isLoadingDiscountListData = true;
    isLoadingFreeListData = true;
    isLoading = true;

    CourseService.featuredCourse().then((value) {
      if (mounted) {
        setState(() {
          isLoadingFeaturedListData = false;
          featuredListData = value;
        });
      }
    });

    CourseService.getAll(offset: 0, bundle: true).then((value) {
      if (mounted) {
        setState(() {
          isLoadingBundleData = false;
          bundleData = value;
        });
      }
    });

    CourseService.getAll(offset: 0, sort: 'newest').then((value) {
      if (mounted) {
        setState(() {
          isLoadingNewsetListData = false;
          newsetListData = value;
        });
      }
    });

    CourseService.getAll(offset: 0, sort: 'best_rates').then((value) {
      if (mounted) {
        setState(() {
          isLoadingBestRatedListData = false;
          bestRatedListData = value;
        });
      }
    });

    CourseService.getAll(offset: 0, sort: 'bestsellers').then((value) {
      if (mounted) {
        setState(() {
          isLoadingBestSellingListData = false;
          bestSellingListData = value;
        });
      }
    });

    CourseService.getAll(offset: 0, discount: true).then((value) {
      if (mounted) {
        setState(() {
          isLoadingDiscountListData = false;
          discountListData = value;
        });
      }
    });

    CourseService.getAll(offset: 0, free: true).then((value) {
      if (mounted) {
        setState(() {
          isLoadingFreeListData = false;
          freeListData = value;
        });
      }
    });

    CategoriesService.trendCategories().then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
          trendCategories = value;
        });
      }
    });
  }

  getToken() async {
    AppData.getAccessToken().then((value) {
      if (mounted) {
        setState(() {
          token = value;
        });

        if (token.isNotEmpty) {
          UserService.getProfile().then((value) async {
            if (value != null && mounted) {
              await AppData.saveName(value.fullName ?? '');
              getUserName();
            }
          });
        }
      }
    });

    getUserName();
  }

  getUserName() {
    AppData.getName().then((value) {
      if (mounted) {
        setState(() {
          name = value;
        });
      }
    });
  }

  List<CategoryModel> trendCategories = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguageProvider>(
        builder: (context, languageProvider, _) {
      return directionality(child:
          Consumer<DrawerProvider>(builder: (context, drawerProvider, _) {
        return ClipRRect(
          borderRadius:
              borderRadius(radius: drawerProvider.isOpenDrawer ? 20 : 0),
          child: Scaffold(
            body: Column(
              children: [
                // app bar
                HomeWidget.homeAppBar(appBarController, appBarAnimation, token,
                    searchController, searchNode, name),

                // body
                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Student Card
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildStudentCard(context),
                            const SizedBox(height: 20),
                            // Banner Carousel from categories
                            if (!isLoading && trendCategories.isNotEmpty)
                              CategoryBannerCarousel(
                                  categories: trendCategories),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      // Categories Section Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                appText.categories,
                                style: GoogleFonts.kufam(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Icon(
                                Icons.more_horiz_rounded,
                                color: Color(0xFF9CA3AF),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 16),
                      ),

                      // Categories List - This is the key fix!
                      isLoading
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 6),
                                  child: _buildSubjectChipShimmer(),
                                ),
                                childCount: 3,
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  if (index >= trendCategories.length) {
                                    return null; // This prevents infinite scrolling
                                  }

                                  final category = trendCategories[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 6),
                                    child: GestureDetector(
                                      onTap: () {
                                        // just for test
                                        //nextRoute(FilterCategoryPage.pageName,
                                        //arguments: category);
                                        nextRoute(CategoriesPage.pageName,
                                            arguments: category);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Stack(
                                            children: [
                                              Image.network(
                                                category.title ?? '',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    color: Colors.grey.shade300,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey,
                                                        size: 50,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Container(
                                                    color: Colors.grey.shade200,
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  );
                                                },
                                              ),
                                              // Gradient overlay for better text readability
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black
                                                          .withOpacity(0.3),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount:
                                    trendCategories.length, // This is crucial!
                              ),
                            ),

                      // Bottom padding
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }));
    });
  }

  Widget _buildStudentCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenWidth * 0.8,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/image/png/techer_icon_home.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSubjectChipShimmer() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryBannerCarousel extends StatelessWidget {
  final List<CategoryModel> categories;

  const CategoryBannerCarousel({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter categories that have valid network icons only
    final validCategories = categories.where((category) {
      if (category.icon == null ||
          category.icon!.isEmpty ||
          category.icon!.trim().isEmpty) {
        return false;
      }

      // Only include network images (URLs)
      final bool isNetworkIcon = category.icon!.startsWith('http://') ||
          category.icon!.startsWith('https://') ||
          category.icon!.startsWith('www.');

      return isNetworkIcon;
    }).toList();

    // Don't show carousel if no valid network icons
    if (validCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      child: CarouselSlider.builder(
        itemCount: validCategories.length,
        options: CarouselOptions(
          height: 200,
          autoPlay: validCategories.length > 1,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          viewportFraction: 1.0,
          enlargeCenterPage: false,
          enableInfiniteScroll: validCategories.length > 1,
          padEnds: false,
        ),
        itemBuilder: (context, index, realIdx) {
          final category = validCategories[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Network image from category icon
                  Image.network(
                    category.icon!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade600,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Failed to load banner',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            if (category.title != null)
                              Text(
                                category.title!,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Optional: Add tap functionality to navigate to category
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // Navigate to category page
                          nextRoute(FilterCategoryPage.pageName,
                              arguments: category);
                        },
                        child: Container(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BannerCarousel extends StatelessWidget {
  final List<String> images;

  const BannerCarousel({
    Key? key,
    required this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CarouselSlider.builder(
        itemCount: images.length,
        options: CarouselOptions(
          height: 200,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          viewportFraction: 1.0,
          enlargeCenterPage: false,
          enableInfiniteScroll: true,
        ),
        itemBuilder: (context, index, realIdx) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildImage(images[index]),
          );
        },
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    // Check if the image is a network URL or asset path
    final bool isNetworkImage = imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://') ||
        imageUrl.startsWith('www.');

    if (isNetworkImage) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Container(
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  color: Colors.grey.shade600,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  color: Colors.grey.shade600,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'Asset not found',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
