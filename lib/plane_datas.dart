import 'dart:io';
import 'dart:math';

import 'package:centrage/save.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import 'package:centrage/values.dart';

Future<List<Plane>> loadPlanesFromBundle(String path) async {
  String yamlString = await rootBundle.loadString(path);
  return loadPlanes(yamlString);
}

List<Plane> loadPlanes(String yamlString) {
  final YamlMap yamlMap = loadYaml(yamlString);
  List<Plane> planeList = [];
  yamlMap.forEach((key, value) {
    List<Point> gabarit = [
      for (dynamic pt in value['gabarit']) Point((pt['x']!), pt['y']!)
    ];
    List<Slot> slots = [
      for (var s in value['slots'])
        Slot(s['name'], SlotType.values.byName(s['type']), s['leverArm'], s['max'], s['min'], s['unit'])
    ];

    planeList.add(Plane(key, gabarit, slots, value['mass'], value['leverArm']));
  });
  return planeList;
}

Future<void> savePlanes(String name, String yamlString) async {
  File("$impDir/datas/" + name)
    ..createSync(recursive: true)
    ..writeAsStringSync(yamlString);
}
