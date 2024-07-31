import 'package:flutter/material.dart';
import 'package:sozluk_projesi/db/db/db.dart';
import 'package:sozluk_projesi/db/models/lists.dart';
import 'package:sozluk_projesi/db/models/words.dart';
import 'package:sozluk_projesi/global_widget/app_bar.dart';
import 'package:sozluk_projesi/global_widget/toast.dart';
import 'package:sozluk_projesi/sipsak_metod.dart';

import '../global_widget/text_field_builder.dart';

class CreateList extends StatefulWidget {
  const CreateList({super.key});

  @override
  State<CreateList> createState() => _CreateListState();
}

class _CreateListState extends State<CreateList> {
  final _listName=TextEditingController();

  List<Row> wordListField=[];
  List<TextEditingController> wordEditingList=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for(int i=0; i<10; i++){
      wordEditingList.add(TextEditingController());
    }
    for(int i=0; i<5; i++){
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
          center: Image.asset("assets/images/logo_text.png"),
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
              textFieldBuilder(icon: const Icon(Icons.list,size: 18),hintText:"Liste Adı",textEditingController: _listName,textAlign: TextAlign.left),
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

   if(_listName.text.isNotEmpty){
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

     if(counter>=4){
       if(!notEmptyPair){
         Lists addedList=await DB.instance.insertList(Lists(name: _listName.text));

         for(int i=0; i<wordEditingList.length/2;i++){
           String eng=wordEditingList[2*i].text;
           String tr=wordEditingList[2*i+1].text;

           Word word =await DB.instance.insertWord(Word(list_id: addedList.id,word_eng: eng,word_tr:tr,status: false));
           debugPrint("${word.id} ${word.list_id} ${word.word_eng} ${word.word_tr} ${word.status}");
         }
         toastMessage("LİSTE OLUŞTURULDU");
         _listName.clear();
         wordEditingList.forEach((element) {
           element.clear();
         });
       }
       else{
         toastMessage("LÜTFEN BOŞ ALANLARI SİLİN VEYA DOLDURUN");
       }
     }
     else{
       toastMessage("MİNUMUM 4 ÇİFT DOLU OLMALI");
     }
   }
   else{
     toastMessage("LÜTFEN LİSTE ADI GİRİNİZ!");
   }

  }
  void delete(){
    if(wordListField.length!=4){

        wordEditingList.removeAt(wordEditingList.length-1);
        wordEditingList.removeAt(wordEditingList.length-1);

        wordListField.removeAt(wordListField.length-1);

        setState(() {
          wordListField;
        });
    }
    else{
      toastMessage("MİNUMUM 4 ÇİFT OLMALI");
    }
  }


}
