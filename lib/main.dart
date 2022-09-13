import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

/* String myString = "";
FirebaseDatabase database = FirebaseDatabase.instance;
DatabaseReference ref = FirebaseDatabase.instance.ref(myString);*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class myStars{
  String? starName;
  String? imagePath;
  myStars({
    this.starName,
    this.imagePath,
  });
}

List<myStars> starsForSearchBar = [
  myStars(starName: "Proxima Centauri", imagePath: "assets/images/proxima_centauri.jpg"),
  myStars(starName: "Alpha Centauri", imagePath: "assets/images/alpha_centauri.jpg"),
  myStars(starName: "Tau Ceti", imagePath: "assets/images/tau_ceti.jpg"),
  myStars(starName: "Ross 128", imagePath: "assets/images/ross_128.jpg"),
  myStars(starName: "Luyten's Star", imagePath: "assets/images/luytens_star.jpg"),
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This is the root widget
  // of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: StarExpedition(),
    );
  }
}

// This is the widget that will be shown
// as the homepage of your application.
/*_getStars() async {
  // This method gets data for Alpha Centauri from the database. If you did it outside the main class, you will probably not be able to see it. async means that it will run once you press the button or run the function.
  DatabaseEvent event = await ref.once(); //the _getStars() method is for the first button. it is put somewhere where i can call it.
  print(event.snapshot.value);
  // This is where one will print the data of the snapshot (in this case, Alpha Centauri's data)
  //print(event.snapshot.value); // This will show Alpha Centauri's data
}*/

class StarExpedition extends StatefulWidget {
  const StarExpedition({Key? key}) : super(key: key);

  @override
  State<StarExpedition> createState() => _StarExpeditionState();
}

class _StarExpeditionState extends State<StarExpedition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Star Expedition",
        ),
        actions: [
          IconButton(
            onPressed: () {
              // method to show the search bar
              //_getStars(); // I am putting it here is just for testing; it is just to see if we are getting any data from firebase (the data we want, such as data relating to Alpha Centauri).
              showSearch(
                  context: context,
                  // delegate to customize the search bar
                  delegate: CustomSearchDelegate());
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  //String correctStar = "";
  //const CustomSearchDelegate({super.key, required this.starsForSearch});
  // final List<myStars> starsForSearch;
  // This is a demo list to show querying
  // late final myStars outcome;
  /*List<String> searchTerms = [
    "Proxima Centauri",
    "Alpha Centauri",
    "Tau Ceti",
    "Ross 128",
    "Luyten's Star",
    "Kapteyn's Star",
    "Wolf 1061",
    "Gliese 876",
    "Gliese 581",
    "Lacaille 9352",*/
  //];

  /*List<String> theImages = [
    'assets/images/proxima_centauri.jpg',
    'assets/images/alpha_centauri.jpg',
    'assets/images/tau_ceti.jpg',
    'assets/images/ross_128.jpg',
    'assets/images/luytens_star.jpg',
    'assets/images/kapteyns_star.jpg',
    'assets/images/wolf_1061.jpg',
    'assets/images/gliese_876.jpg',
    'assets/images/gliese_581.jpg',
    'assets/images/lacaille_9352.jpg'
  ];*/

  // This is the first overwrite (to clear the search text)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  // This is the second overwrite (to pop out of search menu)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  // This is the third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<myStars> myMatchQuery = [];
    for (var star in starsForSearchBar) {
      if (star.starName!.toLowerCase().contains(query.toLowerCase())) {
        myMatchQuery.add(star!);
      }
    }
    return ListView.builder(
      itemCount: myMatchQuery.length,
      itemBuilder: (context, index) {
        var result = myMatchQuery[index];
        return ListTile(
          title: Text(result.starName!), // The ! is there so that it can prevent errors, especially for variables that are set to null
          /*onTap: () {
            print('Testing pop-up');
            showAlertDialog(context);
          }*/
        );
      },
    );
  }

  // This is the last overwrite (to show the querying process at the runtime)
  @override
  Widget buildSuggestions(BuildContext context) {
    List<myStars> myMatchQuery = [];
    //String correctStar = "";
    /*for (var stars in starsForSearchBar) {
      /*if (stars.toLowerCase().contains(query.toLowerCase())) {
        myMatchQuery.add(stars);
      }*/
    }*/
    for (var star in starsForSearchBar) {
      if (star.starName!.toLowerCase().contains(query.toLowerCase())) {
        myMatchQuery.add(star!);
      }
    }
    return ListView.builder(
      itemCount: myMatchQuery.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(myMatchQuery[index].starName!,
                style: TextStyle(
                    color: Colors.deepPurpleAccent, fontFamily: 'Raleway')),
            onTap: () {
              //correctStar = myMatchQuery[index].starName!;
              print(myMatchQuery[index].starName!);
              //showAlertDialog(context);
             // Navigator.push(context, MaterialPageRoute(builder: (context) => articlePage(ms: ));
              //correctStar = myMatchQuery[index].starName!;
              //Navigator.push(context, new MaterialPageRoute(builder: (context) => articlePage(), arguments: )); // I am trying to use this to push the data from the star search suggestions to the dialog
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => articlePage(), settings: RouteSettings(arguments: myMatchQuery[index])));
              //print(Navigator.push(context, showAlertDialog(context)));
            },
            leading: Image.asset(myMatchQuery[index].imagePath!, height: 50, width: 50, scale: 1.5),
            trailing: Icon(Icons.whatshot_rounded));
      },
    );
  }
}

