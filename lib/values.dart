import 'dart:math';
import 'package:flutter/foundation.dart';

enum SlotType { avgas, jetA1, water, people, weight }

class Plane {
  String name;
  List<Point> gabarit;
  List<Slot> slots;
  double mass, leverArm;

  Plane(this.name, this.gabarit, this.slots, this.mass, this.leverArm);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Plane &&
        other.name == name &&
        listEquals(other.gabarit, gabarit) &&
        listEquals(other.slots, slots) &&
        other.mass == mass &&
        other.leverArm == leverArm;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      Object.hashAll(gabarit),
      Object.hashAll(slots),
      mass,
      leverArm,
    );
  }
}

class Slot {
  String name;
  SlotType type;
  double leverArm;
  double max;
  double? min;
  double? step;

  Slot(this.name, this.type, this.leverArm, this.max, this.min, this.step);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Slot &&
        other.name == name &&
        other.type == type &&
        other.leverArm == leverArm &&
        other.max == max &&
        other.min == min &&
        other.step == step;
  }

  @override
  int get hashCode {
    return Object.hash(name, type, leverArm, max, min, step);
  }
}

List<Plane> planeList = [
  Plane(
      "F-GSTY",
      [
        const Point(0.205, 586),
        const Point(0.205, 740),
        const Point(0.420, 980),
        const Point(0.564, 1000),
        const Point(0.564, 586)
      ],
      [
        Slot("mainFuel", SlotType.avgas, 1.12, 110, null, null),
        Slot("crew", SlotType.people, 0.41, 300, null, null),
        Slot("pax", SlotType.people, 1.19, 300, null, null),
        Slot("freight", SlotType.weight, 1.9, 100, null, null),
      ],
      586,
      0.3530)
];

Plane currentPlane = planeList[0];

Map<String, Map<String, double>> updateConfigMapping() {
  return {
    for (var item in planeList)
      item.name: {for (var slot in item.slots) slot.name: slot.min ?? 0.0}
  };
}

Map<String, Map<String, double>> storedValues = updateConfigMapping();

double totalkgfuelMax = 0.0;
double totalNmfuelMax = 0.0;
double totalkgfuelMin = 0.0;
double totalNmfuelMin = 0.0;

class Values {
  List<ValueNotifier<double>> values = List.empty(growable: true);

  ValueNotifier<double> totalkg = ValueNotifier(0.0);
  ValueNotifier<double> totalNm = ValueNotifier(0.0);

  Values() {
    resetNotifiers(currentPlane);
  }
  void resetNotifiers(Plane plane) {
    // Save current config to cache
    for (var i = 0; i < values.length; i++) {
      (storedValues[currentPlane.name])![currentPlane.slots[i].name] =
          values[i].value;
    }

    currentPlane = plane;
    for (var v in values) {
      v.dispose();
    }
    values.clear();
    values.addAll(plane.slots.map((s) => ValueNotifier(s.min ?? 0.0)));
    for (var v in values) {
      v.addListener(updateTot);
    }
    // Load config from cache
    for (var i = 0; i < values.length; i++) {
      values[i].value = (storedValues[plane.name])![plane.slots[i].name]!;
    }
    updateTot();
  }

  void updateTot() {
    double tKg = currentPlane.mass;
    for (var i = 0; i < values.length; i++) {
      tKg += values[i].value * getDensity(currentPlane.slots[i].type);
    }

    double tNm = currentPlane.mass * currentPlane.leverArm;

    for (var i = 0; i < values.length; i++) {
      tNm += values[i].value *
          currentPlane.slots[i].leverArm *
          getDensity(currentPlane.slots[i].type);
    }
    tNm = (tNm / tKg * 10000).round() / 10000;

    totalkgfuelMax = currentPlane.mass;
    totalkgfuelMin = currentPlane.mass;
    for (var i = 0; i < values.length; i++) {
      totalkgfuelMax += ((currentPlane.slots[i].type == SlotType.weight ||
                  currentPlane.slots[i].type == SlotType.people)
              ? values[i].value
              : currentPlane.slots[i].max) *
          getDensity(currentPlane.slots[i].type);
      totalkgfuelMin += ((currentPlane.slots[i].type == SlotType.weight ||
                  currentPlane.slots[i].type == SlotType.people)
              ? values[i].value
              : currentPlane.slots[i].min ?? 0.0) *
          getDensity(currentPlane.slots[i].type);
    }

    totalNmfuelMax = currentPlane.mass * currentPlane.leverArm;
    totalNmfuelMin = currentPlane.mass * currentPlane.leverArm;
    for (var i = 0; i < values.length; i++) {
      totalNmfuelMax += ((currentPlane.slots[i].type == SlotType.weight ||
                  currentPlane.slots[i].type == SlotType.people)
              ? values[i].value
              : currentPlane.slots[i].max) *
          currentPlane.slots[i].leverArm *
          getDensity(currentPlane.slots[i].type);
      totalNmfuelMin += ((currentPlane.slots[i].type == SlotType.weight ||
                  currentPlane.slots[i].type == SlotType.people)
              ? values[i].value
              : currentPlane.slots[i].min ?? 0.0) *
          currentPlane.slots[i].leverArm *
          getDensity(currentPlane.slots[i].type);
    }
    totalNmfuelMax = (totalNmfuelMax / totalkgfuelMax * 10000).round() / 10000;
    totalNmfuelMin = (totalNmfuelMin / totalkgfuelMin * 10000).round() / 10000;

    totalkg.value = tKg;
    totalNm.value = tNm;
  }
}

double getDensity(SlotType type) {
  switch (type) {
    case SlotType.avgas:
      return 0.72;
    case SlotType.jetA1:
      return 0.8;
    case SlotType.water:
      return 1.0;
    case SlotType.people:
      return 1.0;
    case SlotType.weight:
      return 1.0;
  }
}
