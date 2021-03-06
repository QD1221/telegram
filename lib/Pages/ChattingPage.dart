import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Widgets/FullImageWidget.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;

  Chat({
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar,
    @required this.receiverName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: CachedNetworkImageProvider(receiverAvatar),
              ),),
        ],
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text(
          receiverName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(receiverId: receiverId, receiverAvatar: receiverAvatar),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;

  ChatScreen({
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar,
  }) : super(key : key);

  @override
  State createState() => ChatScreenState(receiverId: receiverId, receiverAvatar: receiverAvatar);
}




class ChatScreenState extends State<ChatScreen> {
  final String receiverId;
  final String receiverAvatar;

  ChatScreenState({
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar,
  });

  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool isDisplaySticker;
  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isDisplaySticker = false;
    isLoading = false;
    focusNode.addListener(onFocusChange);
  }

  onFocusChange(){
    if(focusNode.hasFocus){
      //Hide stickers whenever keypad appears
      setState(() {
        isDisplaySticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                //Create list of messages
                createListMessages(),

                //Show stickers
                (isDisplaySticker ? createStickers() : Container()),

                //Input Controllers
                createInput(),
              ],
            ),
            createLoading(),
          ],
        ),
        onWillPop: onBackPress,
      );
    }

  createLoading(){
    return Positioned(
        child: isLoading ? circularProgress() : Container());
  }
  Future<bool> onBackPress(){
    if(isDisplaySticker){
      setState(() {
        isDisplaySticker = false;
      });
    }else{
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  createStickers(){
    return Container(
      child: Column(
        children: <Widget>[
          //1st row
          Row(
            children: <Widget>[
              FlatButton(
                // onPressed: onSendMessage('mimi1', 2),
                child: Image.asset(
                  "images/mimi1.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),

              FlatButton(
                // onPressed: onSendMessage('mimi2', 2),
                child: Image.asset(
                  "images/mimi2.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),

              FlatButton(
                // onPressed: onSendMessage('mimi3', 2),
                child: Image.asset(
                  "images/mimi3.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          //2nd row
          Row(
            children: <Widget>[
              FlatButton(
                // onPressed: onSendMessage('mimi4', 2),
                child: Image.asset(
                  "images/mimi4.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),

              FlatButton(
                // onPressed: onSendMessage('mimi5', 2),
                child: Image.asset(
                  "images/mimi5.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),

              FlatButton(
                // onPressed: onSendMessage('mimi6', 2),
                child: Image.asset(
                  "images/mimi6.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          //3rd row
          Row(
            children: <Widget>[
              FlatButton(
                // onPressed: onSendMessage('mimi7', 2),
                child: Image.asset(
                  "images/mimi7.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),

              FlatButton(
                // onPressed: onSendMessage('mimi8', 2),
                child: Image.asset(
                  "images/mimi8.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),

              FlatButton(
                // onPressed: onSendMessage('mimi9', 2),
                child: Image.asset(
                  "images/mimi9.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5)), color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180,
    );
  }

  void getSticker(){
    focusNode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
  }

  createListMessages(){
    return Flexible(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
          ),
        )
    );
  }

  createInput(){
    return Container(
      child: Row(
        children: <Widget>[
          //Pick image icon button
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                  icon: Icon(Icons.image),
                  color: Colors.lightBlueAccent,
                  onPressed: () => print('Clicked')
              ),
            ),
            color: Colors.white,
          ),

          //Emoji icon button
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                  icon: Icon(Icons.face),
                  color: Colors.lightBlueAccent,
                  onPressed: getSticker,
              ),
            ),
            color: Colors.white,
          ),

          //Text Field
          Flexible(
              child: Container(
                child: TextField(
                  style: TextStyle(
                    color: Colors.black, fontSize: 15,
                  ),
                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Write here',
                    hintStyle: TextStyle(color: Colors.grey)
                  ),
                  focusNode: focusNode,
                ),
              )
          ),

          //Send Message Icon Button
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.lightBlueAccent,
                  onPressed: () => print('Clicked')
              ),
            ),
            color: Colors.white,
          )
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          )
        ),
        color: Colors.white,
      ),
    );
  }

}
