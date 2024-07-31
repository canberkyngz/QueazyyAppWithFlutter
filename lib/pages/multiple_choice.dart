import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sozluk_projesi/db/db/db.dart';
import 'package:sozluk_projesi/global_widget/global_variable.dart';
import 'package:sozluk_projesi/global_widget/toast.dart';
import 'package:sozluk_projesi/sipsak_metod.dart';

import '../db/db/shared_preferences.dart';
import '../db/models/words.dart';
import '../global_widget/app_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MultipleChoicePage extends StatefulWidget {
  const MultipleChoicePage({super.key});

  @override
  State<MultipleChoicePage> createState() => _MultipleChoicePage();

}

class _MultipleChoicePage extends State<MultipleChoicePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLists().then((value){
      setState(() {
        lists;
      });
    });
  }


  List<Word> _words = [];
  bool start = false;

  List<List<String>> optionsList=[];  //kelime listesi uzunluğu kadar şık listesi,Her şık listesinde 4 şık olacak.
  List<String> correctAnswers=[]; //Her kelime için doğru cevap listede tutulacak.
  List<bool> clickControl=[]; // Her kelimeye ait şıklardan herhangi biri işaretlendi mi kontrolü yapılacak.
  List<List<bool>> clickControlList=[]; //Hangi şıkkın işaretlendiğini kontrol edecek.

  int correctCount=0; //doğru sayısı
  int wrongCount=0; // hatalı saysı


  void getSelectedWordOfLists(List<int> selectedListID) async {

    List<String> value= selectedListID.map((e) => e.toString()).toList();
    SP.write("selected_list", value);

    if (chooseQuestionType == Which.learned) {
      _words = await DB.instance.readWordByLists(selectedListID, status: true);
    }
    else if (chooseQuestionType == Which.unlearned) {
      _words = await DB.instance.readWordByLists(selectedListID, status: false);
    }
    else {
      _words = await DB.instance.readWordByLists(selectedListID);
    }

    if (_words.isNotEmpty) {

      if(_words.length>3){
        if (listMixed) _words.shuffle();

        Random random=Random();
        for(int i=0; i<_words.length;++i){
          clickControl.add(false); //Her bir kelime için cevap verilip verilmediğinin kontrolu
          clickControlList.add([false,false,false,false]); // her kelime için 4 şık var, 4 şıkkıında işaretlendiğini belirten 4 adet false ile doldurdum.

          List<String> tempOptions=[];

          while(true)
          {
            int rand=random.nextInt(_words.length); // 0 ile (kelime saysı -1)
            if(rand !=i)
            {
              bool isThereSame= false;

              for (var element in tempOptions) {
                if(chooseLang==Lang.eng)
                {
                  if(element==_words[rand].word_tr!)
                  {
                    isThereSame=true;
                  }
                }
                else
                {
                  if(element==_words[rand].word_eng!)
                  {
                    isThereSame=true;
                  }
                }

              }

              if(!isThereSame) tempOptions.add(chooseLang==Lang.eng?_words[rand].word_tr!:_words[rand].word_eng!);
            }

            if(tempOptions.length==3)
            {
              break;
            }
          }
          tempOptions.add(chooseLang==Lang.eng?_words[i].word_tr!:_words[i].word_eng!); // bu işlem doğru cevabı hep son indexe ekler.
          tempOptions.shuffle();    // bu işlem ile tempOptions listesinin yerlerini karıştırdık.
          correctAnswers.add(chooseLang==Lang.eng?_words[i].word_tr!:_words[i].word_eng!);
          optionsList.add(tempOptions);
        }
        start = true;
        setState(() {
          _words;
          start;
        });
      }
      else{
        toastMessage("Minumum 4 kelime gereklidir.");
      }

    }
    else {
      toastMessage("Seçilen şartlarda liste boş");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          context,
          left: const Icon(
            Icons.arrow_back_ios, color: Colors.black, size: 22,),
          center: const Text("Çoktan Seçmeli", style: TextStyle(
              fontFamily: "carter", fontSize: 22, color: Colors.black),),
          right: Image.asset("assets/images/logo.png", height: 40,),
          leftWidgetOnClick: () =>
          {
            Navigator.pop(context)
          }
      ),
      body: SafeArea(
          child: start == false ? Container(
            width: double.infinity,
            margin: const EdgeInsets.only(
                left: 16, right: 16, bottom: 16, top: 0),
            padding: const EdgeInsets.only(left: 4, right: 4, top: 10),
            decoration: BoxDecoration(
              color: Color(SipsakMetod.HexaColorConverter("#DCD2FF")),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              children: [
                whichRadioButton(
                    text: "Öğrendiklerimi Sor", value: Which.learned),
                whichRadioButton(
                    text: "Öğrenmediklerimi Sor", value: Which.unlearned),
                whichRadioButton(text: "Hepsini Sor", value: Which.all),
                checkBox(text: "Listeyi Karıştır", fWhat: forWhat.forListMixed),
                const SizedBox(height: 20,),
                const Divider(color: Colors.black, thickness: 1,),
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("Listeler", style: TextStyle(
                      fontFamily: "RobotoRegular",
                      fontSize: 18,
                      color: Colors.black),),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: 8, right: 8, bottom: 10, top: 10),
                  height: 200,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1)
                  ),
                  child: Scrollbar(
                    thickness: 5,
                    //isAlwaysShown: true,
                    thumbVisibility: true,
                    child: ListView.builder(itemBuilder: (context, index) {
                      return checkBox(
                          index: index, text: lists[index]['name'].toString());
                    }, itemCount: lists.length,),
                  ),
                ),
                Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(right: 20),
                    child: InkWell(
                      onTap: () {
                        List<int> selectedIndexNoOfList = [];
                        for (int i = 0; i < selectedListIndex.length; ++i) {
                          if (selectedListIndex[i] == true) {
                            selectedIndexNoOfList.add(i);
                          }
                        }

                        List<int> selectedListIdList = [];
                        for (int i = 0; i < selectedIndexNoOfList.length; ++i) {
                          selectedListIdList.add(
                              lists[selectedIndexNoOfList[i]]['list_id'] as int);
                        }

                        if (selectedListIdList.isNotEmpty) {
                          getSelectedWordOfLists(selectedListIdList);
                        }
                        else {
                          toastMessage("Lütfen Liste seçin");
                        }
                      },
                      child: const Text("Başla", style: TextStyle(
                          fontFamily: "RobotoRegular",
                          fontSize: 18,
                          color: Colors.black),),
                    )
                )
              ],
            ),
          ) : CarouselSlider.builder(
              options: CarouselOptions(
                  height: double.infinity
              ),
              itemCount: _words.length,
              itemBuilder: (BuildContext context, int itemIndex,
                  int pageViewIndex) {
                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            width:double.infinity,
                            margin: const EdgeInsets.only(left: 16,right: 16,bottom: 16,top: 0),
                            padding: const EdgeInsets.only(left: 4,right: 4,top: 10),
                            decoration: BoxDecoration(
                              color: Color(SipsakMetod.HexaColorConverter("#DCD2FF")),
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:[
                                  Text(chooseLang==Lang.eng?_words[itemIndex].word_eng!:_words[itemIndex].word_tr!,style:const TextStyle(fontFamily:"RobotoRegular",fontSize: 28,color: Colors.black),),
                                  const SizedBox(height: 15,),
                                  customRadioButtonList(itemIndex, optionsList[itemIndex], correctAnswers[itemIndex])
                                ] ),
                          ),
                          Positioned(left: 40,top: 10,child: Text("${itemIndex+1}/${_words.length}",style:const TextStyle(fontFamily:"RobotoRegular",fontSize: 16,color: Colors.black),),),
                          Positioned(left: 220,top: 10,child: Text("D:$correctCount/Y:$wrongCount",style:const TextStyle(fontFamily:"RobotoRegular",fontSize: 16,color: Colors.black),),)
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: CheckboxListTile(
                          title: const Text("Öğrendim"),
                          value: _words[itemIndex].status,
                          onChanged: (value){
                            _words[itemIndex]= _words[itemIndex].copy(status: value);
                            DB.instance.markAsLearned(value!, _words[itemIndex].id as int);
                            toastMessage(value? "Öğrenildi olarak işaretlendi.":"Öğrenilmedi olarak işaretlendi");

                            setState(() {
                              _words[itemIndex];
                            });
                          }
                      ),
                    )
                  ],
                );
              }
          )
      ),
    );
  }

  SizedBox whichRadioButton({@required String ?text, @required Which ?value}) {
    return SizedBox(
      width: 275,
      height: 32,
      child: ListTile(
        title: Text(
          text!, style: const TextStyle(fontFamily: "RobotoRegular", fontSize: 18),),
        leading: Radio<Which>(
          value: value!,
          groupValue: chooseQuestionType,
          onChanged: (Which ?value) {
            setState(() {
              chooseQuestionType = value;
            });

            switch(value)
            {
              case Which.learned:
                SP.write("which", 0);
                break;
              case Which.unlearned:
                SP.write("which", 1);
                break;
              case Which.all:
                SP.write("which", 2);
                break;
              default:
                break;
            }
          },
        ),
      ),
    );
  }

  SizedBox checkBox(
      {int index = 0, String ?text, forWhat fWhat = forWhat.forList}) {
    return SizedBox(
      width: 270,
      height: 35,
      child: ListTile(
        title: Text(text!,
          style: const TextStyle(fontFamily: "RobotRegular", fontSize: 18),),
        leading: Checkbox(
          checkColor: Colors.white,
          activeColor: Colors.deepPurpleAccent,
          hoverColor: Colors.blueAccent,
          value: fWhat == forWhat.forList
              ? selectedListIndex[index]
              : listMixed,
          onChanged: (bool ?value) {
            setState(() {
              if (fWhat == forWhat.forList) {
                selectedListIndex[index] = value!;
              }
              else {
                listMixed = value!;
                SP.write("mix", value);
              }
            });
          },
        ),
      ),
    );
  }

  Container customRadioButton(int index,List<String> options,int order){
    Icon check= const Icon(Icons.radio_button_checked_outlined,size: 16,);
    Icon uncheck= const Icon(Icons.radio_button_off_outlined,size: 16,);
    return Container(
      margin: const EdgeInsets.all(4),
      child: Row(
        children: [
          clickControlList[index][order]==false ? uncheck:check,
          const SizedBox(width: 10,),
          Text(options[order],style: const TextStyle(fontSize: 18),)
        ],
      ),
    );
  }

  Column customRadioButtonList(int index,List<String> options, String correctAnswer){

    Divider divider=const Divider(thickness: 1,height: 1,);

    return Column(
      children: [
        divider,
        InkWell(
          onTap: ()=>toastMessage("Lütfen Seçmek için çift tıklayın"),
          onDoubleTap: ()=>checker(index,0,options,correctAnswer),
          child: customRadioButton(index,options,0),
        ),
        divider,
        InkWell(
          onTap: ()=>toastMessage("Lütfen Seçmek için çift tıklayın"),
          onDoubleTap: ()=>checker(index,1,options,correctAnswer),
          child: customRadioButton(index,options,1),
        ),
        divider,
        InkWell(
          onTap: ()=>toastMessage("Lütfen Seçmek için çift tıklayın"),
          onDoubleTap: ()=>checker(index,2,options,correctAnswer),
          child: customRadioButton(index,options,2),
        ),
        divider,
        InkWell(
          onTap: ()=>toastMessage("Lütfen Seçmek için çift tıklayın"),
          onDoubleTap: ()=>checker(index,3,options,correctAnswer),
          child: customRadioButton(index,options,3),
        )
      ],
    );
  }

  void checker(index,order,options,correctAnswer)
  {
     if(clickControl[index] == false){
       clickControl[index]= true;
       setState(() {
         clickControlList[index][order]=true;
       });

       if(options[order] == correctAnswer){
         correctCount++;
       }
       else{
         wrongCount++;
       }

       if((correctCount + wrongCount) == _words.length){
         toastMessage("Test Biti.");
       }
     }
  }

}
