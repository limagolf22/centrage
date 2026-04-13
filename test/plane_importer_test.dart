import 'dart:io';
import 'dart:math';

import 'package:centrage/plane_datas.dart';
import 'package:centrage/values.dart';
import 'package:test/test.dart';

void main() {
  group('YAML import', () {
    test('file should be imported', () async {
      File file = File("test/assets/EnacPlanesTest.yaml");
      final res = loadPlanes(file.readAsStringSync());
      List<Plane> expectedplaneList = [
        Plane(
            "F-GOVL",
            [
              const Point(0.205, 566),
              const Point(0.205, 750),
              const Point(0.428, 900),
              const Point(0.564, 900),
              const Point(0.564, 566)
            ],
            [
              Slot("mainFuel", SlotType.avgas, 1.12,110,null,null),
              Slot("crew", SlotType.people, 0.41,110,null,null),
              Slot("pax", SlotType.people, 1.19,110,null,null),
              Slot("freight", SlotType.weight, 1.3,110,null,null),
            ],
            566,
            0.3595)
      ];
      expect(res, expectedplaneList);
    });
  });
}
