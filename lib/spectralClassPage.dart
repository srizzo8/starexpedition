import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:starexpedition4/registerPage.dart';
import 'package:starexpedition4/firebaseDesktopHelper.dart';

import 'loginPage.dart';
import 'login_information/loginStatus.dart';
import 'main.dart' as myMain;

String mySpectralClass = "";
bool fromSpectralClassPage = false;

enum mySpectralClassStarSortingCriteria { alphabeticalAToZ, alphabeticalZToA, distanceClosestToFurthest, distanceFurthestToClosest, temperatureCoolestToHottest, temperatureHottestToCoolest }

class spectralClassPage extends StatefulWidget{
  const spectralClassPage({Key? key}) : super(key: key);

  @override
  spectralClassPageState createState() => spectralClassPageState();
}

class spectralClassPageState extends State<spectralClassPage> with RouteAware{
  static String nameOfRoute = '/spectralClassPage';
  List<String> spectralClassOfStars = [];
  var scpNumberOfStars = myMain.starsForSearchBar.length;
  List<String> spectralClassCount = [];
  bool b = false;

  bool mSpectralClassCountNavigation = false;
  bool kSpectralClassCountNavigation = false;
  bool gSpectralClassCountNavigation = false;
  bool fSpectralClassCountNavigation = false;
  bool aSpectralClassCountNavigation = false;
  bool bSpectralClassCountNavigation = false;
  bool oSpectralClassCountNavigation = false;

  @override
  Future <List<String>> getSpectralClassData() async{
    List<String> spectralClasses = [];
    for(int i = 0; i < scpNumberOfStars; i++) {
      if(firebaseDesktopHelper.onDesktop){
        final spectralClassRef = await firebaseDesktopHelper.getFirebaseData(myMain.starsForSearchBar[i].starName!);
        var spectralClassSnapshot = spectralClassRef["spectral_class"];
        spectralClasses.add(spectralClassSnapshot.toString());
      }
      else{
        final spectralClassRef = FirebaseDatabase.instance.ref(myMain.starsForSearchBar[i].starName!);
        var spectralClassSnapshot = await spectralClassRef.child("spectral_class").get();
        spectralClasses.add(spectralClassSnapshot.value.toString());
      }
    }

    return spectralClasses;
  }

  @override
  Future<List<String>> generateSpectralClasses() async{
    int countMStars = 0;
    int countKStars = 0;
    int countGStars = 0;
    int countFStars = 0;
    int countAStars = 0;
    int countBStars = 0;
    int countOStars = 0;

    List<String> gscSpectralClassesOfStars = [];
    gscSpectralClassesOfStars = await getSpectralClassData();

    print(gscSpectralClassesOfStars);
    for(int i = 0; i < gscSpectralClassesOfStars.length; i++)
    {
      String mySpectralClass = gscSpectralClassesOfStars[i];
      print(mySpectralClass[0]);
      switch(mySpectralClass[0])
      {
        case 'M':
          countMStars++;
          break;
        case 'K':
          countKStars++;
          break;
        case 'G':
          countGStars++;
          break;
        case 'F':
          countFStars++;
          break;
        case 'A':
          countAStars++;
          break;
        case 'B':
          countBStars++;
          break;
        case 'O':
          countOStars++;
          break;
      }
    }
    return [countMStars.toString(), countKStars.toString(), countGStars.toString(), countFStars.toString(), countAStars.toString(), countBStars.toString(), countOStars.toString()];
  }

  void getDataForMyLists() async{
    spectralClassOfStars = await getSpectralClassData();
    spectralClassCount = await generateSpectralClasses();
    setState(() {
      b = true;
    });
  }

  @override
  void initState() {
    getDataForMyLists();
    super.initState();
  }

  //Lifecycle methods (didChangeDependencies() and dispose()):
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    myMain.routesToOtherPages.myRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose(){
    myMain.routesToOtherPages.myRouteObserver.unsubscribe(this);
    super.dispose();
  }

