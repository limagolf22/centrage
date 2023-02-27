import 'dart:math';

import 'package:centrage/plane_importer.dart';
import 'package:centrage/values.dart';
import 'package:test/test.dart';

void main() {
  group('trash test', () {
    test('Point equals', () {
      Point a = const Point(2, 2);
      Point b = const Point(2, 2);
      expect(a, b);
    });
  });
  group('YAML import', () {
    test('file should be imported', () {
      final res = loadPlanes("./assets/datas/EnacPlanesTest.yaml");
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
            {"mainFuel": 1.12, "crew": 0.41, "pax": 1.19, "freight": 1.3},
            110,
            0,
            566,
            0.3595),
        Plane(
            "F-GYRL",
            [
              const Point(0.205, 600),
              const Point(0.205, 760),
              const Point(0.428, 1000),
              const Point(0.564, 1000),
              const Point(0.564, 600)
            ],
            {
              "mainFuel": 1.12,
              "auxFuel": 1.61,
              "crew": 0.41,
              "pax": 1.19,
              "freight": 1.9
            },
            110,
            50,
            603.0,
            0.3159),
      ];
      expect(res, expectedplaneList);
    });
  });
}
