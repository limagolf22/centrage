import 'dart:io';
import 'dart:math';

import 'package:centrage/plane_datas.dart';
import 'package:centrage/values.dart';
import 'package:test/test.dart';

void main() {
  group('YAML import', () {
    test('file has only slots', () async {
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
              Slot("mainFuel", SlotType.avgas, 1.12, 110, null, null),
              Slot("crew", SlotType.people, 0.41, 110, null, null),
              Slot("pax", SlotType.people, 1.19, 110, null, null),
              Slot("freight", SlotType.weight, 1.3, 110, null, null),
            ],
            566,
            0.3595)
      ];
      expect(res, expectedplaneList);
    });
    test('file has imbricated groups', () async {
      File file = File("test/assets/PlaneWithGroupsTest.yaml");
      final res = loadPlanes(file.readAsStringSync());
      List<Plane> expectedplaneList = [
        Plane(
          "D-5774-15m",
          [
            const Point(0.280, 330),
            const Point(0.280, 525),
            const Point(0.387, 525),
            const Point(0.400, 410),
            const Point(0.400, 315),
            const Point(0.393, 310),
          ],
          [
            Group("masses non portantes", 120.0)
              ..subnodes.addAll([
                Group("lests", null)
                  ..subnodes.addAll([
                    Slot("gueuse avant", SlotType.weight, -1.650, 10.0, 0.0,
                        0.5),
                    Slot(
                        "ballast queue", SlotType.water, 4.230, 12.0, null, null)
                  ]),
                Slot("pilote", SlotType.people, -0.511, 117.8, 66.2, null),
                Slot("bagage", SlotType.weight, -0.150, 5.0, null, null),
              ]),
            Slot("ballast aile", SlotType.water, 0.270, 190.0, null, null),
          ],
          274.0,
          0.620,
        )
      ];
      expect(res, expectedplaneList);
    });
  });
}
