import 'package:flutter/material.dart';

import '../db/db/db.dart';
import '../db/models/words.dart';
import '../global_widget/app_bar.dart';
import '../global_widget/text_field_builder.dart';
import '../global_widget/toast.dart';
import '../sipsak_metod.dart';

class AddWordPage extends StatefulWidget {
  final int ?listID;
  final String ?listName;
  const AddWordPage(this.listID,this.listName,{super.key});

  @override
  State<AddWordPage> createState() => _AddWordPageState(listID: listID,listName: listName);
}

class _AddWordPageState extends State<AddWordPage> {
  int ?listID;
  String ?listName;
  _AddWordPageState({@required this.listID, @required this.listName});

  List<Row> wordListField=[];
  List<TextEditingController> wordEditingList=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for(int i=0; i<6; i++){
      wordEditingList.add(TextEditingController());
    }
    for(int i=0; i<3; i++){
      wordListField.add(
          Row(
            children: [
              Expanded(child: textFieldBuilder(textEditingController: wordEditingList[2*i])),
              Expanded(child: textFieldBuilder(textEditingController: wordEditingList[2*i+1]))
            ],
          )
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(
            context,
            left:const Icon(Icons.arrow_back_ios,color: Colors.black,size: 22,),
            center:Text(listName!,style: const TextStyle(fontFamily: "carter",fontSize: 22,color: Colors.black),),
            right: Image.asset("assets/images/logo.png",height: 35,width: 35,),
            leftWidgetOnClick: ()=>{
              Navigator.pop(context)
            }
        ),
        body: SafeArea(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20,bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text("İngilizce",style: TextStyle(fontSize: 18,fontFamily:"RobotoRegular"),),
                      Text("Türkçe",style: TextStyle(fontSize: 18,fontFamily:"RobotoRegular"),)
                    ],
                  ),
                ),
                Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: wordListField,
                      ),
                    )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    actionBtn(addRow, Icons.add),
                    actionBtn(save, Icons.save),
                    actionBtn(delete, Icons.remove)

                  ],
                )
              ],
            ),
          ),
        )
    );
  }

  InkWell actionBtn(Function() click,IconData icon){
    return InkWell(
      onTap: ()=>click(),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(bottom: 15,top: 5),
        decoration: BoxDecoration(
            color: Color(SipsakMetod.HexaColorConverter("#DCD2FF")),
            shape: BoxShape.circle
        ),
        child: Icon(icon,size: 28,),
      ),
    );
  }

  void addRow(){
    wordEditingList.add(TextEditingController());
    wordEditingList.add(TextEditingController());

    wordListField.add(
        Row(
          children: [
            Expanded(child: textFieldBuilder(textEditingController: wordEditingList[wordEditingList.length-2])),
            Expanded(child: textFieldBuilder(textEditingController: wordEditingList[wordEditingList.length-1])),
          ],
        )
    );

    setState(() {
      wordListField;
    });
  }
  void save() async{

      int counter =0;
      bool notEmptyPair=false;

      for(int i=0; i<wordEditingList.length/2;i++){
        String eng=wordEditingList[2*i].text;
        String tr=wordEditingList[2*i+1].text;

        if(eng.isNotEmpty && tr.isNotEmpty){
          counter++;
        }
        else{
          notEmptyPair=true;
        }
      }

      if(counter>=1){
        if(!notEmptyPair){
          for(int i=0; i<wordEditingList.length/2;i++){
            String eng=wordEditingList[2*i].text;
            String tr=wordEditingList[2*i+1].text;

            Word word =await DB.instance.insertWord(Word(list_id:listID,word_eng: eng,word_tr:tr,status: false));
            debugPrint("${word.id} ${word.list_id} ${word.word_eng} ${word.word_tr} ${word.status}");
          }
          toastMessage("EKLEME BAŞARILI");
          wordEditingList.forEach((element) {
            element.clear();
          });
        }
        else{
          toastMessage("LÜTFEN BOŞ ALANLARI SİLİN VEYA DOLDURUN");
        }
      }
      else{
        toastMessage("MİNUMUM 1 ÇİFT DOLU OLMALI");
      }
    }


  void delete(){
    if(wordListField.length!=1){

      wordEditingList.removeAt(wordEditingList.length-1);
      wordEditingList.removeAt(wordEditingList.length-1);

      wordListField.removeAt(wordListField.length-1);

      setState(() {
        wordListField;
      });
    }
    else{
      toastMessage("MİNUMUM 1 ÇİFT OLMALI");
    }
  }
}
