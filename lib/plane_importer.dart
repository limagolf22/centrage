import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import 'package:centrage/values.dart';

Future<List<Plane>> loadPlanes(String path) async {
  String yamlString =
      await rootBundle.loadString('assets/datas/EnacPlanesTest.yaml');
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
