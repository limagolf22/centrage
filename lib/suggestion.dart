import 'dart:math';

import 'package:centrage/values.dart';
import 'package:poly_collisions/poly_collisions.dart';

List<String> generateSuggestions(
    List<double> values, Plane plane) {
  List<Slot> slots = plane.getSlots().toList();
  List<double> changedvalues = [for (double x in values) x];
  for (var i = 0; i < values.length; i++) {
    if(slots[i].type==SlotType.weight){
      while (changedvalues[i] < slots[i].max) {
        changedvalues[i] += slots[i].step ?? 0.5;
        (double, double) cent = plane.computeCentrage(changedvalues);
        if(PolygonCollision.isPointInPolygon(plane.gabarit, Point(cent.$2,cent.$1))){
          return ["mettre ${changedvalues[i]}kg sur '${slots[i].name}'"];
        }
      }
      changedvalues[i] = values[i];
      while (changedvalues[i] > (slots[i].min ??0.0)) {
        changedvalues[i] -= slots[i].step ?? 0.5;
        (double, double) cent = plane.computeCentrage(changedvalues);
        if(PolygonCollision.isPointInPolygon(plane.gabarit, Point(cent.$2,cent.$1))){
          return ["mettre ${changedvalues[i]}kg sur '${slots[i].name}'"];
        }
      }
      changedvalues[i] = values[i];
    }
  }
  return [];
}
