import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  @override
  State<HomePage> createState() {
  return HomePageState();
  }

}
class HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor:   Color(0xFF000047),
   );
  }

}