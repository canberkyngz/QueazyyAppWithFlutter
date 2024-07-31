import 'package:flutter/material.dart';
import 'package:sozluk_projesi/db/db/db.dart';
import 'package:sozluk_projesi/db/db/shared_preferences.dart';
import 'package:sozluk_projesi/global_widget/global_variable.dart';
import 'package:sozluk_projesi/global_widget/toast.dart';
import 'package:sozluk_projesi/sipsak_metod.dart';

import '../db/models/words.dart';
import '../global_widget/app_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';

class WordsCardPage extends StatefulWidget {
  const WordsCardPage({super.key});

  @override
  State<WordsCardPage> createState() => _WordsCardPageState();

}

class _WordsCardPageState extends State<WordsCardPage> {

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
  List<bool> changeLang = [];

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
      for (int i = 0; i < _words.length; ++i) {
        changeLang.add(true);
      }

      if (listMixed) _words.shuffle();
      start = true;

      setState(() {
        _words;
        start;
      });
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
          center: const Text("Kelime Kartları", style: TextStyle(
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
              itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                String word = "";
                if(chooseLang == Lang.tr)
                {
                  word=changeLang[itemIndex]?(_words[itemIndex].word_tr!):(_words[itemIndex].word_eng!);
                }
                else
                {
                  word=changeLang[itemIndex]?(_words[itemIndex].word_eng!):(_words[itemIndex].word_tr!);
                }
                return Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: ()
                              {
                                if (changeLang[itemIndex] == true) {
                                  changeLang[itemIndex] = false;
                                }
                                else {
                                  changeLang[itemIndex] = true;
                                }

                                setState(() {
                                  changeLang[itemIndex];
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width:double.infinity,
                                margin: const EdgeInsets.only(left: 16,right: 16,bottom: 16,top: 0),
                                padding: const EdgeInsets.only(left: 4,right: 4,top: 10),
                                decoration: BoxDecoration(
                                  color: Color(SipsakMetod.HexaColorConverter("#DCD2FF")),
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Text(word,style:const TextStyle(fontFamily:"RobotoRegular",fontSize: 28,color: Colors.black),),
                              ),
                            ),
                            Positioned(left: 30,top: 10,child: Text("${itemIndex+1}/${_words.length}",style:const TextStyle(fontFamily:"RobotoRegular",fontSize: 16,color: Colors.black),),)
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
}
