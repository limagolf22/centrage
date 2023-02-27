import 'dart:io';
import 'package:centrage/plane_importer.dart';
import 'package:centrage/values.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

String impDir = "";
String expDir = "";

Future<void> getImportDir() async {
  var directory = await getApplicationDocumentsDirectory();
  impDir = directory.path;
  print("import dir : " + impDir);
}

Future<void> getExportDir() async {
  if (Platform.isAndroid) {
    var directory = await getExternalStorageDirectory();
    expDir = directory!.path;
    print("export dir : " + expDir);
  } else {
    var directory = await getDownloadsDirectory();
    expDir = directory!.path;
    print("export dir : " + expDir);
  }
}

Future<void> loadPlanesFile() async {
  var _planeList = await loadPlanes("tr");
  planeList = _planeList;
}

Future<void> saveXslx(Values val, String airplaneName) async {
  String file =
      "$impDir/" + airplaneName.toLowerCase() + "-feuille-centrage.xlsx";
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

  var fuel = sheetObject.cell(CellIndex.indexByString("E10"));
  fuel.value = val.mainFuel.value; // dynamic values support provided;

  var crew = sheetObject.cell(CellIndex.indexByString("C18"));
  crew.value = val.crew.value;

  var pax = sheetObject.cell(CellIndex.indexByString("C19"));
  pax.value = val.pax.value;

  var freight = sheetObject.cell(CellIndex.indexByString("C21"));
  freight.value = val.freight.value;

  //fuel.cellStyle = cellStyle;

  var fileBytes = excel.save();

  File(join(
      "$impDir/" + airplaneName.toLowerCase() + "-feuille-centrage_ed.xlsx"))
    ..createSync(recursive: true)
    ..writeAsBytesSync(fileBytes!);

  // printing cell-type
  //print("CellType: " + fuel.cellType.toString());
}
