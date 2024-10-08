import 'package:centrage/chart.dart';
import 'package:centrage/input.dart';
import 'package:centrage/plane_datas.dart';
import 'package:centrage/save.dart';
import 'package:centrage/total.dart';
import 'package:centrage/values.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

enum SaveState { SAVED, NOTSAVED }

SaveState saveS = SaveState.SAVED;

void main() {
  Logger.root.level = Level.FINE; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centrage AC ENAC',
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
        primarySwatch: Colors.cyan,
      ),
      home: const MyHomePage(title: "Centrage AC ENAC"),
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
  Values values = Values();
  bool isDataLoadNecessary = false;

  @override
  void initState() {
    super.initState();
    getExportDir();
    getImportDir().then((value) {
      loadPlanesFile().then((success) => setState((() {
            isDataLoadNecessary = !success;
          })));
    });

    values.totalkg.addListener(() {
      if (saveS == SaveState.SAVED) {
        saveS = SaveState.NOTSAVED;
        setState(() {});
      }
    });
    values.totalNm.addListener(() {
      if (saveS == SaveState.SAVED) {
        saveS = SaveState.NOTSAVED;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
                color: const Color.fromARGB(255, 255, 255, 255),
                icon: Icon(
                  Icons.download_rounded,
                  color: isDataLoadNecessary ? Colors.amber : Colors.white,
                ),
                onPressed: (() async {
                  FilePickerResult? result = await (FilePicker.platform
                      .pickFiles(type: FileType.any, allowMultiple: false));
                  if (result != null && result.files.isNotEmpty) {
                    final fileBytes = result.files.first.bytes;
                    final fileName = result.files.first.name;
                    loadPlanesFromString(String.fromCharCodes(fileBytes!));
                    savePlanes(fileName, String.fromCharCodes(fileBytes));
                    setState(() {
                      isDataLoadNecessary = false;
                    });
                  }
                })),
            IconButton(
              color: saveS == SaveState.SAVED
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : const Color.fromARGB(255, 255, 0, 0),
              icon: const Icon(Icons.save),
              tooltip: 'Save the configuration',
              onPressed: () {
                saveS = SaveState.SAVED;
                saveXlsx(values, currentPlane.name);
                setState(() {});
              },
            ),
          ],
        ),
        drawer: Drawer(
            child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                children: [
              for (Plane plane in planeList)
                ListTile(
                  title: Text(plane.name),
                  onTap: () {
                    // values.updateTot();
                    values.resetNotifiers(plane);
                    setState(() {});
                    Navigator.pop(context);
                  },
                )
            ])),
        body: Column(
          children: [
            Input(
                min: 0.0,
                max: currentPlane.maxFuel.toDouble(),
                valNot: values.mainFuel,
                label: "main\nfuel ",
                unit: "L"),
            Input(
                min: 0.0,
                max: currentPlane.maxAuxFuel.toDouble(),
                valNot: values.auxFuel,
                label: "aux\nfuel ",
                unit: "L"),
            Input(
                min: 0.0,
                max: 250.0,
                valNot: values.crew,
                label: "crew ",
                unit: "kg"),
            Input(
                min: 0.0,
                max: 250.0,
                valNot: values.pax,
                label: "pax ",
                unit: "kg"),
            Input(
                min: 0.0,
                max: 65.0,
                valNot: values.freight,
                label: "freight ",
                unit: "kg"),
            Text(
              currentPlane.name,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(
                height: 200,
                child: Chart(totalkg: values.totalkg, totalNm: values.totalNm)),
            TotalLabel(valtotkg: values.totalkg, valtotNm: values.totalNm),
            Text(impDir == "" ? "" : "saved in : " + impDir,
                style: const TextStyle(color: Color.fromARGB(255, 255, 0, 0)))
          ],
        ));
  }
}
