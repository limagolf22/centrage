import 'dart:math';

import 'package:centrage/values.dart';
import 'package:flutter/material.dart';

class Chart extends StatefulWidget {
  final ValueNotifier<double> totalkg;
  final ValueNotifier<double> totalNm;

  Chart({Key? key, required this.totalkg, required this.totalNm})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChartState();
  }
}

class _ChartState extends State<Chart> {
  @override
  void initState() {
    super.initState();
    widget.totalNm.addListener(() {
      setState(() {});
    });
    widget.totalkg.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: LayoutBuilder(
            builder: (_, constraints) => Container(
                child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: ChartPainter(widget.totalkg, widget.totalNm)))));
  }
}

class ChartPainter extends CustomPainter {
  ValueNotifier<double> totalkg;
  ValueNotifier<double> totalNm;

  ChartPainter(this.totalkg, this.totalNm);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 3
      ..color = Colors.black;

    double defaultHeight = 200;

    double minNm = 0.200,
        maxNm = 0.600,
        minkg = currentPlane.gabarit[0].y.toDouble(),
        maxkg = currentPlane.gabarit[3].y.toDouble();
    double Nm_PX = size.width / (maxNm - minNm);
    double kg_PX = defaultHeight / (maxkg - minkg);

    Path arrowPath = Path()
      ..moveTo((currentPlane.gabarit[0].x - minNm) * Nm_PX,
          defaultHeight - (currentPlane.gabarit[0].y - minkg) * kg_PX);

    paint.color = Colors.green;
    for (Point pt
        in currentPlane.gabarit.sublist(1, currentPlane.gabarit.length)) {
      arrowPath.lineTo(
          (pt.x - minNm) * Nm_PX, defaultHeight - (pt.y - minkg) * kg_PX);
    }

    arrowPath.close();
    canvas.drawPath(arrowPath, paint);

    paint.color = Colors.red;
    canvas.drawCircle(
        Offset((totalNm.value - minNm) * Nm_PX,
            defaultHeight - (totalkg.value - minkg) * kg_PX),
        4,
        paint);

    paint.color = Colors.black;
    canvas.drawLine(Offset(0, 0), Offset(0, defaultHeight), paint);
    canvas.drawLine(
        Offset(0, defaultHeight), Offset(size.width, defaultHeight), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