  //RouteAware methods (didPopNext() and didPush()):
  @override
  void didPopNext(){
    //Called when returning to this page:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  void didPush(){
    //Called when the page is pushed:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  Widget build(BuildContext bc) {
    if(b == true) {
      print('spectralClassOfStars in build method: ' + spectralClassOfStars.toString());
      print('spectralClassCount in build method: ' + spectralClassCount.toString());
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
      ),
      body: spectralClassOfStars.isEmpty || spectralClassCount.isEmpty? Center(child: CircularProgressIndicator()):
      SingleChildScrollView(
        child: Wrap(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Center(
            child: Container(
              child: Text("Spectral Classes of Stars", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015625),
            child: Text("This page has information regarding each star spectral class. "
                "To see a list of stars that have articles on Star Expedition that belong to a certain spectral class, click the number in the \"Stars with Articles\" column.", textAlign: TextAlign.center),
          ),
          Center(
            child: DataTable(
              columnSpacing: 30.0,
              columns: [
                DataColumn(label: Expanded(
                  child: Center(
                    child: Text('Spectral\nClass', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0.sp)),
                  ),
                  ),
                ),
                DataColumn(label: Expanded(
                  child: Center(
                    child: Text('Temperature', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0.sp)),
                  ),
                  ),
                ),
                DataColumn(label: Expanded(
                  child: Center(
                    child: Text('Stars with\nArticles', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0.sp)),
                  ),
                  ),
                ),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('M'),
                  ),
                  ),
                  DataCell(
                    SizedBox(
                      width: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.height * 0.33333 : 125,
                      child: Align(
                      //alignment: Alignment.center,
                        child: Text('2500-3800 K'),
                      ),
                    ),
                  ),
                  //DataCell(Text('Proxima Centauri')),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: AbsorbPointer(
                      absorbing: mSpectralClassCountNavigation,
                        child: GestureDetector(
                          child: Text(spectralClassCount[0].toString(), style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)),
                          onTap: (){
                            if(mSpectralClassCountNavigation){
                              return;
                            }

                            setState(() => mSpectralClassCountNavigation = true);

                            print("You clicked me!");
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                            mySpectralClass = "M";

                            if(mounted){
                              setState(() => mSpectralClassCountNavigation = false);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('K'),
                  ),
                  ),
                  DataCell(
                    SizedBox(
                      width: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.height * 0.33333 : 125,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text('3800-5300 K'),
                      ),
                    ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: AbsorbPointer(
                      absorbing: kSpectralClassCountNavigation,
                      child: GestureDetector(
                        child: Text(spectralClassCount[1].toString(), style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)),
                        onTap: (){
                          if(kSpectralClassCountNavigation){
                            return;
                          }

                          setState(() => kSpectralClassCountNavigation = true);

                          print('You clicked me!');
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                          mySpectralClass = "K";

                          if(mounted){
                            setState(() => kSpectralClassCountNavigation = false);
                          }
                        },
                      ),
                    ),
                  ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('G'),
                  ),
                  ),
                  DataCell(
                    SizedBox(
                      width: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.height * 0.33333 : 125,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text('5300-6000 K'),
                      ),
                    ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: AbsorbPointer(
                      absorbing: gSpectralClassCountNavigation,
                      child: GestureDetector(
                        child: Text(spectralClassCount[2].toString(), style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)),
                        onTap: (){
                          if(gSpectralClassCountNavigation){
                            return;
                          }

                          setState(() => gSpectralClassCountNavigation = true);

                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                          mySpectralClass = "G";

                          if(mounted){
                            setState(() => gSpectralClassCountNavigation = false);
                          }
                        },
                      ),
                    ),
                  ),
                  ),      //Text(spectralClassCount[2].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))),
                ]),
                DataRow(cells: [
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('F'),
                  ),
                  ),
                  DataCell(
                    SizedBox(
                      width: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.height * 0.33333 : 125,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text('6000-7300 K'),
                      ),
                    ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                      child: AbsorbPointer(
                        absorbing: fSpectralClassCountNavigation,
                        child: GestureDetector(
                          child: Text(spectralClassCount[3].toString(), style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)),
                          onTap: (){
                            if(fSpectralClassCountNavigation){
                              return;
                            }

                            setState(() => fSpectralClassCountNavigation = true);

                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                            mySpectralClass = "F";

                            if(mounted){
                              setState(() => fSpectralClassCountNavigation = false);
                            }
                          },
                        ),
                      ),
                    )
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('A'),
                  ),
                  ),
                  DataCell(
                    SizedBox(
                      width: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.height * 0.33333 : 125,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text('7300-10000 K'),
                      ),
                    ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                      child: AbsorbPointer(
                        absorbing: aSpectralClassCountNavigation,
                        child: GestureDetector(
                          child: Text(spectralClassCount[4].toString(), style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)),
                          onTap: (){
                            if(aSpectralClassCountNavigation){
                              return;
                            }

                            setState(() => aSpectralClassCountNavigation = true);

                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                            mySpectralClass = "A";

                            if(mounted){
                              setState(() => aSpectralClassCountNavigation = false);
                            }
                          },
                        ),
                      ),
                    )
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('B'),
                  ),
                  ),
                  DataCell(
                    SizedBox(
                      width: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.height * 0.33333 : 125,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text('10000-30000 K'),
                      ),
                    ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                      child: AbsorbPointer(
                        absorbing: bSpectralClassCountNavigation,
                        child: GestureDetector(
                          child: Text(spectralClassCount[5].toString(), style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)),
                          onTap: (){
                            if(bSpectralClassCountNavigation){
                              return;
                            }

                            setState(() => bSpectralClassCountNavigation = true);

                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                            mySpectralClass = "B";

                            if(mounted){
                              setState(() => bSpectralClassCountNavigation = false);
                            }
                          },
                        ),
                      ),
                    )
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('O'),
                  ),
                  ),
                  DataCell(
                    SizedBox(
                      width: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.height * 0.33333 : 125,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text('30000+ K'),
                      ),
                    ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                      child: AbsorbPointer(
                        absorbing: oSpectralClassCountNavigation,
                        child: GestureDetector(
                          child: Text(spectralClassCount[6].toString(), style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)),
                          onTap: (){
                            if(oSpectralClassCountNavigation){
                              return;
                            }

                            setState(() => oSpectralClassCountNavigation = true);

                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                            mySpectralClass = "O";

                            if(mounted){
                              setState(() => oSpectralClassCountNavigation = false);
                            }
                          },
                        ),
                      ),
                    )
                  ),
                ]),
              ],
            ),
          ),
          Center(
            child: Container(
              child: Text("\nSources", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Center(
            child: Container(
              child: Text("https://www.handprint.com/ASTRO/specclass.html", textAlign: TextAlign.center),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
        ],
      ),
      ),
      drawer: myMain.starExpeditionNavigationDrawer(),
    );
  }
}

