import 'dart:io';
import 'package:centrage/plane_datas.dart';
import 'package:centrage/values.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

String impDir = "";
String expDir = "";

Future<void> getImportDir() async {
  if (Platform.isAndroid) {
    var directory = await getExternalStorageDirectory();
    impDir = directory!.path;
    print("import dir : " + impDir);
    print("import content " + directory.listSync(recursive: true).toString());
  } else {
    var directory = await getApplicationDocumentsDirectory();
    impDir = directory.path;
    print("import dir : " + impDir);
  }
}

Future<void> getExportDir() async {
  if (Platform.isAndroid) {
    var directory = await getExternalStorageDirectory();
    expDir = directory!.path;
    print("export dir : " + expDir);
    print("export content " + directory.listSync().toString());
  } else {
    var directory = await getDownloadsDirectory();
    expDir = directory!.path;
    print("export dir : " + expDir);
  }
}

Future<void> loadPlanesFile() async {
  if (impDir != "" && File(impDir + "/datas/EnacPlanes.yaml").existsSync()) {
    print("init load done from datas");
    File file = File(impDir + "/datas/EnacPlanes.yaml");
    String content = await file.readAsString();
    loadPlanesFromString(content);
  } else {
    var _planeList = await loadPlanesFromBundle('assets/datas/EnacPlanes.yaml');
    print("init load done from bundle");
    planeList = _planeList;
  }
}

void loadPlanesFromString(String yamlString) {
  var _planeList = loadPlanes(yamlString);
  planeList = _planeList;
}

Future<void> savePlanesFile() async {}

Future<void> saveXlsx(Values val, String airplaneName) async {
  String file = "$impDir/feuille-centrage-template.xlsx";
  var bytes = File(file).readAsBytesSync();
  Excel excel = Excel.decodeBytes(bytes);
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

  var nameAvion = sheetObject.cell(CellIndex.indexByString("A3"));
  nameAvion.value = currentPlane.name;

  var fuel = sheetObject.cell(CellIndex.indexByString("E9"));
  fuel.value = val.mainFuel.value;

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

  fuel = sheetObject.cell(CellIndex.indexByString("C24"));
  fuel.value = val.mainFuel.value * fuelDensities[currentPlane.fuelType.name]!;
  var lFuel = sheetObject.cell(CellIndex.indexByString("D24"));
  lFuel.value = currentPlane.leverArm["mainFuel"];

  auxFuel = sheetObject.cell(CellIndex.indexByString("C25"));
  auxFuel.value = val.auxFuel.value;
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
      "$impDir/" + airplaneName.toLowerCase() + "-feuille-centrage_ed.xlsx"))
    ..createSync(recursive: true)
    ..writeAsBytesSync(fileBytes!);
}
