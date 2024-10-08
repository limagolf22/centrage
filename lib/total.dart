import 'dart:math';

import 'package:flutter/material.dart';
import 'package:centrage/values.dart';
import 'package:poly_collisions/poly_collisions.dart';

class TotalLabel extends StatefulWidget {
  final ValueNotifier<double> valtotkg;
  final ValueNotifier<double> valtotNm;

  const TotalLabel({Key? key, required this.valtotkg, required this.valtotNm})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TotalLabelState();
  }
}

class _TotalLabelState extends State<TotalLabel> {
  @override
  void initState() {
    super.initState();
    widget.valtotkg.addListener(() {
      setState(() {});
    });
    widget.valtotNm.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
        child: Text(
          "masse totale : " +
              ((widget.valtotkg.value * 10).round() / 10).toString() +
              " kg, bras de levier : " +
              ((widget.valtotNm.value * 1000).round() / 1000).toString() +
              " m",
          style: TextStyle(
              color: inlimitsConvex() ? Colors.black : Colors.red,
              fontWeight:
                  inlimitsConvex() ? FontWeight.normal : FontWeight.bold),
          textAlign: TextAlign.center,
        ));
  }

  bool inlimits() {
    return widget.valtotkg.value <
            min(
                currentPlane.gabarit[1].y +
                    (currentPlane.gabarit[2].y - currentPlane.gabarit[1].y) /
                        (currentPlane.gabarit[2].x -
                            currentPlane.gabarit[1].x) *
                        (widget.valtotNm.value - currentPlane.gabarit[1].x),
                currentPlane.gabarit[2].y) &&
        widget.valtotNm.value < currentPlane.gabarit[3].x;
  }

  bool inlimitsConvex() {
    return PolygonCollision.isPointInPolygon(currentPlane.gabarit,
        Point(widget.valtotNm.value, widget.valtotkg.value));
  }
}
