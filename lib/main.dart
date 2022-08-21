import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


/*void main() async{
  runApp(const MyApp());
}*/

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
              showSearch(
                  context: context,
                  // delegate to customize the search bar
                  delegate: CustomSearchDelegate()
              );
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
    );
  }
}
class CustomSearchDelegate extends SearchDelegate {
  // Demo list to show querying
  List<String> searchTerms = [
    "Proxima Centauri",
    "Alpha Centauri",
    "Epsilon Eridani",
    "Tau Ceti",
    "Ross 128",
    "Luyten's Star",
    "Kapteyn's Star",
    "Wolf 1061",
    "Gliese 876",
    "Gliese 581",
  ];

  List<String> theImages = [
    'https://upload.wikimedia.org/wikipedia/commons/9/95/New_shot_of_Proxima_Centauri%2C_our_nearest_neighbour.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/6/61/Alpha%2C_Beta_and_Proxima_Centauri_%281%29.jpg',
    'http://www.daviddarling.info/images/EpsEri.jpg',
    'https://www.universetoday.com/wp-content/uploads/2010/11/exoplanet.jpg',
    'https://skyandtelescope.org/wp-content/uploads/Ross-128-SDSS_S_480x274-736x490-c-default.jpg',
    'http://www.solstation.com/stars/gl623ab.gif',
    'http://www.daviddarling.info/images/Kapteyns_Star.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/a/a8/Planets_Under_a_Red_Sun.jpg',
    'https://www.cs.mcgill.ca/~rwest/wikispeedia/wpcd/images/185/18537.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRROUezXXVa6yArzPxwFTgtK8NrMA-0qkaYlA&usqp=CAU'
  ];

  // first overwrite to
  // clear the search text
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

  // second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  // third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<String> myMatchQuery = [];
    for (var stars in searchTerms) {
      if (stars.toLowerCase().contains(query.toLowerCase())) {
        myMatchQuery.add(stars);
      }
    }
    return ListView.builder(
      itemCount: myMatchQuery.length,
      itemBuilder: (context, index) {
        var result = myMatchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  // last overwrite to show the
  // querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> myMatchQuery = [];
    for (var stars in searchTerms) {
      if (stars.toLowerCase().contains(query.toLowerCase())) {
        myMatchQuery.add(stars);
      }
    }
    return ListView.builder(
      itemCount: myMatchQuery.length,
      itemBuilder: (context, index) {
        var result = myMatchQuery[index];
        return ListTile(
            title: Text(result, style: TextStyle(color: Colors.deepPurpleAccent, fontFamily: 'Raleway')),
            /*for(var i = 0; i < searchTerms.length; i++){
          i = searchTerms[i];
          switch(i){
            case 0:
              leading: Image.network('https://upload.wikimedia.org/wikipedia/commons/9/95/New_shot_of_Proxima_Centauri%2C_our_nearest_neighbour.jpg');
              break;
            case 1:
              leading: Image.network('https://upload.wikimedia.org/wikipedia/commons/6/61/Alpha%2C_Beta_and_Proxima_Centauri_%281%29.jpg');
              break;
            case 2:
              leading: Image.network('http://www.daviddarling.info/images/EpsEri.jpg');
              break;
            case 3:
              leading: Image.network('https://www.universetoday.com/wp-content/uploads/2010/11/exoplanet.jpg');
              break;
            case 4:
              leading: Image.network('https://skyandtelescope.org/wp-content/uploads/Ross-128-SDSS_S_480x274-736x490-c-default.jpg');
              break;
            case 5:
              leading: Image.network('http://www.solstation.com/stars/gl623ab.gif');
              break;
            case 6:
              leading: Image.network('http://www.daviddarling.info/images/Kapteyns_Star.jpg');
              break;
            case 7:
              leading: Image.network('https://upload.wikimedia.org/wikipedia/commons/a/a8/Planets_Under_a_Red_Sun.jpg');
              break;
            case 8:
              leading: Image.network('https://www.cs.mcgill.ca/~rwest/wikispeedia/wpcd/images/185/18537.jpg');
              break;
            case 9:
              leading: Image.network('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRROUezXXVa6yArzPxwFTgtK8NrMA-0qkaYlA&usqp=CAU');
              break;
          }
        },*/
            leading:
              Image.network(theImages[index], height: 50, width: 50),
            trailing: Icon(Icons.whatshot_rounded)
        );
      },
    );
  }
}
