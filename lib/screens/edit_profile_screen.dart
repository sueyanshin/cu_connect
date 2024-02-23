import 'dart:typed_data';

import 'package:cu_connect/providers/user_provider.dart';
import 'package:cu_connect/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cu_connect/resources/auth_methods.dart';
import 'package:cu_connect/utils/utils.dart';
import 'package:provider/provider.dart';

import '../models/user.dart' as model;

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String bio;
  final String image;
  const EditProfileScreen({
    Key? key,
    required this.username,
    required this.bio,
    required this.image,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Uint8List? _image;
  String? imglink;

  @override
  void initState() {
    super.initState();

    _usernameController.text = widget.username;
    _bioController.text = widget.bio;
    imglink = widget.image;
  }

  @override
  void dispose() {
    super.dispose();
  }

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        actions: [
          IconButton(
              onPressed: () async {
                await AuthMethods().updateUserData(
                    username: _usernameController.text,
                    bio: _bioController.text,
                    file: _image);
                Navigator.of(context).pop();
                setState(() {
                  user;
                });
              },
              icon: const Icon(Icons.check))
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 64,
              ),
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                          backgroundColor: Colors.purpleAccent,
                        )
                      : CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(imglink!),
                          backgroundColor: Colors.grey,
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              TextFormField(
                autofocus: true,
                controller: _usernameController,
              ),
              const SizedBox(
                height: 24,
              ),
              TextFormField(controller: _bioController),
              const SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
