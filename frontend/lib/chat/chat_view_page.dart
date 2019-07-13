import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:week_3/utils/base_height.dart';
import 'dart:developer';

class ChatViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Chat();
  }
}

class ChatState extends State<Chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
//  final Firestore _firestore = Firestore.instance;

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  final _paddingFormat = EdgeInsets.only(left: 26, top: 12, bottom: 12, right: 26);

  final _dialPartnerName = 'diuni';

  final _partnerNameFont = TextStyle(fontSize: 20.0, color: Colors.grey[600]);
  final _chatFont = TextStyle(fontSize: 12.0, color: Colors.grey[500]);
  // final _timeFont = TextStyle(fontSize: 10.0, color: Colors.grey[400]);

  Future<void> callback() async {
    if (messageController.text.length > 0) {
      await
          //     _firestore.collections('messages').add({
          // 'text': messageController.text,
          // 'from': widget.user.id,
//      });
          log('add message to db');
      messageController.clear();
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          curve: Curves.easeOut, duration: const Duration(milliseconds: 300));
    }
  }

  Widget _typingbar(context) {
    return Container(
      width: 270.0,
      height: screenAwareSize(50.0, context),
      child: TextField(
        onSubmitted: (value) => callback(),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(screenAwareSize(5.0, context)),
          // suffixIcon: SendButton(
          //   text: "Send",
          //   callback: callback,
          // ),
          hintText: "Enter a message...",
          hintStyle: TextStyle(fontSize: 14.0),
        ),
        controller: messageController,
        maxLines: 2,
        autofocus: true,
        style: TextStyle(fontSize: 14.0),
        scrollPadding: EdgeInsets.all(2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(_dialPartnerName, style: _partnerNameFont,),
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Message(
                from: 'diuni',
                text: 'heello 내 이름은 지윤팍팍 아임 지윤 유 쎄이 지 아 쎄 윤 지 윤 지 윤',
                me: false,
              ),
              Container(
                  padding: EdgeInsets.only(left: 30.0),
                  child: new Row(
                    children: <Widget>[
                      _typingbar(context),
                      SendButton(
                        text: "Send",
                        callback: callback,
                      ),
                    ],
                  ))
            ],
          ),
        ));
  }
}

class Chat extends StatefulWidget {
  @override
  ChatState createState() => ChatState();
}

class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SendButton({Key key, this.text, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: callback,
        icon: Icon(
          Icons.send,
          color: Colors.grey[400],
        ));
  }
}

class Message extends StatelessWidget {
  final String from;
  final String text;
  final String time;

  final bool me;

  final _chatFont = const TextStyle(fontSize: 14.0, color: Colors.grey);

  const Message({Key key, this.from, this.text, this.me, this.time})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // crossAxisAlignment: me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            color: me ? Colors.white : Colors.amber[200],
            borderRadius: BorderRadius.circular(30.0),
            elevation: 0.0,
            child: Container(
              constraints: BoxConstraints(maxWidth: 250),
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 24.0),
              child: Text(
                text,
                style: _chatFont,
              ),
            ),
          )
        ],
      ),
    );
  }
}
