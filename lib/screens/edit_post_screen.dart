import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cu_connect/providers/user_provider.dart';
import 'package:cu_connect/resources/firestore_methods.dart';
import 'package:cu_connect/utils/colors.dart';
import 'package:cu_connect/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class EditPostScreen extends StatefulWidget {
  final snap;
  const EditPostScreen({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.snap['description'] ?? '';
    _loadImage(widget.snap['postUrl']);
  }

  void _loadImage(String imageUrl) async {
    // Fetch the image data from the network
    var response = await http.get(Uri.parse(imageUrl));

    // Decode the response body as a byte array
    Uint8List bytes = response.bodyBytes;

    setState(() {
      // Assign the bytes to _file
      _file = bytes;
    });
  }

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose an image'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void post(String pid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await FireStoreMethods()
          .updatePost(pid, _descriptionController.text, _file!, profImage);
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          showSnackBar(
            context,
            'Updated your post!',
          );
        }
        clearImage();
      } else {
        if (context.mounted) {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return
        // _file == null
        //     ? Center(
        //         child: IconButton(
        //           icon: const Icon(
        //             Icons.upload,
        //           ),
        //           onPressed: () => _selectImage(context),
        //         ),
        //       )
        //     :
        Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        title: const Text(
          'Edit post',
        ),
        centerTitle: false,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              post(
                // userProvider.getUser.uid,
                widget.snap['postId'],
                userProvider.getUser.username,
                userProvider.getUser.photoUrl,
              );
            },
            child: const Text(
              "Save",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          )
        ],
      ),
      // POST FORM
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: <Widget>[
              isLoading
                  ? const LinearProgressIndicator()
                  : const Padding(padding: EdgeInsets.only(top: 0.0)),
              const Divider(),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // User information
                  // Image and description text field
                  // The existing image widget should be replaced by a GestureDetector to allow image selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          userProvider.getUser.photoUrl,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        userProvider.getUser.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _selectImage(context),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: _file != null
                          ? Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  alignment: FractionalOffset.topCenter,
                                  image: MemoryImage(_file!),
                                ),
                              ),
                            )
                          : (widget.snap['postUrl'] != null
                              ? CachedNetworkImage(
                                  imageUrl: widget.snap['postUrl'],
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                )
                              : Placeholder()), // Placeholder or any other widget to display if no image is selected
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: "Write a caption...",
                        border: InputBorder.none,
                      ),
                      maxLines: 8,
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
