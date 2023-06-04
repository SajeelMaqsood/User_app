import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:find_a_mechanic/configMap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Models/message.dart';
import '../main.dart';
class MessageCard extends StatefulWidget {
  Message message;

  MessageCard({Key? key,required this.message}) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();

}

class _MessageCardState extends State<MessageCard> {

  String currentUser= FirebaseAuth.instance.currentUser!.uid.toString();
  @override
  Widget build(BuildContext context) {
    bool isMe =currentUser== widget.message.senderId;
    return InkWell(
        child: isMe ? _greenMessage() : _blueMessage());
  }

  // sender or another user message
  Widget _blueMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(
                widget.message.type == 'image'
                    ? 9
                    : 8),
            margin: EdgeInsets.symmetric(
                horizontal: 50, vertical: 15),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                //making borders curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child:widget.message.type== 'text'
                ?
            //show text
            Text(
              widget.message.msg.toString(),
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            )
            :
            //show image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: GestureDetector(
                onTap: (){
                  final imageProvider = Image.network(widget.message.msg.toString()).image;
                  showImageViewer(context, imageProvider, onViewerDismissed: () {
                    print("dismissed");
                  });

                },
                child: CachedNetworkImage(
                  imageUrl: widget.message.msg.toString(),
                  imageBuilder: (context, imageProvider) => Container(
                    width: 300.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.image, size: 70),
                ),
              ),
            ),

          ),
        ),

        //message time
      ],
    );
  }

  // our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message time
        // Row(
        //   children: [
        //     //for adding some space
        //     SizedBox(width: mq.width * .04),
        //
        //     //double tick blue icon for message read
        //     if (widget.message.read.isNotEmpty)
        //       const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),
        //
        //     //for adding some space
        //     const SizedBox(width: 2),
        //
        //     //sent time
        //     Text(
        //       widget.message.sent,
        //       style: const TextStyle(fontSize: 13, color: Colors.black54),
        //     ),
        //   ],
        // ),

        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(
                widget.message.type == 'image'
                ? 9
                : 8
            ),
            margin: EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color: Colors.lightGreen),
                //making borders curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type== 'text'
                ?
            //show text
            Text(
              widget.message.msg.toString(),
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            )
                :
            //show image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: GestureDetector(
                onTap: (){
                  final imageProvider = Image.network(widget.message.msg.toString()).image;
                  showImageViewer(context, imageProvider, onViewerDismissed: () {
                    print("dismissed");
                  });
                },
                child: CachedNetworkImage(
                  imageUrl: widget.message.msg.toString(),
                  imageBuilder: (context, imageProvider) => Container(
                    width: 300.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.image, size: 70),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
