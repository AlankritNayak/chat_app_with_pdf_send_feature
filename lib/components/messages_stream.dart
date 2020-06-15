import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'message_bubble.dart';

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('messeges')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data['text'];
          final messageSender = message.data['sender'];
          final List urls = message.data['url'];
          var messageBubble = MessageBubble(
            sender: messageSender,
            textmessage: messageText,
            isUser: messageSender == loggedInUser.email,
            hasURL: urls,
          );
          messageBubbles.add(messageBubble);
        }
        return ListView(
          reverse: true,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          children: messageBubbles,
        );
      },
    );
  }
}
