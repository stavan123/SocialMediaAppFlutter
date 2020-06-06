import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/PostWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';

class TimeLinePage extends StatefulWidget {
  final User gcurrentUser;
  TimeLinePage({this.gcurrentUser});
  
  @override 
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  List<Post> posts;
  List<Post> posts1;
  
  List<Post> postsfoll;

  List<String> followingList = [];
  
  final _scaffoldKey = GlobalKey<ScaffoldState>();
 
  retrieveTimeLine() async
  {
    //  QuerySnapshot querySnapshot = await timelineReference.document(widget.gcurrentUser.id).collection("timelinePosts").orderBy("timestamp",descending: true).getDocuments();
         QuerySnapshot querySnapshot = await postsReference.document(widget.gcurrentUser.id).collection("userPosts").orderBy("timestamp",descending:true ).getDocuments();

    List <Post> allPosts = querySnapshot.documents.map((document) => Post.fromDocument(document)).toList();
    print("Myarea");
    print(allPosts.toString());
    setState(() {
      this.posts  = allPosts;
    });
  }
   

   retrieveFollowing() async
   {
         QuerySnapshot querySnapshot = await followingReference.document(currentUser.id).collection("userFollowing").getDocuments();
   
           followingList = querySnapshot.documents.map((doc) => doc.documentID).toList();

           for (var item in followingList) {
             print(item);
                QuerySnapshot querySnapshot1 = await postsReference.document(item).collection("userPosts").orderBy("timestamp",descending:true ).getDocuments();         
                 postsfoll = querySnapshot1.documents.map((document) => Post.fromDocument(document)).toList();
           
                      setState(() {
                  followingList = querySnapshot.documents.map((doc) => doc.documentID).toList();    
                        this.posts  = postsfoll;


    });

           }
  
          
          print("following");
          
     

   }

   @override
   void initState()
   {
     super.initState();
     retrieveTimeLine();
     retrieveFollowing();

   }

   createUserTimeLine()
   {
     if (posts == null)
     {
       return circularProgress();
     }
     else
     {
       return ListView(
          children: posts
          
       );
     }
   }

  
  @override
  Widget build(context) {
    return Scaffold(
      key: _scaffoldKey,
      
      appBar: header(context, isAppTitle: true),
      
      body: RefreshIndicator(
        child: createUserTimeLine(),
        onRefresh: () => retrieveTimeLine(),),

    );
  }
}
