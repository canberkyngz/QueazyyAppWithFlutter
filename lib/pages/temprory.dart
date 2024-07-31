import 'package:flutter/material.dart';
import 'package:sozluk_projesi/db/db/shared_preferences.dart';
import 'package:sozluk_projesi/global_widget/global_variable.dart';
import 'package:sozluk_projesi/pages/main.dart';

class TemproryPage extends StatefulWidget {
  const TemproryPage({super.key});

  @override
  State<TemproryPage> createState() => _TemproryPageState();
}

class _TemproryPageState extends State<TemproryPage> {
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    Future.delayed(const Duration(seconds: 2),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const MainPAge()));
    });

    spRead();
  }

  void spRead() async {
    if (await SP.read('lang') == true) {
      chooseLang = Lang.eng;
    }
    else {
      chooseLang = Lang.tr;
    }

    switch(await SP.read('which')){
      case 0:
        chooseQuestionType=Which.learned;
        break;
      case 1:
        chooseQuestionType=Which.unlearned;
        break;
      case 2:
        chooseQuestionType=Which.all;
        break;
    }

    if(await SP.read('mix') == false){
      listMixed=false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Image.asset("assets/images/logo.png"),
                    const Padding(
                        padding: EdgeInsets.all(15.0),
                        child:Text("QUEAZY",style: TextStyle(color: Colors.black,fontFamily:"Luck",fontSize: 40 ),) ,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child:Text("İstediğinizi Öğrenin",style: TextStyle(color: Colors.black,fontFamily:"Carter",fontSize: 25 ),) ,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




