// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../main.dart';
//
//
// class ChatScreen extends StatelessWidget {
//   const ChatScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           flexibleSpace: _appBar(),
//         ),
//       ),
//     );
//   }
//   Widget _appBar() {
//     return InkWell(
//         // onTap: () {
//         //   Navigator.push(
//         //       context,
//         //       MaterialPageRoute(
//         //           builder: (_) => ViewProfileScreen(user: widget.user)));
//         // },
//         child: StreamBuilder(
//             stream: APIs.getUserInfo(widget.user),
//             builder: (context, snapshot) {
//               final data = snapshot.data?.docs;
//               final list =
//                   data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
//
//               return Row(
//                 children: [
//                   //back button
//                   IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon:
//                       const Icon(Icons.arrow_back, color: Colors.black54)),
//
//                   //user profile picture
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(mq.height * .03),
//                     child: CachedNetworkImage(
//                       width: mq.height * .05,
//                       height: mq.height * .05,
//                       imageUrl:
//                       list.isNotEmpty ? list[0].image : widget.user.image,
//                       errorWidget: (context, url, error) => const CircleAvatar(
//                           child: Icon(CupertinoIcons.person)),
//                     ),
//                   ),
//
//                   //for adding some space
//                   const SizedBox(width: 10),
//
//                   //user name & last seen time
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       //user name
//                       Text(list.isNotEmpty ? list[0].name : widget.user.name,
//                           style: const TextStyle(
//                               fontSize: 16,
//                               color: Colors.black87,
//                               fontWeight: FontWeight.w500)),
//
//                       //for adding some space
//                       const SizedBox(height: 2),
//
//                       //last seen time of user
//                       Text(
//                           list.isNotEmpty
//                               ? list[0].isOnline
//                               ? 'Online'
//                               : MyDateUtil.getLastActiveTime(
//                               context: context,
//                               lastActive: list[0].lastActive)
//                               : MyDateUtil.getLastActiveTime(
//                               context: context,
//                               lastActive: widget.user.lastActive),
//                           style: const TextStyle(
//                               fontSize: 13, color: Colors.black54)),
//                     ],
//                   )
//                 ],
//               );
//             }));
//   }
// }