class listForSpectralClassesPage extends StatefulWidget{
  const listForSpectralClassesPage({Key? key}) : super(key: key);

  @override
  listForSpectralClassesPageState createState() => listForSpectralClassesPageState();
}

class listForSpectralClassesPageState extends State<listForSpectralClassesPage> with RouteAware{

  List<myMain.myStars> mStars = [];
  List<myMain.myStars> kStars = [];
  List<myMain.myStars> gStars = [];
  List<myMain.myStars> fStars = [];
  List<myMain.myStars> aStars = [];
  List<myMain.myStars> bStars = [];
  List<myMain.myStars> oStars = [];
  List<List<myMain.myStars>> fullListOfStars = [];
  bool switchOn = false;
  myMain.myStars clickedStar = myMain.myStars(starName: "not available");

  ValueNotifier<mySpectralClassStarSortingCriteria> mySpectralClassStarSortingCriteriaNotifier = ValueNotifier(mySpectralClassStarSortingCriteria.alphabeticalAToZ);

  bool starNavigationFromSpectralClassPageList = false;
  bool goingBackFromSpectralClassPageList = false;
  bool activatingStarSorter = false;

  @override
  Future<List<List<myMain.myStars>>> getStars() async{
    List<myMain.myStars> getMStars = [];
    List<myMain.myStars> getKStars = [];
    List<myMain.myStars> getGStars = [];
    List<myMain.myStars> getFStars = [];
    List<myMain.myStars> getAStars = [];
    List<myMain.myStars> getBStars = [];
    List<myMain.myStars> getOStars = [];

    for(int i = 0; i < myMain.starsForSearchBar.length; i++) {
      print('Current star: ' + myMain.starsForSearchBar[i].starName!.toString());

      String starSnapshotString = "";

      if(firebaseDesktopHelper.onDesktop){
        final starsWithSpectralClassRef = await firebaseDesktopHelper.getFirebaseData(myMain.starsForSearchBar[i].starName!);
        var starSnapshot = starsWithSpectralClassRef["spectral_class"];
        starSnapshotString = starSnapshot.toString();
      }
      else{
        final starsWithSpectralClassRef = FirebaseDatabase.instance.ref(myMain.starsForSearchBar[i].starName!);
        var starSnapshot = await starsWithSpectralClassRef.child("spectral_class").get();
        starSnapshotString = starSnapshot.value.toString();
      }
      String starSnapshotSpectralClass = starSnapshotString[0];

      switch(starSnapshotSpectralClass){
        case "M":
          getMStars.add(myMain.starsForSearchBar[i]);
          break;
        case "K":
          getKStars.add(myMain.starsForSearchBar[i]);
          break;
        case "G":
          getGStars.add(myMain.starsForSearchBar[i]);
          break;
        case "F":
          getFStars.add(myMain.starsForSearchBar[i]);
          break;
        case "A":
          getAStars.add(myMain.starsForSearchBar[i]);
          break;
        case "B":
          getBStars.add(myMain.starsForSearchBar[i]);
          break;
        case "O":
          getOStars.add(myMain.starsForSearchBar[i]);
          break;
      }
    }

    //Sorting stars of each spectral class alphabetically
    getMStars.sort((s1, s2) => s1.starName!.toLowerCase().compareTo(s2.starName!.toLowerCase()));
    getKStars.sort((s1, s2) => s1.starName!.toLowerCase().compareTo(s2.starName!.toLowerCase()));
    getGStars.sort((s1, s2) => s1.starName!.toLowerCase().compareTo(s2.starName!.toLowerCase()));
    getFStars.sort((s1, s2) => s1.starName!.toLowerCase().compareTo(s2.starName!.toLowerCase()));
    getAStars.sort((s1, s2) => s1.starName!.toLowerCase().compareTo(s2.starName!.toLowerCase()));
    getBStars.sort((s1, s2) => s1.starName!.toLowerCase().compareTo(s2.starName!.toLowerCase()));
    getOStars.sort((s1, s2) => s1.starName!.toLowerCase().compareTo(s2.starName!.toLowerCase()));

    return [getMStars, getKStars, getGStars, getFStars, getAStars, getBStars, getOStars];
  }

