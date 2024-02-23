import 'package:cached_network_image/cached_network_image.dart';
import 'package:cu_connect/models/user.dart';
import 'package:cu_connect/resources/auth_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cu_connect/utils/colors.dart';
import 'package:cu_connect/utils/global_variable.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController; // for tabs animation
  late User _currentUser;
  bool _isLoading = true;
  AuthMethods authMethods = AuthMethods();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    pageController = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
    setState(() {
      _page = page;
    });
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await AuthMethods().getUserDetails();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (error) {
      // Handle error
      print('Error loading user: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            body: PageView(
              controller: pageController,
              onPageChanged: onPageChanged,
              children: homeScreenItems,
            ),
            bottomNavigationBar: CupertinoTabBar(
              backgroundColor: mobileBackgroundColor,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    (_page == 0) ? Icons.home_filled : Icons.home_rounded,
                    color: (_page == 0) ? primaryColor : secondaryColor,
                  ),
                  label: '',
                  backgroundColor: primaryColor,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    (_page == 1) ? Icons.search : Icons.search_outlined,
                    color: (_page == 1) ? primaryColor : secondaryColor,
                  ),
                  label: '',
                  backgroundColor: primaryColor,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    (_page == 2) ? Icons.add_circle : Icons.add_circle_outline,
                    color: (_page == 2) ? primaryColor : secondaryColor,
                  ),
                  label: '',
                  backgroundColor: primaryColor,
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: _page == 3 ? Colors.white : secondaryColor,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(_currentUser.photoUrl),
                      radius: 14,
                    ),
                  ),
                  label: '',
                  backgroundColor: primaryColor,
                ),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
            ),
          );
  }
}
