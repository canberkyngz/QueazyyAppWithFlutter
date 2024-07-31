import 'package:flutter/material.dart';
import 'package:sozluk_projesi/db/db/shared_preferences.dart';
import 'package:sozluk_projesi/pages/lists.dart';
import 'package:sozluk_projesi/pages/multiple_choice.dart';
import 'package:sozluk_projesi/pages/words_card.dart';
import 'package:sozluk_projesi/sipsak_metod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../global_widget/app_bar.dart';
import '../global_widget/global_variable.dart';
import "package:google_mobile_ads/google_mobile_ads.dart";

class MainPAge extends StatefulWidget {
  const MainPAge({super.key});

  @override
  State<MainPAge> createState() => _MainPAgeState();
}

const _url = 'https://Google.com';
class _MainPAgeState extends State<MainPAge> {

  final AdManagerBannerAd myBanner = AdManagerBannerAd(
     adUnitId: 'ca-app-pub-3940256099942544/6300978111', //test
  //  adUnitId: 'ca-app-pub-2200542301865818/1370505881', //canlıya aldığım zaman kullancam
    sizes:[AdSize.mediumRectangle],
    request: AdManagerAdRequest(),
    listener:AdManagerBannerAdListener(),
  );

  final AdManagerBannerAdListener listener = AdManagerBannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => print('Ad loaded'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error){
      ad.dispose();
      print('AdManagerBannerAd failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => print('Ad closed'),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) => print('Ad impression'),
  );
  final GlobalKey<ScaffoldState> _scaffoldKey=GlobalKey<ScaffoldState>();
  PackageInfo ?packageInfo;
  String version="";

  Container ?adContainer=Container();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MobileAds.instance.initialize();
    packageInfoInit();
    myBanner.load().then((value){
      final AdWidget adWidget = AdWidget(ad: myBanner);
      adContainer=Container(
        margin:const EdgeInsets.only(top: 50),
        alignment: Alignment.center,
        width: double.infinity,
        height: 250,
        child: adWidget,
      );

      setState(() {
        adContainer;
      });
    });
  }

  void deneme() async
  {
    SP.write("int", 3).then((value) async{
      int veri=await SP.read("int") as int;
      debugPrint("GELEN VERİ: $veri");
    });
  }


  void packageInfoInit() async{
    packageInfo=await PackageInfo.fromPlatform();
    setState(() {
      version=packageInfo!.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width*0.5,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Image.asset("assets/images/logo.png",height: 80,),
                  const Text("QUEZY",style: TextStyle(fontSize: 26,fontFamily: "RobotoLight"),),
                  const Text("İstediğini Öğren",style: TextStyle(fontSize: 16,fontFamily: "RobotoLight"),),
                  SizedBox(width:MediaQuery.of(context).size.width*0.35,child: const Divider(color: Colors.black,),),
                  Container(
                    margin: const EdgeInsets.only(top: 50,right: 8,left: 8),
                    child: const Text("Bu uygulamaların nasıl yapıldığını öğrenmek ve bu tarz uygulamalar geliştirmek için",textAlign: TextAlign.center,),
                  ),
                  InkWell(
                    onTap: ()  async{
                           await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
                    },
                    child:Text("Tıkla",style: TextStyle(fontFamily:"RobotoLight",fontSize: 16,color:Color(SipsakMetod.HexaColorConverter("#0A588D"))),),
                  )
                ],
              ),
              Padding(
                  padding:const EdgeInsets.all(8.0),
                  child: Text("V$version\ncyangaz81@gmail.com",style: TextStyle(fontFamily:"RobotoLight",fontSize: 14,color:Color(SipsakMetod.HexaColorConverter("#0A588D"))),textAlign: TextAlign.center,)
              )
            ],
          ),
        ),
      ),
      appBar:appBar(context,
      left: const FaIcon(FontAwesomeIcons.bars,color: Colors.black,size: 20,),
      center: Image.asset("assets/images/logo_text.png"),
        leftWidgetOnClick: ()=>{_scaffoldKey.currentState!.openDrawer()}
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    langRadioButton(text: "İngilizce-Türkçe",group: chooseLang, value: Lang.eng),
                    langRadioButton(text: "Türkçe-İngilizce",group: chooseLang, value: Lang.tr),
                    const SizedBox(height: 30),
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const ListsPage()));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 55,
                        margin: const EdgeInsets.only(bottom: 20),
                        width: MediaQuery.of(context).size.width*0.8,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Color( SipsakMetod.HexaColorConverter("#7D20A6")),
                                Color( SipsakMetod.HexaColorConverter("#481183")),
                              ],
                              tileMode: TileMode.repeated,
                            )
                        ),
                        child: const Text("Listelerim", style: TextStyle(fontSize: 28,fontFamily:"Carter", color: Colors.white)),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          card(context,title:"Kelime\nKartlari",startColor: "#1DACC9",endColor: "#0C33B2",click:(){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>const WordsCardPage()));
                          }),
                          card(context,title:"Çoktan\nSeçmeli",startColor: "#FF3348",endColor: "#B029B9",click: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>const MultipleChoicePage()));
                          }),
                        ],
                      ),
                    ),
                    adContainer!
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }

  InkWell card(BuildContext context,{@required String ?startColor,@required String ?endColor,@required String ?title, @required Function() ?click}) {
    return InkWell(
      onTap:click,
      child: Container(
                        alignment: Alignment.center,
                        height: 200,
                        width: MediaQuery.of(context).size.width*0.37,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Color( SipsakMetod.HexaColorConverter(startColor!)),
                                Color( SipsakMetod.HexaColorConverter(endColor!)),
                              ],
                              tileMode: TileMode.repeated,
                            )
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children:  [
                            Text(title!, style: const TextStyle(fontSize: 28,fontFamily:"Carter", color: Colors.white),textAlign: TextAlign.center,),
                            const Icon(Icons.file_copy,size: 32,color: Colors.white,)
                          ],
                        ),
                      ),
    );
  }

  SizedBox langRadioButton({@required String ?text,required  Lang value, @required Lang ?group}) {
    return SizedBox(
                width: 250,
                height: 30,
                child: ListTile(
                  contentPadding:  const EdgeInsets.all(0),
                  title: Text(text!, style: const TextStyle(fontFamily:"Carter",fontSize: 15),),
                  leading: Radio<Lang>(
                    value:value,
                    groupValue: chooseLang,
                    onChanged: (Lang? value){
                      setState(() {
                        chooseLang=value;
                      });

                      //TRUE => İNGİLİZCEDEN TÜRKÇE
                      //FALSE => TÜRKÇEDEN İNGİLİZCE

                      if(value == Lang.eng){
                        SP.write("lang", true);
                      }
                      else{
                        SP.write("lang", false);
                      }
                    },
                  ),
                ),
              );
  }
}

