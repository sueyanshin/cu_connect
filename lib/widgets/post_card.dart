import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cu_connect/screens/edit_post_screen.dart';
import 'package:cu_connect/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cu_connect/models/user.dart' as model;
import 'package:cu_connect/providers/user_provider.dart';
import 'package:cu_connect/resources/firestore_methods.dart';
import 'package:cu_connect/screens/comments_screen.dart';
import 'package:cu_connect/utils/colors.dart';
import 'package:cu_connect/utils/global_variable.dart';
import 'package:cu_connect/utils/utils.dart';
import 'package:cu_connect/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;
  var userData;
  bool userBlueMarkStatus = false;

  @override
  void initState() {
    super.initState();
    getData();
    fetchCommentLen();
  }

  // void getData() async {
  //   var userSnap = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.snap['uid'])
  //       .get();
  //   setState(() {
  //     userBlueMarkStatus = userSnap.data()?['blueMark'];
  //   });
  // }
  void getData() async {
    try {
      DocumentSnapshot userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.snap['uid'])
          .get();

      if (userSnap.exists) {
        setState(() {
          userData = userSnap.data() ?? {};
          userBlueMarkStatus = userData['blueMark'];
        });
      } else {
        print('User not found');
      }
    } catch (error) {
      // Handle error
      print('Error fetching user data: $error');
    }
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      // ignore: use_build_context_synchronously
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      // ignore: use_build_context_synchronously
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return Container(
      // boundary needed for web
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
        ),
        color: mobileBackgroundColor,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 0,
      ),
      child: Column(
        children: [
          // HEADER SECTION OF THE POST
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      uid: widget.snap['uid'].toString(),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: CachedNetworkImageProvider(
                        widget.snap['profImage'].toString(),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                Text(
                                  widget.snap['username'].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                // Blue Mark
                                userBlueMarkStatus == true
                                    ? Container(
                                        width: 15,
                                        height: 15,
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      )
                                    : const Text(''),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    widget.snap['uid'].toString() == user.uid
                        ? IconButton(
                            onPressed: () {
                              showDialog(
                                useRootNavigator: false,
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: ListView(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shrinkWrap: true,
                                        children: [
                                          'Edit',
                                          'Delete',
                                        ]
                                            .map(
                                              (e) => InkWell(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                    child: Text(e),
                                                  ),
                                                  onTap: () {
                                                    if (e == "Edit") {
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .push(
                                                              MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditPostScreen(
                                                                snap: widget
                                                                    .snap),
                                                      ));
                                                    }
                                                    if (e == "Delete") {
                                                      deletePost(
                                                        widget.snap['postId']
                                                            .toString(),
                                                      );
                                                      // remove the dialog box
                                                      Navigator.of(context)
                                                          .pop();
                                                      showSnackBar(context,
                                                          'Deleted your post!');
                                                    }
                                                  }),
                                            )
                                            .toList()),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.more_vert),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
          // IMAGE SECTION OF THE POST
          GestureDetector(
            onDoubleTap: () {
              FireStoreMethods().likePost(
                widget.snap['postId'].toString(),
                user.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) => Center(
                        child: Stack(
                          children: [
                            // Image(
                            //     image: NetworkImage(
                            //   widget.snap['postUrl'],
                            // )),
                            CachedNetworkImage(
                              imageUrl: widget.snap['postUrl'].toString(),
                              progressIndicatorBuilder:
                                  (context, url, progress) => Center(
                                child: CircularProgressIndicator(
                                  value: progress.progress,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),

                            Positioned(
                              right: 10,
                              top: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: const Icon(Icons.close)),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: widget.snap['postUrl'].toString(),
                        progressIndicatorBuilder: (context, url, progress) =>
                            Center(
                          child: CircularProgressIndicator(
                            value: progress.progress,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // LIKE, COMMENT SECTION OF THE POST
          Row(
            children: <Widget>[
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user.uid),
                smallLike: true,
                child: IconButton(
                  icon: widget.snap['likes'].contains(user.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_border,
                        ),
                  onPressed: () => FireStoreMethods().likePost(
                    widget.snap['postId'].toString(),
                    user.uid,
                    widget.snap['likes'],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.comment_outlined,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentsScreen(
                      postId: widget.snap['postId'].toString(),
                    ),
                  ),
                ),
              ),
              // IconButton(
              //     icon: const Icon(
              //       Icons.send,
              //     ),
              //     onPressed: () {}),
              // Expanded(
              //     child: Align(
              //   alignment: Alignment.bottomRight,
              //   child: IconButton(
              //       icon: const Icon(Icons.bookmark_border), onPressed: () {}),
              // ))
            ],
          ),
          //DESCRIPTION AND NUMBER OF COMMENTS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: Text(
                      '${widget.snap['likes'].length} likes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: widget.snap['username'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' ${widget.snap['description']}',
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'View all $commentLen comments',
                      style: const TextStyle(
                        fontSize: 14,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        postId: widget.snap['postId'].toString(),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap['datePublished'].toDate()),
                    style: const TextStyle(color: secondaryColor, fontSize: 12),
                  ),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
          const Divider(
            height: 0,
            thickness: 1,
            indent: 15,
            endIndent: 15,
            color: Colors.grey,
          )
        ],
      ),
    );
  }
}
