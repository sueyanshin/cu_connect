import 'package:cu_connect/screens/user_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cu_connect/screens/add_post_screen.dart';
import 'package:cu_connect/screens/feed_screen.dart';
import 'package:cu_connect/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  UserProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
