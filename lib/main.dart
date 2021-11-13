import 'package:centrage/chart.dart';
import 'package:centrage/input.dart';
import 'package:centrage/save.dart';
import 'package:centrage/total.dart';
import 'package:centrage/values.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centrage Flutter',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: "Centrage Flutter Home Page"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Values values = new Values();

  @override
  Widget build(BuildContext context) {
    List<Widget> childrenAdded = [
      Input(
          min: 0.0,
          max: currentPlane.maxFuel,
          valNot: values.fuel,
          label: "fuel ")
        ..unit = "L",
      Input(min: 0.0, max: 250.0, valNot: values.crew, label: "crew "),
      Input(min: 0.0, max: 250.0, valNot: values.pax, label: "pax "),
      Input(min: 0.0, max: 65.0, valNot: values.freight, label: "freight "),
      SizedBox(
          height: 200,
          child: Chart(totalkg: values.totalkg, totalNm: values.totalNm)),
      TotalLabel(valtotkg: values.totalkg, valtotNm: values.totalNm)
    ];
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save the configuration',
              onPressed: () {
                saveXslx(values);
              },
            ),
          ],
        ),
        drawer: Drawer(
            child: ListView(
                padding: EdgeInsets.symmetric(vertical: 50.0),
                children: [
              for (Plane plane in planeList)
                ListTile(
                  title: Text(plane.name),
                  onTap: () {
                    currentPlane = plane;
                    setState(() {});
                    values.updateTot();
                  },
                )
            ])),
        body: ListView.builder(
            itemCount: 6,
            itemBuilder: (BuildContext context, int index) {
              return childrenAdded[index];
            }));
  }
}
