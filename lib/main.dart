import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseDatabase database = FirebaseDatabase.instance;
DatabaseReference ref = FirebaseDatabase.instance.ref("Alpha Centauri");

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

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
_getStars() async {
  // This method gets data for Alpha Centauri from the database. If you did it outside the main class, you will probably not be able to see it. async means that it will run once you press the button or run the function.
  DatabaseEvent event = await ref.once(); //the _getStars() method is for the first button. it is put somewhere where i can call it.

  // This is where one will print the data of the snapshot (in this case, Alpha Centauri's data)
  print(event.snapshot.value); // This will show Alpha Centauri's data
}

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
              _getStars(); // I am putting it here is just for testing; it is just to see if we are getting any data from firebase (the data we want, such as data relating to Alpha Centauri).
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
  // This is a demo list to show querying
  List<String> searchTerms = [
    "Proxima Centauri",
    "Alpha Centauri",
    "Tau Ceti",
    "Ross 128",
    "Luyten's Star",
    "Kapteyn's Star",
    "Wolf 1061",
    "Gliese 876",
    "Gliese 581",
    "Lacaille 9352",
  ];

  List<String> theImages = [
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
  ];

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
          onTap: () {
            showAlertDialog(context);
          }
        );
      },
    );
  }

  // This is the last overwrite (to show the querying process at the runtime)
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
            title: Text(result,
                style: TextStyle(
                    color: Colors.deepPurpleAccent, fontFamily: 'Raleway')),
            leading: Image.asset(theImages[index], height: 50, width: 50, scale: 1.5),
            trailing: Icon(Icons.whatshot_rounded));
      },
    );
  }
}
showAlertDialog(BuildContext bc) {
  // The OK button
  Widget buttonForOk = TextButton(
    child: Text("Ok"),
    onPressed: () {},
  );

  // The content of the notification
  AlertDialog ad = AlertDialog(
    title: Text("Star Information"),
    content: Text("Hello"),
    actions: [
      buttonForOk,
    ],
  );

  // Showing the actual dialog
  showDialog(
    context: bc,
    builder: (BuildContext bc) {
      return ad;
    },
  );
}