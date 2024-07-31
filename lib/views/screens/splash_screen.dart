import 'dart:async';

import 'package:flutter/material.dart';
import 'package:khata_app/views/screens/users_screen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
navToNext(){
  Timer.periodic(const Duration(seconds: 3), ((duration){
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const UsersScreen()));
  }));
}
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    navToNext();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(height: 300,
              width:250 ,
              child: Image.asset("assets/images/splash_logo.jpeg",
              fit: BoxFit.cover,),),
            )
          ],
        ),
      )),
    );
  }
}