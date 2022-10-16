import 'dart:math';

import 'package:flutter/material.dart';

const fuelType = {"100LL": 0.72, "JETA1": 0.8};

class Plane {
  String name;
  List<Point> gabarit;
  Map<String, double> leverArm;
  double maxFuel, maxAuxFuel, massPlane, laPlane;

  Plane(this.name, this.gabarit, this.leverArm, this.maxFuel, this.maxAuxFuel,
      this.massPlane, this.laPlane);
}

List<Plane> planeList = [
  Plane(
      "F-GOVL",
      [
        Point(0.205, 566),
        Point(0.205, 750),
        Point(0.428, 900),
        Point(0.564, 900),
        Point(0.564, 566)
      ],
      {"mainFuel": 1.12, "crew": 0.41, "pax": 1.19, "freight": 1.3},
      110,
      0,
      566,
      0.3595),
  Plane(
      "F-GLVY",
      [
        Point(0.205, 566),
        Point(0.205, 750),
        Point(0.428, 900),
        Point(0.564, 900),
        Point(0.564, 566)
      ],
      {"mainFuel": 1.12, "crew": 0.41, "pax": 1.19, "freight": 1.3},
      110,
      0,
      566,
      0.3595),
  Plane(
      "F-GGXU",
      [
        Point(0.205, 581.9),
        Point(0.205, 750),
        Point(0.428, 900),
        Point(0.564, 900),
        Point(0.564, 581.9)
      ],
      {"mainFuel": 1.12, "crew": 0.41, "pax": 1.19, "freight": 1.9},
      110,
      0,
      581.9,
      0.3290),
  Plane(
      "F-GYRL",
      [
        Point(0.205, 600),
        Point(0.205, 760),
        Point(0.428, 1000),
        Point(0.564, 1000),
        Point(0.564, 600)
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
  Plane(
      "F-GUAC",
      [
        Point(0.949, 700),
        Point(0.949, 970),
        Point(1.01, 1070),
        Point(1.083, 1150),
        Point(1.205, 1150),
        Point(1.205, 700)
      ],
      {"mainFuel": 1.075, "crew": 1.165, "pax": 2.095, "freight": 2.6},
      210,
      0,
      766.0,
      0.9494)
];

Plane currentPlane = planeList[0];

double fuelDensity = fuelType["100LL"]!;

Map<String, Map<String, double>> storedValues = {
  for (var item in planeList)
    item.name: {"mainFuel": 0, "auxFuel": 0, "crew": 0, "pax": 0, "freight": 0}
};

double totalkgfuelMax = 0.0;
double totalNmfuelMax = 0.0;
double totalkgfuelMin = 0.0;
double totalNmfuelMin = 0.0;

class Values {
  ValueNotifier<double> mainFuel = new ValueNotifier(110.0);
  ValueNotifier<double> auxFuel = new ValueNotifier(0.0);

  ValueNotifier<double> crew = new ValueNotifier(130.0);
  ValueNotifier<double> pax = new ValueNotifier(7.5);
  ValueNotifier<double> freight = new ValueNotifier(0.0);

  ValueNotifier<double> totalkg = new ValueNotifier(0.0);
  ValueNotifier<double> totalNm = new ValueNotifier(0.0);

  Values() {
    mainFuel.addListener(updateTot);
    auxFuel.addListener(updateTot);
    crew.addListener(updateTot);
    pax.addListener(updateTot);
    freight.addListener(updateTot);
    updateTot();
  }
  void resetNotifiers(Plane plane) {
    (storedValues[currentPlane.name])!["mainFuel"] = mainFuel.value;
    (storedValues[currentPlane.name])!["auxFuel"] = auxFuel.value;
    (storedValues[currentPlane.name])!["crew"] = crew.value;
    (storedValues[currentPlane.name])!["pax"] = pax.value;
    (storedValues[currentPlane.name])!["freight"] = freight.value;
    currentPlane = plane;
    mainFuel.value = (storedValues[currentPlane.name])!["mainFuel"]!;
    auxFuel.value = (storedValues[currentPlane.name])!["auxFuel"]!;
    crew.value = (storedValues[currentPlane.name])!["crew"]!;
    pax.value = (storedValues[currentPlane.name])!["pax"]!;
    freight.value = (storedValues[currentPlane.name])!["freight"]!;
    updateTot();
  }

  void updateTot() {
    double t_kg = currentPlane.massPlane +
        mainFuel.value * fuelDensity +
        auxFuel.value * fuelDensity +
        crew.value +
        pax.value +
        freight.value;
    double t_Nm = ((currentPlane.massPlane * currentPlane.laPlane +
                    mainFuel.value *
                        fuelDensity *
                        currentPlane.leverArm["mainFuel"]! +
                    (currentPlane.leverArm.containsKey("auxFuel")
                        ? fuelDensity *
                            auxFuel.value *
                            currentPlane.leverArm["auxFuel"]!
                        : 0) +
                    crew.value * currentPlane.leverArm["crew"]! +
                    pax.value * currentPlane.leverArm["pax"]! +
                    freight.value * currentPlane.leverArm["freight"]!) /
                t_kg *
                1000)
            .round() /
        1000;
    totalkgfuelMax = currentPlane.massPlane +
        currentPlane.maxFuel * fuelDensity +
        currentPlane.maxAuxFuel * fuelDensity +
        crew.value +
        pax.value +
        freight.value;
    totalkgfuelMin =
        currentPlane.massPlane + crew.value + pax.value + freight.value;
    totalNmfuelMax = ((currentPlane.massPlane * currentPlane.laPlane +
                    currentPlane.maxFuel *
                        fuelDensity *
                        currentPlane.leverArm["mainFuel"]! +
                    (currentPlane.leverArm.containsKey("auxFuel")
                        ? fuelDensity *
                            currentPlane.maxAuxFuel *
                            currentPlane.leverArm["auxFuel"]!
                        : 0) +
                    crew.value * currentPlane.leverArm["crew"]! +
                    pax.value * currentPlane.leverArm["pax"]! +
                    freight.value * currentPlane.leverArm["freight"]!) /
                totalkgfuelMax *
                1000)
            .round() /
        1000;
    totalNmfuelMin = ((currentPlane.massPlane * currentPlane.laPlane +
                    crew.value * currentPlane.leverArm["crew"]! +
                    pax.value * currentPlane.leverArm["pax"]! +
                    freight.value * currentPlane.leverArm["freight"]!) /
                totalkgfuelMin *
                1000)
            .round() /
        1000;
    totalkg.value = t_kg;
    totalNm.value = t_Nm;
  }
}
