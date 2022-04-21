import 'dart:math';

import 'package:flutter/material.dart';

class Plane {
  String name;
  List<Point> gabarit;
  Map<String, double> leverArm;
  double maxFuel, massPlane, laPlane;

  Plane(this.name, this.gabarit, this.leverArm, this.maxFuel, this.massPlane,
      this.laPlane);
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
      {"fuel": 1.12, "crew": 0.41, "pax": 1.19, "freight": 1.3},
      110,
      566,
      0.3595),
  Plane(
      "F-GOVY",
      [
        Point(0.205, 566),
        Point(0.205, 750),
        Point(0.428, 900),
        Point(0.564, 900),
        Point(0.564, 566)
      ],
      {"fuel": 1.12, "crew": 0.41, "pax": 1.19, "freight": 1.3},
      110,
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
      {"fuel": 1.12, "crew": 0.41, "pax": 1.19, "freight": 1.9},
      110,
      581.9,
      0.3290)
];

Plane currentPlane = planeList[0];

double totalkgfuelMax = 0.0;
double totalNmfuelMax = 0.0;
double totalkgfuelMin = 0.0;
double totalNmfuelMin = 0.0;

class Values {
  ValueNotifier<double> fuel = new ValueNotifier(110.0);
  ValueNotifier<double> crew = new ValueNotifier(130.0);
  ValueNotifier<double> pax = new ValueNotifier(7.5);
  ValueNotifier<double> freight = new ValueNotifier(0.0);

  ValueNotifier<double> totalkg = new ValueNotifier(0.0);
  ValueNotifier<double> totalNm = new ValueNotifier(0.0);

  Values() {
    fuel.addListener(updateTot);
    crew.addListener(updateTot);
    pax.addListener(updateTot);
    freight.addListener(updateTot);
    updateTot();
  }

  void updateTot() {
    double t_kg = currentPlane.massPlane +
        fuel.value * 0.72 +
        crew.value +
        pax.value +
        freight.value;
    double t_Nm = ((currentPlane.massPlane * currentPlane.laPlane +
                    fuel.value * 0.72 * currentPlane.leverArm["fuel"]! +
                    crew.value * currentPlane.leverArm["crew"]! +
                    pax.value * currentPlane.leverArm["pax"]! +
                    freight.value * currentPlane.leverArm["freight"]!) /
                t_kg *
                1000)
            .round() /
        1000;
    totalkgfuelMax = currentPlane.massPlane +
        currentPlane.maxFuel * 0.72 +
        crew.value +
        pax.value +
        freight.value;
    totalkgfuelMin =
        currentPlane.massPlane + crew.value + pax.value + freight.value;
    totalNmfuelMax = ((currentPlane.massPlane * currentPlane.laPlane +
                    currentPlane.maxFuel *
                        0.72 *
                        currentPlane.leverArm["fuel"]! +
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
