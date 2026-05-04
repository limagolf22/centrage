import 'dart:math';

import 'package:centrage/suggestion.dart';
import 'package:centrage/values.dart';
import 'package:test/test.dart';

void main() {
  group('Suggestion ', () {
    test('one lest suggestion', () async {
      Plane plane = Plane(
          "7X",
          [
            const Point(0.280, 330),
            const Point(0.280, 525),
            const Point(0.387, 525),
            const Point(0.400, 410),
            const Point(0.400, 315),
            const Point(0.393, 310),
          ],
          [
            Slot("gueuse avant", SlotType.weight, -1.650, 10.0, 0.0, 0.5),
            Slot("ballast queue", SlotType.water, 4.230, 12.0, null, null),
            Slot("pilote", SlotType.people, -0.511, 117.8, 0.0, null),
            Slot("bagage", SlotType.weight, -0.150, 5.0, null, null),
            Slot("ballast aile", SlotType.water, 0.270, 190.0, null, null),
          ],
          280,
          0.625);

      List<String> expectedSuggestion = generateSuggestions([0.0,0.0,50.0,0.0,0.0], plane);
      expect(expectedSuggestion,["mettre 9.0kg sur 'gueuse avant'"]);
    });
    test('no suggestion found', () async {
      Plane plane = Plane(
          "7X",
          [
            const Point(0.280, 330),
            const Point(0.280, 525),
            const Point(0.387, 525),
            const Point(0.400, 410),
            const Point(0.400, 315),
            const Point(0.393, 310),
          ],
          [
            Slot("gueuse avant", SlotType.weight, -1.650, 10.0, 0.0, 0.5),
            Slot("ballast queue", SlotType.water, 4.230, 12.0, null, null),
            Slot("pilote", SlotType.people, -0.511, 117.8, 0.0, null),
            Slot("bagage", SlotType.weight, -0.150, 5.0, null, null),
            Slot("ballast aile", SlotType.water, 0.270, 190.0, null, null),
          ],
          280,
          0.625);

      List<String> expectedSuggestion = generateSuggestions([0.0,0.0,10.0,0.0,0.0], plane);
      expect(expectedSuggestion,[]);
    });
  });
}
