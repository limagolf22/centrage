import 'dart:io';
import 'dart:typed_data';
import 'package:centrage/plane_datas.dart';
import 'package:centrage/values.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

String impDir = "";
String expDir = "";

final loggerSave = Logger("Save");

Future<void> getImportDir() async {
  if (Platform.isAndroid) {
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
  if (Platform.isAndroid) {
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
  if (impDir != "" && File(impDir + "/datas/EnacPlanes.yaml").existsSync()) {
    loggerSave.fine("init load done from datas");
    File file = File(impDir + "/datas/EnacPlanes.yaml");
    String content = await file.readAsString();
    loadPlanesFromString(content);
    return true;
  } else {
    var _planeList = await loadPlanesFromBundle('assets/datas/EnacPlanes.yaml');
    loggerSave.fine("init load done from bundle");
    planeList = _planeList;
    return false;
  }
}

void loadPlanesFromString(String yamlString) {
  var _planeList = loadPlanes(yamlString);
  planeList = _planeList;
}

Future<void> savePlanesFile() async {}

Future<void> saveXlsx(Values val, String airplaneName) async {
  var templateStr =
      await rootBundle.load('assets/datas/feuille-centrage-template.xlsx');
  saveXlsxWithInt8List(val, airplaneName, templateStr.buffer.asUint8List());
}

Future<void> saveXlsxWithInt8List(
    Values val, String airplaneName, Uint8List values) async {
  Excel excel = Excel.decodeBytes(values);
  /* 
      * sheetObject.updateCell(cell, value, { CellStyle (Optional)});
      * sheetObject created by calling - // Sheet sheetObject = excel['SheetName'];
      * cell can be identified with Cell Address or by 2D array having row and column Index;
      * Cell Style options are optional
      */

  Sheet sheetObject = excel['Feuil1'];

  CellStyle cellStyle = CellStyle(
      backgroundColorHex: "#FF388E3C", //  "#1AFF1A",
      fontFamily: getFontFamily(FontFamily.Calibri));

  cellStyle.underline = Underline.Single; // or Underline.Double

  var date = sheetObject.cell(CellIndex.indexByString("A1"));
  date.value = DateTime.now().toUtc().toIso8601String().substring(0, 16);

  var nameAvion = sheetObject.cell(CellIndex.indexByString("A3"));
  nameAvion.value = currentPlane.name;

  var fuelType = sheetObject.cell(CellIndex.indexByString("E8"));
  fuelType.value = currentPlane.fuelType.name;

  var labelFuel = sheetObject.cell(CellIndex.indexByString("B9"));
  labelFuel.value = "Volume en litres  (max : ${currentPlane.maxFuel}) :";

  var fuel = sheetObject.cell(CellIndex.indexByString("E9"));
  fuel.value = val.mainFuel.value;

  var labelAuxFuel = sheetObject.cell(CellIndex.indexByString("B13"));
  labelAuxFuel.value = "Volume en litres  (max : ${currentPlane.maxAuxFuel}) :";

  var auxFuel = sheetObject.cell(CellIndex.indexByString("E13"));
  auxFuel.value = val.auxFuel.value;

  var mAvion = sheetObject.cell(CellIndex.indexByString("C21"));
  mAvion.value = currentPlane.massPlane;
  var lAvion = sheetObject.cell(CellIndex.indexByString("D21"));
  lAvion.value = currentPlane.laPlane;

  var crew = sheetObject.cell(CellIndex.indexByString("C22"));
  crew.value = val.crew.value;
  var lCrew = sheetObject.cell(CellIndex.indexByString("D22"));
  lCrew.value = currentPlane.leverArm["crew"];

  var pax = sheetObject.cell(CellIndex.indexByString("C23"));
  pax.value = val.pax.value;
  var lPax = sheetObject.cell(CellIndex.indexByString("D23"));
  lPax.value = currentPlane.leverArm["pax"];

  fuel = sheetObject.cell(CellIndex.indexByString("E10"));
  fuel.value =
      (val.mainFuel.value - 1) * fuelDensities[currentPlane.fuelType.name]!;
  var lFuel = sheetObject.cell(CellIndex.indexByString("D24"));
  lFuel.value = currentPlane.leverArm["mainFuel"];

  auxFuel = sheetObject.cell(CellIndex.indexByString("E14"));
  auxFuel.value =
      (val.auxFuel.value) * fuelDensities[currentPlane.fuelType.name]!;

  var lAuxFuel = sheetObject.cell(CellIndex.indexByString("D25"));
  lAuxFuel.value = currentPlane.leverArm.containsKey("auxFuel")
      ? currentPlane.leverArm["auxFuel"]
      : 0;

  var freight = sheetObject.cell(CellIndex.indexByString("C26"));
  freight.value = val.freight.value;
  var lFreight = sheetObject.cell(CellIndex.indexByString("D26"));
  lFreight.value = currentPlane.leverArm["freight"];

  var mTot = sheetObject.cell(CellIndex.indexByString("C28"));
  mTot.value = val.totalkg.value;
  var lTot = sheetObject.cell(CellIndex.indexByString("D28"));
  lTot.value = val.totalNm.value;

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
