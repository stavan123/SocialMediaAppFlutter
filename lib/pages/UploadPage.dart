// import 'dart:html';

import 'dart:io';

import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;

class UploadPage extends StatefulWidget {
  
  

final User gcurrentUser;
UploadPage({this.gcurrentUser});
  @override
  _UploadPageState createState() => _UploadPageState();

}




class _UploadPageState extends State<UploadPage>  with AutomaticKeepAliveClientMixin
{
TextEditingController descriptionTextEditingController = TextEditingController();
TextEditingController locationTextEditingController = TextEditingController();
File file;
bool uploading = false;
String postId = Uuid().v4();
captureImageWithCamera() async
{
Navigator.pop(context);

final pickedFile  = await ImagePicker().getImage(source: ImageSource.camera,maxHeight: 600,maxWidth: 970);
setState(() {
  this.file = File(pickedFile.path);
});

}

pickImageFromGallery()
async
{
  Navigator.pop(context);
  final pickedFile  = await ImagePicker().getImage(source: ImageSource.gallery);
  setState(() {
  this.file = File(pickedFile.path);
});

}


takeImage(mContext)
{
  return showDialog(context: mContext,
  builder: (context)
  {
    return SimpleDialog(
      title: Text("New Post",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
      children: <Widget>[
        SimpleDialogOption(
          child: Text("Capture Image with camera",style: TextStyle(color: Colors.white),),
          onPressed: captureImageWithCamera ,
        ),
        SimpleDialogOption(
          child: Text("Select Image from Gallery",style: TextStyle(color: Colors.white),),
          onPressed: pickImageFromGallery,
        ),
        SimpleDialogOption(
          child: Text("Cancel",style: TextStyle(color: Colors.white),),
          onPressed: ()=> Navigator.pop(context),
        ),
      ],

    );

  }
  );
}



compressingPhoto() async
{
 final tDirectory = await getTemporaryDirectory();
 final path = tDirectory.path;
 ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
 final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(ImD.encodeJpg(mImageFile,quality: 60));
 setState(() {
   file = compressedImageFile;
  // file = file;
 });
}

controlUploadAndSave () async{

  setState(() {
    uploading = true;
  });


await compressingPhoto();  

String downloadUrl = await uploadPhoto(file);
//put the url in firestore
savePostInfoToFireStore(url: downloadUrl,location: locationTextEditingController.text,description:descriptionTextEditingController.text);
locationTextEditingController.clear();
descriptionTextEditingController.clear();
setState(() {
  
  file = null;
  uploading = false;
  postId = Uuid().v4();
});
}


savePostInfoToFireStore({String url, String location, String description})
{
 postsReference.document(widget.gcurrentUser.id).collection("userPosts").document(postId).setData(
   {"postId":postId,
     "ownerId": widget.gcurrentUser.id,
     "timestamp":DateTime.now(),
     "likes":{},
     "username":widget.gcurrentUser.username,
     "description":description,
     "location": location,
      "url":url,
   }
 );
}


// Uploading the file to the fire base storage and gets its download url
Future <String> uploadPhoto(mImageFile) async
{
  StorageUploadTask  mStorageUploadTask =  storageReference.child("post_$postId.jpg").putFile(mImageFile);
  StorageTaskSnapshot storageTaskSnapshot = await mStorageUploadTask.onComplete;
  String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
  return downloadUrl;
}

 displayUploadScreen()
 {
   return Container(
     color: Theme.of(context).accentColor.withOpacity(0.5),
     child: Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children: <Widget>[
         Icon(Icons.add_a_photo,
         color: Colors.grey,
         size: 200.0,         
         ),
         Padding(
           padding: EdgeInsets.only(top:20.0),
           child: RaisedButton(
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
             child: Text("Upload Image",style: TextStyle(color: Colors.white,fontSize: 20.0),),
             color: Colors.green,
             onPressed: () =>takeImage(context)                  
           ),
         ),
       ],
     ),
   );
 }




clearPostInfo()
{
  locationTextEditingController.clear();
  descriptionTextEditingController.clear();
  setState(() {
    file = null;
  });
}


getUserCurrentLocation()async
{
Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
List<Placemark> placeMarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
Placemark mPlaceMark = placeMarks[0];
//String completeAddressInfo = '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare},${mPlaceMark.subLocality} ${mPlaceMark.locality} ,${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea},${mPlaceMark.postalCode} ${mPlaceMark.country}';
String specificAddress = '${mPlaceMark.locality},${mPlaceMark.country}';
locationTextEditingController.text = specificAddress;

}


Scaffold displayUploadFormScreen()
{
  print(file);
  return Scaffold(
     appBar: AppBar(
       backgroundColor: Colors.black,
       leading: IconButton(icon: Icon(Icons.arrow_back) ,
       color: Colors.white, 
       onPressed: clearPostInfo),//clearPostInfo()),
       title: Text("New Post",style: TextStyle(fontSize:24.0 ,color: Colors.white,fontWeight: FontWeight.bold),),
       actions: <Widget>[
         FlatButton(

           onPressed: uploading ? null : ()=> controlUploadAndSave(),
     child: Text("Share",style:TextStyle(color: Colors.lightGreenAccent,fontWeight: FontWeight.bold,fontSize: 16.0),)
         ),        
       ],
       
     ),
     body: ListView(
       children: <Widget>[
         uploading ? linearProgress() : Text(" "),
         Container(
           height: 230.0,
           width: MediaQuery.of(context).size.width * 0.8,
           child: Center(
             child: AspectRatio(
               aspectRatio: 16/9,
               
               child: Container(
                 decoration: BoxDecoration(image:DecorationImage(image:FileImage(file),fit: BoxFit.cover,)),
                
               ) ,
             ),
           ),
         ),
         Padding(
           padding: EdgeInsets.only(top:12.0),),
         ListTile(
           leading:CircleAvatar(backgroundImage:CachedNetworkImageProvider(widget.gcurrentUser.url,)),
           title: Container(
             width: 250.0,
             child: TextField(
               style:TextStyle(
                 color: Colors.white,                
               ),
               controller:descriptionTextEditingController,
               decoration: InputDecoration(
                 hintText: "Say Something About Your image",
                 hintStyle: TextStyle(
                   color: Colors.white
                 ),
                 border:InputBorder.none,
               ),
             ),
           ),
         ),
         Divider(),
         ListTile(
           leading:Icon(Icons.person_pin_circle,color: Colors.white,size: 36.0,),
           title: Container(
             width: 250.0,
             child: TextField(
               style:TextStyle(
                 color: Colors.white,                
               ),
               controller:locationTextEditingController,
               decoration: InputDecoration(
                 hintText: "Write The Location here",
                 hintStyle: TextStyle(
                   color: Colors.white
                 ),
                 border:InputBorder.none,
               ),
             ),
           ),
         ),
         Container(
           width: 220.0,
           height: 111.0,
           alignment: Alignment.center,
           child: RaisedButton.icon(
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
             color: Colors.green,
             
             icon: Icon(Icons.location_on,color: Colors.white,), 
             label: Text("Get my current location",style: TextStyle(color:Colors.white),),
             onPressed: getUserCurrentLocation, 
             
             ),
            
         )
       ],
     ),
  );
}
 bool get wantKeepAlive =>true;

  @override
  Widget build(BuildContext context) {
    return file == null?  displayUploadScreen(): displayUploadFormScreen();
  }
}
