import 'dart:async';

import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:flutter/material.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;

 submitUserName()
 {
  final form = _formKey.currentState;
  if(form.validate())
  {
    form.save();
    SnackBar snackBar =  SnackBar(content: Text("Welcome "+ username));
    _scaffoldKey.currentState.showSnackBar(snackBar);
    Timer(Duration(seconds: 4), (){
     Navigator.pop(context,username);
    });
  }
 }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,strTitle: "Settings",disappearBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Text("Set Up a UserName",style: TextStyle(fontSize: 26.0),),
                ),
                ),
                Padding(padding: EdgeInsets.all(17.0),
                  child: Container(
                    child:Form(
                      key: _formKey,
                      autovalidate: true,
                      child: TextFormField(
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value.trim().length < 5 || value.isEmpty)
                          {
                           return "User Name is invalid";
                          }
                           else  if (value.trim().length >15 || value.isEmpty)
                           {
                             return "User Name is very long";
                           }
                           else
                           {
                             return null;
                           }
                        },
                        onSaved: (newValue) {
                          username = newValue;
                        },
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey
                            ),
                            
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color:Colors.white),
                          ),
                          border: OutlineInputBorder(),
                          labelText: "UserName",
                          labelStyle: TextStyle(fontSize: 16.0),
                          hintText:"Must be Atleast  5 characters",
                          hintStyle: TextStyle(color:Colors.grey),

                        ),
                      ),
                    )
                  ),
                ),
GestureDetector(
  onTap: submitUserName,
  child:Container(
    height: 35.0,
    width:360.0 ,
    decoration: BoxDecoration(
      color:Colors.green,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Center(
      child: Text("Proceed",
      style: TextStyle(
        color:Colors.white,
        fontSize: 16.0,
        fontWeight: FontWeight.bold
      ),),
    ),
  ),
)
              ],
            ),
          )
        ],
      ),
    );
  }
}
