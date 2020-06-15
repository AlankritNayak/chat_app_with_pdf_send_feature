import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.textmessage, this.isUser, this.hasURL});

  final String sender;
  final String textmessage;
  final bool isUser;
  final List hasURL;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender == null ? '' : sender,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Material(
            borderRadius: isUser
                ? BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(40))
                : BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(25),
                    bottomLeft: Radius.circular(40)),
            elevation: 4,
            color: isUser ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
              child: hasURL.isNotEmpty
                  ? InkWell(
                      child: Text(
                        textmessage == null ? '' : textmessage,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black54,
                          fontSize: 15,
                          decoration: TextDecoration.underline
                        
                        ),
                      ),
                      onTap: () => launch(hasURL[0]),
                    )
                  : Text(
                      textmessage == null ? '' : textmessage,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black54,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
