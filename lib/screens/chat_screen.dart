import 'dart:io';
import 'package:path/path.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/components/messages_stream.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';


final firestore = Firestore.instance;
Stream snapshotStream;
FirebaseUser loggedInUser;
FirebaseStorage _storage = FirebaseStorage.instance;

class ChatScreen extends StatefulWidget {
  static const String id = 'ChatScreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messagetextcontroller = TextEditingController();
  String message;
  List<String> urls = new List<String>();
  List<File> pickedFiles = [];

  

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  
  }

  Future getPDF() async {
    pickedFiles = await FilePicker.getMultiFile(
        type: FileType.CUSTOM, fileExtension: 'pdf');
    String filenames = '';
    for (File file in pickedFiles) {
      String name = basename(file.path);
      filenames = filenames + name + "\n";
      print(name);
    }
    setState(() {
      messagetextcontroller.value = TextEditingValue(
        text: filenames,
      );
    });
  }

  Future uploadFiles() async{
    for(File file in pickedFiles){
    StorageReference ref = _storage.ref().child(basename('pdf'));
    StorageUploadTask uploadTask =  ref.child(basename(file.path)).putFile(file);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    urls.add(url);
    }
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
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
                Navigator.pushNamed(context, WelcomeScreen.id);
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
            Expanded(child: MessagesStream()),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messagetextcontroller,
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file),
                    color: Colors.black54,
                    iconSize: 30,
                    onPressed: () {
                      getPDF();
                    },
                  ),
                  FlatButton(
                    onPressed: () async {
                    
                      setState(() {
                      message = messagetextcontroller.text;
                      });
                      print(messagetextcontroller.text);
                      if(pickedFiles.isNotEmpty){
                      await uploadFiles();
                      pickedFiles.clear();
                      }
                      firestore.collection('messeges').add({
                        'sender': loggedInUser.email,
                        'text': message,
                        'time': FieldValue.serverTimestamp(),
                        'url' : urls,
                      });

                      urls.clear();
                      messagetextcontroller.clear();
                      
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