  void mySortMatchQuery(List<myMain.myStars> mySpectralClassMatchQuery){
    switch(mySpectralClassStarSortingCriteriaNotifier.value){
      case mySpectralClassStarSortingCriteria.alphabeticalAToZ:
        mySpectralClassMatchQuery.sort((a, b) => a.starName!.compareTo(b.starName!));
        break;
      case mySpectralClassStarSortingCriteria.alphabeticalZToA:
        mySpectralClassMatchQuery.sort((a, b) => b.starName!.compareTo(a.starName!));
        break;
      case mySpectralClassStarSortingCriteria.distanceClosestToFurthest:
        mySpectralClassMatchQuery.sort((a, b) => (myMain.myStarDistanceInLightYearsMap[a.starName!] ?? double.infinity).compareTo(myMain.myStarDistanceInLightYearsMap[b.starName!] ?? double.infinity));
        break;
      case mySpectralClassStarSortingCriteria.distanceFurthestToClosest:
        mySpectralClassMatchQuery.sort((a, b) => (myMain.myStarDistanceInLightYearsMap[b.starName!] ?? double.infinity).compareTo(myMain.myStarDistanceInLightYearsMap[a.starName!] ?? double.infinity));
        break;
      case mySpectralClassStarSortingCriteria.temperatureCoolestToHottest:
        mySpectralClassMatchQuery.sort((a, b) => (myMain.myStarTemperatureInKelvinMap[a.starName!] ?? double.infinity).compareTo(myMain.myStarTemperatureInKelvinMap[b.starName!] ?? double.infinity));
        break;
      case mySpectralClassStarSortingCriteria.temperatureHottestToCoolest:
        mySpectralClassMatchQuery.sort((a, b) => (myMain.myStarTemperatureInKelvinMap[b.starName!] ?? double.infinity).compareTo(myMain.myStarTemperatureInKelvinMap[a.starName!] ?? double.infinity));
        break;
    }
  }

  void getListOfStars() async{
    fullListOfStars = await getStars();
    setState((){
      switchOn = true;
    });
  }

