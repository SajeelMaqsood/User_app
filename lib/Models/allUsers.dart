import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Users
{
  String? id;
  String? email;
  String? name;
  String? phone;
  String? payment_method;
  String? UrlImage;
  String? Cnic;
  String? AccountNo;



  Users({this.id,this.name,this.phone,this.email,this.UrlImage,this.Cnic,this.AccountNo});

  Users.fromSnapshot(DataSnapshot? dataSnapshot)
  {

      id= dataSnapshot!.key;
      email=dataSnapshot.child('email').value.toString();
      name=dataSnapshot.child('name').value.toString();
      phone=dataSnapshot.child('phone').value.toString();
      UrlImage=dataSnapshot.child("User_details").child("user_image").value.toString();
      Cnic=dataSnapshot.child("User_details").child("user_cnic").value.toString();
      AccountNo=dataSnapshot.child("User_details").child("user_Account").value.toString();



  }
}