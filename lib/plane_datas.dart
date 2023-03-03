import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

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
    var name = key;
    List<Point> gabarit = [
      for (dynamic pt in value['gabarit']) Point((pt['x']!), pt['y']!)
    ];
    Map<String, num> leverArm = {
      for (var entry in value['leverArm'].entries) entry.key: entry.value
    }; // [for (Map<String, double> pt in value['leverArm']) Point((pt['x']!),pt['y']!) ]  ;

    planeList.add(Plane(key, gabarit, leverArm, value['maxFuel'],
        value['maxAuxFuel'], value['massPlane'], value['laPlane']));
  });
  return planeList;
}

Future<void> savePlanes(String name, String yamlString) async {
  File("$impDir/datas/" + name)
    ..createSync(recursive: true)
    ..writeAsStringSync(yamlString);
}
