import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/EditProfilePage.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/PostTileWidget.dart';
import 'package:buddiesgram/widgets/PostWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;
  ProfilePage({this.userProfileId});
  
  @override
  _ProfilePageState createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {

final String currentOnlineUserId = currentUser?.id; 
bool loading = false;
int countPost = 0;
List <Post> postsList = [];
String postOrientation = "grid";
int countTotalFollowers;
int countTotalFollowings;
bool following = false;

void  initState()
{
  super.initState();
  getAllProfilePosts();
  getAllFollowers();
  getAllFollowing();
  checkIfAlreadyFollowing();
}

  checkIfAlreadyFollowing()async
   {
     DocumentSnapshot documentSnapshot = await followersReference.document(widget.userProfileId).collection("userFollowers").document(currentOnlineUserId).get();
     setState(() {
       following = documentSnapshot.exists;
     });
   }

    getAllFollowing()  async
    {
      QuerySnapshot querySnapshot = await  followingReference.document(widget.userProfileId).collection("userFollowing").getDocuments();
      setState(() {
        countTotalFollowings = querySnapshot.documents.length;
      });
    }
   
   getAllFollowers()  async
    {
      QuerySnapshot querySnapshot = await  followersReference.document(widget.userProfileId).collection("userFollowers").getDocuments();
      setState(() {
        countTotalFollowers = querySnapshot.documents.length;
      });
    }

 createProfileTopView()
 {
   return FutureBuilder(
     future: usersReference.document(widget.userProfileId).get(),
     builder: (context,dataSnapshot)
     {
       if (!dataSnapshot.hasData)
       {
         return circularProgress();
       }
       User user = User.fromDocument(dataSnapshot.data);
       return Padding(
         padding: EdgeInsets.all(17.0),
         child: Column(
           children: <Widget>[
             Row(
               children: <Widget>[
                 CircleAvatar(
                   radius: 45.0,
                   backgroundColor: Colors.grey,
                   backgroundImage: CachedNetworkImageProvider(user.url),

                 ),
                 Expanded(
                   child: Column(
                     children: <Widget>[
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         mainAxisSize: MainAxisSize.max,
                         children: <Widget>[
                           createColumn("posts",countPost),
                           createColumn("followers",countTotalFollowers),
                           createColumn("following",countTotalFollowings),
                         ],
                       ),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         children: <Widget>[
                           createButton(),
                         ],
                       )
                     ],
                   ) 
                 )
               ],
             ),
             Container(
               alignment: Alignment.centerLeft,
               padding: EdgeInsets.only(top:13.0),
               child: Text(
                 user.username,
                 style: TextStyle(fontSize: 14.0,color:Colors.white),
               ),
             ),
             Container(
               alignment: Alignment.centerLeft,
               padding: EdgeInsets.only(top:5.0),
               child: Text(
                 user.profileName,
                 style: TextStyle(fontSize: 18.0,color:Colors.white),
               ),
             ),
             Container(
               alignment: Alignment.centerLeft,
               padding: EdgeInsets.only(top:3.0),
               child: Text(
                 user.bio,
                 style: TextStyle(fontSize: 18.0,color:Colors.white70),
               ),
             ),
           ],
         ),
       );
     }
     
     );
 }

 createButton()
 {
 bool ownProfile = currentOnlineUserId == widget.userProfileId;
 if(ownProfile)
 {
  return createButtonTitleAndFunction(title:"Edit Profile", performFunction:editUserProfile);
  }
  if(following)
 {
  return createButtonTitleAndFunction(title:"Unfollow", performFunction:controlUnfollowUser);
  }
  if(!following)
 {
  return createButtonTitleAndFunction(title:"Follow", performFunction:controlFollowUser);
  }
 }


controlUnfollowUser()
{
  setState(() {
    following = false;
  });
  followersReference.document(widget.userProfileId).collection("userFollowers").document(currentOnlineUserId).
  get().then((doc) {

    if(doc.exists)
    {
      doc.reference.delete();
    }
  });
  followingReference.document(currentOnlineUserId).collection("userFollowing").document(widget.userProfileId).
  get().then((doc) {

    if(doc.exists)
    {
      doc.reference.delete();
    }
  });

  activityFeedReference.document(widget.userProfileId).collection("feedItems").document(currentOnlineUserId).get()
  .then((doc) {
    if (doc.exists)
    {
      doc.reference.delete();
    }
  } );
}