  @override
  void initState(){
    getListOfStars();

    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await myMain.addingToStarMaps();
    });

    super.initState();
  }

  //Lifecycle methods (didChangeDependencies() and dispose()):
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    myMain.routesToOtherPages.myRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose(){
    myMain.routesToOtherPages.myRouteObserver.unsubscribe(this);
    super.dispose();
  }

  //RouteAware methods (didPopNext() and didPush()):
  @override
  void didPopNext(){
    //Called when returning to this page:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  void didPush(){
    //Called when the page is pushed:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  Widget build(BuildContext context){
    final myLoginStatus = context.watch<loginStatus>();

    if(switchOn == true) {
      print('This is fullListOfStars: ' + fullListOfStars.toString());
      print("Method being utilized: ${fullListOfStars[indexPlaceSpectralClass()]}");
    }

    List<String> informationAboutClickedStar = [];

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text("Star Expedition"),
          leading: AbsorbPointer(
            absorbing: goingBackFromSpectralClassPageList,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                if(goingBackFromSpectralClassPageList){
                  return;
                }

                setState(() => goingBackFromSpectralClassPageList = true);

                Navigator.push(context, MaterialPageRoute(builder: (context) => spectralClassPage()));

                if(mounted){
                  setState(() => goingBackFromSpectralClassPageList = false);
                }
              }
          )
        ),
      ),
      body: fullListOfStars.isEmpty? Center(child: CircularProgressIndicator()):
      Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(10.0),
            child: Text("List of stars with articles that belong to the " + mySpectralClass + " spectral class", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          AbsorbPointer(
            absorbing: activatingStarSorter,
            child: IconButton(
              icon: Icon(Icons.sort),
              tooltip: "Sort star by",
              onPressed: (){
                if(activatingStarSorter){
                  return;
                }

                setState(() => activatingStarSorter = true);

                //Temporary variable to hold a user's selection inside the dialog:
                mySpectralClassStarSortingCriteria mySpectralClassTemporaryCriteria = mySpectralClassStarSortingCriteriaNotifier.value;

                showDialog(
                    context: context,
                    builder: (BuildContext bc){
                      return StatefulBuilder(
                          builder: (context, setDialogState){
                            return AlertDialog(
                              title: Text("Sort stars by"),
                              content: DropdownButtonHideUnderline(
                                child: DropdownButton<mySpectralClassStarSortingCriteria>(
                                  value: mySpectralClassTemporaryCriteria,
                                  isExpanded: true,
                                  items: [
                                    DropdownMenuItem(
                                      value: mySpectralClassStarSortingCriteria.alphabeticalAToZ,
                                      child: Text("Alphabetical A to Z (default)"),
                                    ),
                                    DropdownMenuItem(
                                      value: mySpectralClassStarSortingCriteria.alphabeticalZToA,
                                      child: Text("Alphabetical Z to A"),
                                    ),
                                    DropdownMenuItem(
                                      value: mySpectralClassStarSortingCriteria.distanceClosestToFurthest,
                                      child: Text("Distance (from closest to furthest in light-years)"),
                                    ),
                                    DropdownMenuItem(
                                      value: mySpectralClassStarSortingCriteria.distanceFurthestToClosest,
                                      child: Text("Distance (from furthest to closest in light-years)"),
                                    ),
                                    DropdownMenuItem(
                                      value: mySpectralClassStarSortingCriteria.temperatureCoolestToHottest,
                                      child: Text("Temperature (from coolest to hottest in Kelvin)"),
                                    ),
                                    DropdownMenuItem(
                                      value: mySpectralClassStarSortingCriteria.temperatureHottestToCoolest,
                                      child: Text("Temperature (from hottest to coolest in Kelvin)"),
                                    ),
                                  ],
                                  onChanged: (myValue){
                                    if(myValue != null){
                                      setDialogState(() => mySpectralClassTemporaryCriteria = myValue);
                                    }
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: (){
                                    mySpectralClassStarSortingCriteriaNotifier.value = mySpectralClassTemporaryCriteria;
                                    print("This is mySpectralClassStarSortingCriteriaNotifier.value: ${mySpectralClassStarSortingCriteriaNotifier.value}");
                                    Navigator.of(bc).pop();
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                      );
                    }
                );
                if(mounted){
                  setState(() => activatingStarSorter = false);
                }
              }
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          switchOn?
            (fullListOfStars[indexPlaceSpectralClass()].length > 0? Expanded(
              child: ValueListenableBuilder<mySpectralClassStarSortingCriteria>(
                valueListenable: mySpectralClassStarSortingCriteriaNotifier,
                builder: (context, mySpectralClassStarSortingCriteria, _){
                  return ListView.builder(
                    itemCount: fullListOfStars[indexPlaceSpectralClass()].length,
                    itemBuilder: (context, index){
                      mySortMatchQuery(fullListOfStars[indexPlaceSpectralClass()]);
                      return AbsorbPointer(
                        absorbing: starNavigationFromSpectralClassPageList,
                        child: ListTile(
                          title: Text(fullListOfStars[indexPlaceSpectralClass()][index].starName!, textAlign: TextAlign.center),
                          onTap: () async{
                            if(starNavigationFromSpectralClassPageList){
                              return;
                            }

                            setState(() => starNavigationFromSpectralClassPageList = true);

                            myMain.correctStar = fullListOfStars[indexPlaceSpectralClass()][index].starName!;
                            print(myMain.correctStar);
                            clickedStar.starName = myMain.correctStar;
                            print(clickedStar.starName);

                            informationAboutClickedStar = await myMain.getStarInformation();
                            print(informationAboutClickedStar);
                            fromSpectralClassPage = true;

                            myMain.starFileContent = await myMain.readStarFile();

                            myMain.listOfStarUrls = [];

                            final myLines = myMain.starFileContent.replaceAll("\r\n", "\n").replaceAll("\r", "\n").split("\n").where((s) => s.isNotEmpty && s != " ").toList();

                            Map<int, String> myTitles = {};

                            for(int i = 0; i < myLines.length; i++){
                              if(myLines[i].contains("||")){
                                final parts = myLines[i].split("||");
                                myMain.listOfStarUrls.add(parts[0].trim());
                                myTitles[i] = parts[1].trim();
                              }
                              else{
                                myMain.listOfStarUrls.add(myLines[i]);
                              }
                            }

                            myMain.urlTitlesForStars = await Future.wait(List.generate(myMain.listOfStarUrls.length, (i){
                                if(myTitles.containsKey(i)){
                                  return Future.value(myTitles[i]);
                                }
                                return myMain.getTitleOfPage(myMain.listOfStarUrls[i]);
                              })
                            );

                            //Is a user tracking this star?
                            if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                              if(firebaseDesktopHelper.onDesktop){
                                List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersProfileInfo["usernameProfileInformation"] ?? {});

                                myMain.starTracked = currentInfoOfUser?["starsTracked"].containsKey(myMain.correctStar);
                                print("starTracked: ${myMain.starTracked}");
                              }
                              else{
                                var theUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                var docNameForUsers;
                                theUser.docs.forEach((result){
                                  docNameForUsers = result.id;
                                });

                                DocumentSnapshot<Map<dynamic, dynamic>> snapshotUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForUsers).get();
                                Map<dynamic, dynamic>? individual = snapshotUsers.data();

                                myMain.starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(myMain.correctStar);
                                print("starTracked: ${myMain.starTracked}");
                              }
                            }

                            myMain.myAccessCheckNotifier.value = DateTime.now();
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => myMain.articlePage(informationAboutClickedStar), settings: RouteSettings(arguments: clickedStar)));

                            if(mounted){
                              setState(() => starNavigationFromSpectralClassPageList = false);
                            }
                          },
                          leading: Image.asset(myMain.starsForSearchBar[myMain.starsForSearchBar.indexWhere((star) => star.starName! == fullListOfStars[indexPlaceSpectralClass()][index].starName!)].imagePath!, fit: BoxFit.cover, height: 50, width: 50),
                        ),
                      );
                    },
                  );
                }
              ),
            ): Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.031250, 0.0, MediaQuery.of(context).size.width * 0.031250, 0.0), child: Container(child: Text("Unfortunately, there are no stars with articles that belong to the ${mySpectralClass} spectral class.", textAlign: TextAlign.center,)))
          ): Container(),
        ],
      ),
      drawer: myMain.starExpeditionNavigationDrawer(),
    );
  }

  int indexPlaceSpectralClass(){
    int myIndexPlace = 0;
    switch(mySpectralClass) {
      case "M":
        myIndexPlace = 0;
        break;
      case "K":
        myIndexPlace = 1;
        break;
      case "G":
        myIndexPlace = 2;
        break;
      case "F":
        myIndexPlace = 3;
        break;
      case "A":
        myIndexPlace = 4;
        break;
      case "B":
        myIndexPlace = 5;
        break;
      case "O":
        myIndexPlace = 6;
        break;
    }

    return myIndexPlace;
  }
}