class articlePage extends StatelessWidget{
  //final myStars ms;
  //articlePage({Key? key, required this.ms}) : super(key:key);
  /*DatabaseReference dr = FirebaseDatabase.instance.ref("Ross 128");

  _getStarInfo() async{
    DatabaseEvent de = await dr.once();
  }*/

  Future<String> getStarData() async{
    DatabaseReference dr = FirebaseDatabase.instance.ref("Luyten's Star");
    DatabaseEvent de = await dr.once();
    return Future.delayed(Duration(seconds: 1), () {
      return de.snapshot.value as String; // Data should be returned from the snapshot.
    });
  }

  @override
  Widget build(BuildContext bc) {
    var info = ModalRoute.of(bc)!.settings;
    myStars theStar;

    //for(theStar in starsForSearchBar){
    theStar = info.arguments as myStars;
    //ref = FirebaseDatabase.instance.ref(theStar.starName!);

    /*Future<Object?> getStarData() async
    {
      return de.snapshot.value;
    }*/

    /*FutureBuilder(
      future: getStarData(),
      builder: (context, mySnapshot){
    },
    );*/

    return Scaffold(
      appBar: AppBar(
        title: Text(theStar.starName!),
      ),
      body: FutureBuilder(
        /*child: Column(children: <Widget>[
          Text("Hello there",
              textAlign:
              TextAlign.left,
              style: TextStyle(
                  color: Colors.deepPurpleAccent, fontFamily: 'Raleway')
          )
        ])*/
        builder: (bc, mySnapshot){
          if(mySnapshot.connectionState == ConnectionState.done){
            if(mySnapshot.hasError){
              return Text("Sorry, an error has occurred. Please try again.");
            }
            else{
              if(mySnapshot.hasData){
                final myData = mySnapshot.data as String;
                return Text('$myData', style: TextStyle(fontSize: 14),);
              }
              else{ // This else statement indicates what happens if the Firebase database returns nothing.
                return Text("No data is available"); // If the snapshot does not have data, this will print.
              }
            }
          }
          else{
            return Text("Star data is still loading"); //This represents a scenario where the connection has not finished yet.
          }
          //future: getStarData(),
        },
        future: getStarData(),
      ),
    );
  }
}