controlFollowUser()
{
  setState(() {
    following = true;
  });
  followersReference.document(widget.userProfileId).collection("userFollowers").document(currentOnlineUserId).setData({

  });
  followingReference.document(currentOnlineUserId).collection("userFollowing").document(widget.userProfileId).setData({

  });
  activityFeedReference.document(widget.userProfileId).collection("feedItems").document(currentOnlineUserId).setData({
    "type":"follow",
    "ownerId":widget.userProfileId,
    "username":currentUser.username,
    "timestamp":DateTime.now(),
    "userProfileImg":currentUser.url,
    "userId":currentOnlineUserId
  });
}

createButtonTitleAndFunction({String title, Function performFunction})
{
  return Container(
    padding: EdgeInsets.only(top:3.0),
    child: FlatButton(
      onPressed: performFunction,
       child: Container(
         width:245.0,
         height: 26.0,
         child: Text(title,style:TextStyle(color: following ? Colors.grey: Colors.white70, fontWeight: FontWeight.bold )),
         alignment: Alignment.center,
         decoration: BoxDecoration(color:following  ? Colors.black: Colors.white70,
         border:Border.all(color: following ? Colors.grey:Colors.white70),
         borderRadius: BorderRadius.circular(6.0),
         ),
         
       )
       
       ),
  );
}


Column createColumn(String title,int count)
{
return Column(
 mainAxisSize: MainAxisSize.min,
 mainAxisAlignment: MainAxisAlignment.center,
 children: <Widget>[
   Text(
     count.toString(),
     style: TextStyle(fontSize: 20.0,color:Colors.white,fontWeight: FontWeight.bold),

   ),
   Container(
     margin: EdgeInsets.only(top:5.0),
     child: 
     Text(
       title,
       style: TextStyle(fontSize: 20.0,color:Colors.white,fontWeight: FontWeight.bold),
     ),
   )
 ],
);


}


editUserProfile()
{
  Navigator.push(context, 
  MaterialPageRoute(builder: (content)=> EditProfilePage(currentOnlineUserId:currentOnlineUserId))
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,strTitle: "Profile"),
      body:ListView(
        children: <Widget>[
          createProfileTopView(),
          Divider(height: 0.0,),
          createListAndGridPostOrientation(),
          Divider(),
          displayProfilePost(),
        ],
      ),
    );
  }
        
        
        displayProfilePost()
        {
          if(loading)
          {
            return circularProgress();
          }
          else if (postsList.isEmpty)
          {
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Icon(Icons.photo_library,color: Colors.grey,size:200.0),),
                    Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No Posts", style:TextStyle(color:Colors.redAccent,fontSize: 40.0,fontWeight: FontWeight.bold,)))                    
                ],
              ),
            );
          }
          else if (postOrientation == "grid")
          {
            List<GridTile> gridTile = [];
            postsList.forEach((eachPost) {
               gridTile.add(GridTile(child: PostTile(eachPost),));
             });
            return GridView.count(crossAxisCount: 3,
             childAspectRatio: 1.0,
             mainAxisSpacing: 1.5,
             crossAxisSpacing: 1.5,
             shrinkWrap: true,
             physics: NeverScrollableScrollPhysics(),
             children: gridTile,
            );
          }
           else if (postOrientation == "list")
          {
              return Column(
              children: postsList
          );
          }
        
        }
     getAllProfilePosts() async
     { 
       setState(() {
         loading = true;
       });
      QuerySnapshot querySnapshot = await postsReference.document(widget.userProfileId).collection("userPosts").orderBy("timestamp",descending:true ).getDocuments();
      setState(() {
        loading = false;
        countPost = querySnapshot.documents.length;
        postsList = querySnapshot.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
      });
     }
     createListAndGridPostOrientation()
     {
       return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.grid_on),
                color: postOrientation == "grid" ? Theme.of(context).primaryColor:Colors.grey,
                 onPressed: ()=> setOrientation("grid")),
              IconButton(
                icon: Icon(Icons.list),
                color: postOrientation == "list" ? Theme.of(context).primaryColor:Colors.grey,
                 onPressed: ()=> setOrientation("list")),
            ],
       );
     }
 setOrientation(String orientation)
 {
   setState(() {
     this.postOrientation = orientation;
   });
 }
}
