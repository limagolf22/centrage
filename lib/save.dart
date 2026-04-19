import 'dart:io';
import 'package:centrage/plane_datas.dart';
import 'package:centrage/values.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';


String impDir = "";
String expDir = "";

final loggerSave = Logger("Save");

Future<void> getImportDir() async {
  if(kIsWeb){

  }
  else if (Platform.isAndroid) {
    var directory = await getExternalStorageDirectory();
    impDir = directory!.path;
    loggerSave.fine("import dir : " + impDir);
    loggerSave.fine(
        "import content " + directory.listSync(recursive: true).toString());
  } else {
    var directory = await getApplicationDocumentsDirectory();
    impDir = directory.path;
    loggerSave.fine("import dir : " + impDir);
  }
}

Future<void> getExportDir() async {
  if(kIsWeb){

  }
  else if (Platform.isAndroid) {
    var directory = await getExternalStorageDirectory();
    expDir = directory!.path;
    loggerSave.fine("export dir : " + expDir);
    loggerSave.fine("export content " + directory.listSync().toString());
  } else {
    var directory = await getDownloadsDirectory();
    expDir = directory!.path;
    loggerSave.fine("export dir : " + expDir);
  }
}

/// Loads Planes Files. Returns [true] if they are loaded from an
/// imported file, and [false] if datas come from internal storage.
Future<bool> loadPlanesFile() async {
if (impDir != "" && File(impDir + "/datas/ATVV.yaml").existsSync()) {
    loggerSave.fine("init load done from datas");
    File file = File(impDir + "/datas/ATVV.yaml");
    String content = await file.readAsString();
    loadPlanesFromString(content);
    return true;
  } else {
    var _planeList = await loadPlanesFromBundle('assets/datas/ATVV.yaml');
    loggerSave.fine("init load done from bundle");
    planeList = _planeList;
    storedValues = initConfigMapping();
    return false;
  }
}

void loadPlanesFromString(String yamlString) {
  var _planeList = loadPlanes(yamlString);
  planeList = _planeList;
  storedValues = initConfigMapping();
}

Future<void> savePlanesFile() async {}

Future<void> saveXlsx(Values val, String airplaneName) async {
  var templateStr =
      await rootBundle.load('assets/datas/feuille-centrage-template-v2.xlsx');
  saveXlsxWithInt8List(val, airplaneName, templateStr.buffer.asUint8List());
}

Future<void> saveXlsxWithInt8List(
    Values val, String airplaneName, Uint8List values) async {
  Excel excel = Excel.decodeBytes(values);

  Sheet sheetObject = excel['Feuil1'];

  CellStyle cellStyle = CellStyle(
      backgroundColorHex: "#FF388E3C", //  "#1AFF1A",
      fontFamily: getFontFamily(FontFamily.Calibri));

  cellStyle.underline = Underline.Single; // or Underline.Double

  var date = sheetObject.cell(CellIndex.indexByString("A1"));
  date.value = DateTime.now().toUtc().toIso8601String().substring(0, 16);

  var nameAvion = sheetObject.cell(CellIndex.indexByString("A3"));
  nameAvion.value = currentPlane.name;

  sheetObject.cell(CellIndex.indexByString("B7")).value = "Avion vide";
  sheetObject.cell(CellIndex.indexByString("C7")).value = currentPlane.mass;
  sheetObject.cell(CellIndex.indexByString("D7")).value = currentPlane.leverArm;
  sheetObject.cell(CellIndex.indexByString("E7")).setFormula("=C7 * D7");

  int i = 0;
  for (Slot slot in currentPlane.getSlots()) {
    sheetObject.cell(CellIndex.indexByString("B" + (8 + i).toString())).value =
        slot.name;
    sheetObject.cell(CellIndex.indexByString("C" + (8 + i).toString())).value =
        val.values[i].value * getDensity(slot.type) ;
    sheetObject.cell(CellIndex.indexByString("D" + (8 + i).toString())).value =
        slot.leverArm;
    sheetObject
        .cell(CellIndex.indexByString("E" + (8 + i).toString()))
        .setFormula("=C" + (8 + i).toString() + " * D" + (8 + i).toString());
    i++;
  }
  i++;

  sheetObject.cell(CellIndex.indexByString("B" + (8 + i).toString())).value =
      "Total";
  sheetObject
      .cell(CellIndex.indexByString("C" + (8 + i).toString()))
      .setFormula("=SUM(C7:C" + (6 + i).toString() + ")");
  sheetObject
      .cell(CellIndex.indexByString("D" + (8 + i).toString()))
      .setFormula("=E" + (8 + i).toString() + "/C" + (8 + i).toString());
  sheetObject
      .cell(CellIndex.indexByString("E" + (8 + i).toString()))
      .setFormula("=SUM(E7:E" + (6 + i).toString() + ")");

  sheetObject.cell(CellIndex.indexByString("H1")).value = "Total";
  sheetObject
      .cell(CellIndex.indexByString("I1"))
      .setFormula("=C" + (8 + i).toString());
  sheetObject
      .cell(CellIndex.indexByString("J1"))
      .setFormula("=D" + (8 + i).toString());
  sheetObject
      .cell(CellIndex.indexByString("K1"))
      .setFormula("=E" + (8 + i).toString());

  for (var i = 0; i < currentPlane.gabarit.length; i++) {
    var gab =
        sheetObject.cell(CellIndex.indexByString("B" + (49 + i).toString()));
    gab.value = String.fromCharCode(65 + i);
    var gabX =
        sheetObject.cell(CellIndex.indexByString("C" + (49 + i).toString()));
    gabX.value = currentPlane.gabarit[i].x;
    var gabY =
        sheetObject.cell(CellIndex.indexByString("D" + (49 + i).toString()));
    gabY.value = currentPlane.gabarit[i].y;
  }

  var fileBytes = excel.save();

  File(join(
      "$expDir/" + airplaneName.toLowerCase() + "-feuille-centrage_ed.xlsx"))
    ..createSync(recursive: true)
    ..writeAsBytesSync(fileBytes!);
}
