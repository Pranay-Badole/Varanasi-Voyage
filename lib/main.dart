import 'package:flutter/material.dart';
import 'package:tourist_app/Allscreens/mainscreen.dart';
import 'package:tourist_app/DataHandler/appData.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context)=> AppData(),
          child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: MainScreen.idScreen,
        routes:
        {
          MainScreen.idScreen: (context) => MainScreen(),
          // SearchScreen.idScreen: (context) => SearchScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


