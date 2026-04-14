import 'dart:math';

import 'package:centrage/api.dart';
import 'package:centrage/chart.dart';
import 'package:centrage/config.dart';
import 'package:centrage/input.dart';
import 'package:centrage/plane_datas.dart';
import 'package:centrage/save.dart';
import 'package:centrage/total.dart';
import 'package:centrage/values.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

enum SaveState { saved, notSaved }

SaveState saveS = SaveState.saved;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centrage AC',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: const MyHomePage(title: "Centrage AC"),
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
  Key _inputKey = UniqueKey();
  final TextEditingController _pilotWeightController = TextEditingController();
  final TextEditingController _parachuteWeightController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _pilotWeightController.text = config.pilotWeight.toString();
    _parachuteWeightController.text = config.parachuteWeight.toString();
    getExportDir();
    getImportDir().then((value) {
      loadPlanesFile().then((success) {
        // Apply URL parameters after loading planes data
        Map<String, String> urlParams = getUrlParameters();
        values.resetNotifiers(applyUrlParameters(urlParams) ?? planeList[0]);
        setState((() {
          isDataLoadNecessary = !success;
          _inputKey = UniqueKey();
        }));
      });
    });

    values.totalkg.addListener(() {
      if (saveS == SaveState.saved) {
        saveS = SaveState.notSaved;
        setState(() {});
      }
    });
    values.totalNm.addListener(() {
      if (saveS == SaveState.saved) {
        saveS = SaveState.notSaved;
        setState(() {});
      }
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paramètres'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pilotWeightController,
              decoration: const InputDecoration(
                labelText: 'Masse Pilote (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(
              height: 15.0,
            ),
            TextField(
              controller: _parachuteWeightController,
              decoration: const InputDecoration(
                labelText: 'Masse Parachute (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              double? weight = double.tryParse(_pilotWeightController.text);
              double? paraWeight =
                  double.tryParse(_parachuteWeightController.text);
              if (weight != null &&
                  weight > 0 &&
                  paraWeight != null &&
                  paraWeight > 0) {
                config.setPilotWeight(weight);
                config.setParachuteWeight(paraWeight);
                // Update pilot slot in current plane if exists
                _applyConfigWeightToCurrentPlane(weight, paraWeight);
              }
              Navigator.pop(context);
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  void _applyConfigWeightToCurrentPlane(double weight, double paraWeight) {
    for (var i = 0; i < values.values.length; i++) {
      if (storedValues[currentPlane.name] != null) {
        (storedValues[currentPlane.name])![currentPlane.slots[i].name] =
            values.values[i].value;
      }
    }
    // Update only people section in cache
    for (var item in planeList) {
      for (var slot in item.slots) {
        if (slot.type == SlotType.people) {
          storedValues[item.name]![slot.name] =
              min(slot.max, max(slot.min ?? 0.0, weight + paraWeight));
        }
      }
    }
    // Load config from cache
    for (var i = 0; i < values.values.length; i++) {
      if (storedValues[currentPlane.name] != null) {
        values.values[i].value =
            (storedValues[currentPlane.name])![currentPlane.slots[i].name]!;
      }
    }
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
                  color: isDataLoadNecessary ? Colors.amber : Colors.grey,
                ),
                onPressed: (() async {
                  FilePickerResult? result = await (FilePicker.platform
                      .pickFiles(
                          type: FileType.any,
                          allowMultiple: false,
                          withData: true));
                  if (result != null && result.files.isNotEmpty) {
                    final fileBytes = result.files.first.bytes;
                    final fileName = result.files.first.name;
                    loadPlanesFromString(String.fromCharCodes(fileBytes!));
                    savePlanes(fileName, String.fromCharCodes(fileBytes));
                    values.resetNotifiers(planeList[0]);
                    setState(() {
                      isDataLoadNecessary = false;
                      _inputKey = UniqueKey();
                    });
                  }
                })),
            IconButton(
              color: saveS == SaveState.saved ? Colors.grey : Colors.red,
              icon: const Icon(Icons.save),
              tooltip: 'Enregistre',
              onPressed: () {
                saveS = SaveState.saved;
                saveXlsx(values, currentPlane.name);
                setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Paramètres',
              onPressed: _showSettingsDialog,
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
                  selected: plane.name == currentPlane.name,
                  onTap: () {
                    values.resetNotifiers(plane);
                    setState(() {
                      _inputKey = UniqueKey();
                    });
                    Navigator.pop(context);
                  },
                )
            ])),
        body: currentPlane.slots.isNotEmpty
            ? Column(
                children: [
                      Column(
                          key: _inputKey,
                          children: (currentPlane.slots
                              .asMap()
                              .entries
                              .map((s) => Input(
                                  label: s.value.name,
                                  min: s.value.min ?? 0.0,
                                  max: s.value.max,
                                  unit: getUnit(s.value.type),
                                  step: s.value.step ?? 0.5,
                                  valNot: values.values[s.key]))
                              .toList()))
                    ].cast<Widget>() +
                    [
                      Text(
                        currentPlane.name,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height: 200,
                          child: Chart(
                              totalkg: values.totalkg,
                              totalNm: values.totalNm)),
                      TotalLabel(
                          valtotkg: values.totalkg, valtotNm: values.totalNm),
                      Text(impDir == "" ? "" : "saved in : " + impDir,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 255, 0, 0)))
                    ],
              )
            : const Center(child: Text("Pas de données chargées")));
  }
}

String getUnit(SlotType type) {
  switch (type) {
    case SlotType.weight:
      return "kg";
    case SlotType.people:
      return "kg";
    default:
      return "L";
  }
}
