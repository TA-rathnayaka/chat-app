import 'package:flutter/material.dart';
import 'package:chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;
User? loggedUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'ChatScreen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final massageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String? messageText;

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedUser = user as User;
      }
    } catch (e) {
      print(e);
    }
  }

  void getMessages() async {
    final massages = await _fireStore.collection('messages').get();
    for (var message in massages.docs) {
      print(message.data());
    }
  }

  void messageStream() async {
    await for (var snapshot in _fireStore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesSteam(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: massageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      massageTextController.clear();
                      _fireStore.collection('messages').add(
                          {'sender': loggedUser?.email, 'text': messageText});
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesSteam extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore.collection('messages').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blueAccent,
              ),
            );
          }
          final messages = snapshot.data?.docs.reversed;
          List<MessageBubble> messageBubbles = [];
          if (messages != null) {
            for (var message in messages) {
              var messageData = message.data() as Map<String, dynamic>?;
              if (messageData != null) {
                final sender = messageData['sender'];
                final text = messageData['text'];
                messageBubbles.add(MessageBubble(
                    sender: sender,
                    text: text,
                    isMe: sender == loggedUser?.email));
              }
            }
          }
          return Expanded(
              child: ListView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  reverse: true,
                  children: messageBubbles));
        });
  }
}

class MessageBubble extends StatelessWidget {
  final sender;
  final text;
  bool isMe;

  MessageBubble({required this.sender, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12.0, color: Colors.black54),
          ),
          Material(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(isMe ? 0 : 30),
                  topLeft: Radius.circular(isMe ? 30.0 : 0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30)),
              elevation: 5.0,
              color: isMe ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Text(
                  text,
                  style: TextStyle(
                      fontSize: 15.0,
                      color: isMe ? Colors.white : Colors.black54),
                ),
              )),
        ],
      ),
    );
  }
}
