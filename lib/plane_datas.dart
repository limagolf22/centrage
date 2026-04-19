import 'dart:io';
import 'dart:math';

import 'package:centrage/save.dart';
import 'package:flutter/foundation.dart';
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
    List<Node> slots = [for (var n in value['slots']) retrieveNode(n)];

    planeList.add(Plane(key, gabarit, slots, value['mass'], value['leverArm']));
  });
  return planeList;
}

Node retrieveNode(dynamic n) {
  return n['type'] != null
      ? Slot(n['name'], SlotType.values.byName(n['type']), n['leverArm'],
          n['max'], n['min'], n['unit'])
      : (Group(n['name'], n['max'])
        ..subnodes.addAll([for (var sn in n['subnodes']) retrieveNode(sn)]));
}

Future<void> savePlanes(String name, String yamlString) async {
  if (!kIsWeb) {
    File("$impDir/datas/" + name)
      ..createSync(recursive: true)
      ..writeAsStringSync(yamlString);
  }
}
