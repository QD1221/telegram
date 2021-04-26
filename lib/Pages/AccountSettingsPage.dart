import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:telegramchatapp/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';



class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.lightBlue,
        title: Text(
          "Account Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}


class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}



class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController nickNameTextEditingController;
  TextEditingController aboutMeTextEditingController;
  SharedPreferences preferences;
  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photoUrl = "";
  File imageFileAvatar;
  bool isLoading = false;
  final FocusNode nickNameFocusNode = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    readDataFromLocal();
  }

  void readDataFromLocal() async{
    preferences = await SharedPreferences.getInstance();

    id = preferences.getString("id");
    nickname = preferences.getString("nickname");
    aboutMe = preferences.getString("aboutMe");
    photoUrl = preferences.getString("photo");

    nickNameTextEditingController = TextEditingController(text: nickname);
    aboutMeTextEditingController = TextEditingController(text: aboutMe);

    setState(() {

    });

  }

  Future getImage() async{
    File newImageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(newImageFile != null){
      setState(() {
        this.imageFileAvatar = newImageFile;
        isLoading = true;
      });
    }

    uploadImageToFirestoreAndStorage();

  }

  Future uploadImageToFirestoreAndStorage() async{
    String mFileName = id;
    StorageReference storageReference = FirebaseStorage.instance.ref().child(mFileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(imageFileAvatar);
    StorageTaskSnapshot storageTaskSnapshot;
    storageUploadTask.onComplete.then((value) {
      if(value.error == null){
        storageTaskSnapshot = value;

        storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
          photoUrl = newImageDownloadUrl;

          Firestore.instance.collection("users").document(id).updateData({
            "photo": photoUrl,
            "aboutMe": aboutMe,
            "nickname": nickname
          }).then((data) async{
            await preferences.setString("photo", photoUrl);

            setState(() {
              isLoading = false;
            });

            Fluttertoast.showToast(msg: "Updated successfully.");
          });
        }, onError: (errorMsg){
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'Error occurred');
        });
      }
    }, onError: (errorMsg){
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: errorMsg.toString());
    });
  }

  void updateData(){
    nickNameFocusNode.unfocus();
    aboutMeFocusNode.unfocus();

    setState(() {
      isLoading = false;
    });

    Firestore.instance.collection("users").document(id).updateData({
      "photo": photoUrl,
      "aboutMe": aboutMe,
      "nickname": nickname
    }).then((data) async{
      await preferences.setString("photo", photoUrl);
      await preferences.setString("aboutMe", aboutMe);
      await preferences.setString("nickname", nickname);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Updated successfully.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              //Profile Image
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (imageFileAvatar == null)
                          ? (photoUrl != "")
                          ? Material(
                            //Display already existing - old image file
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation <Color>(Colors.lightBlueAccent),
                                ),
                                width: 200,
                                height: 200,
                                padding: EdgeInsets.all(20),
                              ),
                              imageUrl: photoUrl,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(125)),
                            clipBehavior: Clip.hardEdge,

                      )
                          : Icon(Icons.account_circle, size: 90, color: Colors.grey,)
                          : Material(
                            //Display the new update image here
                            child: Image.file(
                              imageFileAvatar,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(125)),
                            clipBehavior: Clip.hardEdge,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt, size: 50, color: Colors.white54.withOpacity(0.3),
                        ),
                        onPressed: getImage,
                        padding: EdgeInsets.all(10),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.grey,
                        iconSize: 200,
                      )
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20),
              ),

              //Input Fields
              Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(1), child: isLoading ? circularProgress() : Container(),),

                  //Username
                  Container(
                    child: Text(
                      'Profile Name: ',
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
                    ),
                    margin: EdgeInsets.only(left: 10, bottom: 5, top: 10),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Quang Tran",
                          contentPadding: EdgeInsets.all(5),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: nickNameTextEditingController,
                        onChanged: (value){
                          nickname = value;
                        },
                        focusNode: nickNameFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30, right: 30),
                  ),

                  //aboutMe - Bio
                  Container(
                    child: Text(
                      'About Me: ',
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
                    ),
                    margin: EdgeInsets.only(left: 10, bottom: 5, top: 30),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Bio...",
                          contentPadding: EdgeInsets.all(5),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: aboutMeTextEditingController,
                        onChanged: (value){
                          aboutMe = value;
                        },
                        focusNode: aboutMeFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30, right: 30),
                  )

                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              //Buttons
              Container(
                child: FlatButton(
                  onPressed: updateData,
                  child: Text('Update', style: TextStyle(fontSize: 16),
                  ),
                  color: Colors.lightBlueAccent,
                  highlightColor: Colors.grey,
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                ),
                margin: EdgeInsets.only(top: 50, bottom: 1),
              ),

              //Logout Button
              Padding(
                padding: EdgeInsets.only(left: 50, right: 50),
                child: ElevatedButton(
                  onPressed: logoutUser,
                  child: Text('Logout', style: TextStyle(color: Colors.white, fontSize: 14),
                  ),

                ),
              )
            ],
          ),
          padding: EdgeInsets.only(left: 15, right: 15),
        )
      ],
    );
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Null> logoutUser() async{
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MyApp()), (Route<dynamic> route) => false);

  }
}
