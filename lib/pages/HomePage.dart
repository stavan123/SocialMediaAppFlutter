import 'dart:io';
import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/CreateAccountPage.dart';
import 'package:buddiesgram/pages/NotificationsPage.dart';
import 'package:buddiesgram/pages/ProfilePage.dart';
import 'package:buddiesgram/pages/SearchPage.dart';
import 'package:buddiesgram/pages/TimeLinePage.dart';
import 'package:buddiesgram/pages/UploadPage.dart';
import 'package:buddiesgram/pages/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'sign_in.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:google_sign_in/google_sign_in.dart';


final usersReference =  Firestore.instance.collection('users');
final postsReference =  Firestore.instance.collection('posts');
final StorageReference storageReference =  FirebaseStorage.instance.ref().child("Post Pictures");
final activityFeedReference =  Firestore.instance.collection("feed");
final commentsReference =  Firestore.instance.collection("comments");
final followersReference =  Firestore.instance.collection("followers");
final followingReference =  Firestore.instance.collection("following");
final timelineReference =  Firestore.instance.collection("timeline");

final DateTime timestamp = DateTime.now();
User currentUser ;
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
bool isSignedIn = false;

 PageController  pageController;
 int getPageIndex = 0;

 FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
 final _scaffoldKey = GlobalKey<ScaffoldState>();


void initState()
{
   super.initState();
  pageController = PageController();
  googleSignIn.onCurrentUserChanged.listen((gSignInAccount) { 
    controlSignIn(gSignInAccount);
  },onError: (gerror)
  { 
   print("Error Message"+gerror); 
  }  
  );

  // googleSignIn.signInSilently(suppressErrors: false).then((gSignInAccount) {
  //   controlSignIn(gSignInAccount);
  // }).catchError((onError)
  // {
  //   print("Error"+ onError);
  
  // });  
  // //  cx
}

controlSignIn(googleSignInAccount)
async
{
  print(isSignedIn);
 if (googleSignInAccount != null)
 {
  await saveUserInfoFireStore();

   setState(() {
     isSignedIn = true;
   });

   configureRealTimePushNotification();
 }
 else
 {
   setState(() {
     isSignedIn = false;
   });
 }
}

configureRealTimePushNotification()
{
  final GoogleSignInAccount gUser = googleSignIn.currentUser;
  if(Platform.isIOS)
  {
    getIOSPermissions();
  }
  _firebaseMessaging.getToken()
.then((token) {
usersReference.document(gUser.id).updateData({"androidNotificationToken":token});
} );
_firebaseMessaging.configure(
 onMessage: (Map<String, dynamic> msg ) async
 {
   final String recipientId = msg["data"]["recipient"];
   final String body = msg["notification"]["body"];

   if (recipientId == gUser.id)
   {
     SnackBar snackBar = SnackBar(
       backgroundColor: Colors.grey,
       content: Text(body, style: TextStyle(color: Colors.black,),overflow:TextOverflow.ellipsis ,)
       
     );
    _scaffoldKey.currentState.showSnackBar(snackBar);

   }
 }
);
}
getIOSPermissions()
{
   _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(alert:true,badge: true,sound:true));
   _firebaseMessaging.onIosSettingsRegistered.listen((setting) { 
    print("setting Registered   : $setting");

   });
}

// This is ussed for chhangind the page 
whenPageChanges(int pageIndex)
{
  setState(() {
   this.getPageIndex = pageIndex;    
  });

}


onTapChangePage(int pageIndex)
{
  pageController.animateToPage(pageIndex, duration: Duration(microseconds:  400), curve: Curves.bounceInOut);
}

saveUserInfoFireStore() async
{

DocumentSnapshot documentSnapshot = await usersReference.document(googleSignIn.currentUser.id).get();
if(!documentSnapshot.exists)
{
  final username = await Navigator.push(context, MaterialPageRoute(builder: (context) =>CreateAccountPage()));   
   usersReference.document(googleSignIn.currentUser.id).setData(
   {
     "id": googleSignIn.currentUser.id,
     "profileName": googleSignIn.currentUser.displayName,
     "username":username,
     "url":googleSignIn.currentUser.photoUrl,
     "email":googleSignIn.currentUser.email,
     "bio":"",
     "timestamp":timestamp
   });
   await followersReference.document(googleSignIn.currentUser.id).collection("userFollowers").document(googleSignIn.currentUser.id).setData(
     {
         
     }
   );
   documentSnapshot = await usersReference.document(googleSignIn.currentUser.id).get();
}

 currentUser = User.fromDocument(documentSnapshot);
}

void dispose()
{
  pageController.dispose();
  super.dispose();
}

  Scaffold buildHomeScreen()
  {
    return Scaffold(
     key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          //  RaisedButton.icon(   onPressed: signOutGoogle,    icon: Icon(Icons.close),    label: Text("Sign Out")),
           // The above is for testing purpose
          TimeLinePage(gcurrentUser: currentUser),
          SearchPage(),
          UploadPage(gcurrentUser: currentUser,),
          NotificationsPage(),
          ProfilePage(userProfileId:currentUser.id),
        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        activeColor: Colors.white,
        inactiveColor: Colors.blueGrey,
        backgroundColor: Theme.of(context).accentColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size :37.0)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),

        ]
       
      ),
    );

    
}
 
  Widget buildSignedInScreen()
  {
   return Scaffold(
     body:Container(
       decoration: BoxDecoration(
         gradient: LinearGradient(
           begin: Alignment.topRight,
           end: Alignment.bottomLeft,
           colors: [Theme.of(context).accentColor,Theme.of(context).primaryColor],

         )
       ),
       alignment: Alignment.center,
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         crossAxisAlignment: CrossAxisAlignment.center,
         children: <Widget>[
          Text("Buddies Gram",
          style: TextStyle(
            fontSize:52.0, color: Colors.white
            ,fontFamily: "Signatra"
          ),
          ),
          GestureDetector(
            onTap: signInWithGoogle,
            child: Container(
              width: 270,
              height: 65.0,
              decoration: BoxDecoration(
                image:DecorationImage(
                  image: AssetImage("assets/images/google_signin_button.png") ,
                  fit: BoxFit.cover,
                )
              ),
            ),
          )
         ],
       ),
     )
   );
  }
  
@override
  Widget build(BuildContext context) {
    if(isSignedIn)
    {
     return buildHomeScreen();
    }
    else
    {
      return buildSignedInScreen();
    }
  }  

}


















// loginUser()
// {
//  googleSignIn.signIn();
// }


// logoutUser()
// {
//   googleSignIn.signOut();
// }
