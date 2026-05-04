import 'dart:math';
import 'package:centrage/suggestion.dart';
import 'package:flutter/foundation.dart';
import 'package:centrage/config.dart';
import 'package:poly_collisions/poly_collisions.dart';

enum SlotType { avgas, jetA1, water, people, weight }

class Plane {
  String name;
  List<Point> gabarit;
  List<Node> nodes;
  double mass, leverArm;

  Plane(this.name, this.gabarit, this.nodes, this.mass, this.leverArm);

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
        listEquals(other.nodes, nodes) &&
        other.mass == mass &&
        other.leverArm == leverArm;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      Object.hashAll(gabarit),
      Object.hashAll(nodes),
      mass,
      leverArm,
    );
  }

  Iterable<Slot> getSlots() {
    return nodes.expand((n) => n.flattenNode()).whereType<Slot>();
  }

  Iterable<Group> getGroups() {
    return nodes.expand((n) => n.flattenNode()).whereType<Group>();
  }

  (double, double) computeCentrage(List<double> values) {
    List<Slot> slots = getSlots().toList();
    double kg = mass;
    double mkg = leverArm * mass;
    for (var i = 0; i < values.length; i++) {
      double m = values[i] * getDensity(slots[i].type);
      kg += m;
      mkg += m * slots[i].leverArm;
    }
    return (kg, mkg / kg);
  }
}

sealed class Node {
  String name;
  List<Node> subnodes = List.empty(growable: true);

  Node(this.name);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Node &&
        other.name == name &&
        listEquals(other.subnodes, subnodes);
  }

  @override
  int get hashCode => Object.hash(name, Object.hashAll(subnodes));

  List<Node> flattenNode() {
    return [this] + subnodes.expand((n) => n.flattenNode()).toList();
  }

  double nodeWeight(Map<Slot, double> mapping) {
    return subnodes
            .whereType<Slot>()
            .map((s) => mapping[s] ?? 0.0)
            .fold(0.0, (a, b) => a + b) +
        subnodes
            .whereType<Group>()
            .map((g) => g.nodeWeight(mapping))
            .fold(0.0, (a, b) => a + b);
  }
}

class Group extends Node {
  double? max;

  Group(super.name, this.max);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Group && super == other && other.max == max;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, max);
}

class Slot extends Node {
  SlotType type;
  double leverArm;
  double max;
  double? min;
  double? step;

  Slot(super.name, this.type, this.leverArm, this.max, this.min, this.step);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Slot &&
        super == other &&
        other.type == type &&
        other.leverArm == leverArm &&
        other.max == max &&
        other.min == min &&
        other.step == step;
  }

  @override
  int get hashCode {
    return Object.hash(super.hashCode, type, leverArm, max, min, step);
  }
}

List<Plane> planeList = [Plane("XXXXX", [], [], 1.0, 1.0)];

Plane currentPlane = planeList[0];

Map<String, Map<String, double>> initConfigMapping() {
  return {
    for (var item in planeList)
      item.name: {
        for (var slot in item.getSlots())
          slot.name: min(
              slot.max,
              max(
                  slot.min ?? 0.0,
                  (slot.type == SlotType.people
                      ? config.pilotWeight + config.parachuteWeight
                      : 0.0)))
      }
  };
}

Map<String, Map<String, double>> storedValues = initConfigMapping();

double totalkgfuelMax = 0.0;
double totalNmfuelMax = 0.0;
double totalkgfuelMin = 0.0;
double totalNmfuelMin = 0.0;

bool isInBounds = false;
List<String> groupAlerts = [];
List<String> balanceSuggestions = [];

class Values {
  List<ValueNotifier<double>> values = List.empty(growable: true);

  ValueNotifier<double> totalkg = ValueNotifier(0.0);
  ValueNotifier<double> totalNm = ValueNotifier(0.0);

  Values() {
    resetNotifiers(currentPlane);
  }
  void resetNotifiers(Plane plane) {
    List<Slot> slotList = currentPlane.getSlots().toList();
    // Save current config to cache
    for (var i = 0; i < values.length; i++) {
      if (storedValues[currentPlane.name] != null) {
        (storedValues[currentPlane.name])![slotList[i].name] = values[i].value;
      }
    }

    currentPlane = plane;
    slotList = currentPlane.getSlots().toList();
    for (var v in values) {
      v.dispose();
    }
    values.clear();
    values.addAll(slotList.map((s) => ValueNotifier(s.min ?? 0.0)));
    for (var v in values) {
      v.addListener(updateTot);
    }
    // Load config from cache
    for (var i = 0; i < values.length; i++) {
      if (storedValues[plane.name] != null) {
        values[i].value = (storedValues[plane.name])![slotList[i].name]!;
      }
    }
    updateTot();
  }

  void updateTot() {
    List<Slot> slots = currentPlane.getSlots().toList();
    Map<Slot, double> slotMapper = {};
    double tKg = currentPlane.mass;
    for (var i = 0; i < values.length; i++) {
      double v = values[i].value * getDensity(slots[i].type);
      slotMapper[slots[i]] = v;
      tKg += v;
    }

    groupAlerts = currentPlane
        .getGroups()
        .where((g) => g.max != null)
        .map((g) {
          double w = g.nodeWeight(slotMapper);
          return g.max! < w
              ? "le groupe '${g.name}' pèse $w kg (masse max ${g.max}kg)"
              : null;
        })
        .whereType<String>()
        .toList();

    double tNm = currentPlane.mass * currentPlane.leverArm;

    for (var i = 0; i < values.length; i++) {
      tNm += values[i].value * slots[i].leverArm * getDensity(slots[i].type);
    }
    tNm = (tNm / tKg * 10000).round() / 10000;

    List<double> minFuelValues = Iterable.generate(values.length)
        .map((i) => ((slots[i].type == SlotType.weight ||
                slots[i].type == SlotType.people)
            ? values[i].value
            : (slots[i].min ?? 0.0)))
        .toList();
    (double, double) minCentrage = currentPlane.computeCentrage(minFuelValues);
    totalkgfuelMin = (minCentrage.$1 * 10000).round() / 10000;
    totalNmfuelMin = (minCentrage.$2 * 10000).round() / 10000;

    List<double> maxFuelValues = Iterable.generate(values.length)
        .map((i) => ((slots[i].type == SlotType.weight ||
                slots[i].type == SlotType.people)
            ? values[i].value
            : slots[i].max))
        .toList();
    (double, double) maxCentrage = currentPlane.computeCentrage(maxFuelValues);
    totalkgfuelMax = (maxCentrage.$1 * 10000).round() / 10000;
    totalNmfuelMax = (maxCentrage.$2 * 10000).round() / 10000;

    if (PolygonCollision.isPointInPolygon(
        currentPlane.gabarit, Point(tNm, tKg))) {
      isInBounds = true;
      balanceSuggestions = [];
    } else {
      isInBounds = false;
      balanceSuggestions = generateSuggestions(
          values.map((v) => v.value).toList(), currentPlane);
    }
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
