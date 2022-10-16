import 'dart:math';
import 'dart:ui';

import 'package:centrage/values.dart';
import 'package:flutter/material.dart';
import 'package:poly_collisions/poly_collisions.dart';

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

    double minNm = currentPlane.gabarit
            .reduce((current, next) => current.x < next.x ? current : next)
            .x
            .toDouble(),
        maxNm = currentPlane.gabarit
            .reduce((current, next) => current.x > next.x ? current : next)
            .x
            .toDouble(),
        minkg = currentPlane.gabarit
            .reduce((current, next) => current.y < next.y ? current : next)
            .y
            .toDouble(),
        maxkg = currentPlane.gabarit
            .reduce((current, next) => current.y > next.y ? current : next)
            .y
            .toDouble();
    double Nm_PX = size.width / (maxNm - minNm);
    double kg_PX = defaultHeight / (maxkg - minkg);

    Path arrowPath = Path()
      ..moveTo((currentPlane.gabarit[0].x - minNm) * Nm_PX,
          defaultHeight - (currentPlane.gabarit[0].y - minkg) * kg_PX);

    paint.color = Colors.cyan.shade100;
    for (Point pt
        in currentPlane.gabarit.sublist(1, currentPlane.gabarit.length)) {
      arrowPath.lineTo(
          (pt.x - minNm) * Nm_PX, defaultHeight - (pt.y - minkg) * kg_PX);
    }

    arrowPath.close();


    canvas.drawPath(arrowPath, paint);

    Offset maxFuelOffset = Offset((totalNmfuelMax - minNm) * Nm_PX,
        defaultHeight - (totalkgfuelMax - minkg) * kg_PX),
        minFuelOffset =  Offset((totalNmfuelMin - minNm) * Nm_PX,
            defaultHeight - (totalkgfuelMin - minkg) * kg_PX);

    paint.color = Colors.grey;
    paint.strokeWidth = 1.0;

    canvas.drawLine(
        maxFuelOffset,
        minFuelOffset,
        paint);

    paint.strokeWidth = 2.0;

    Offset deltaOffset =  Offset((minFuelOffset.dy-maxFuelOffset.dy),(minFuelOffset.dx-maxFuelOffset.dx));
    deltaOffset = deltaOffset.scale(10/deltaOffset.distance,10/deltaOffset.distance );
    canvas.drawLine(
        Offset(maxFuelOffset.dx+deltaOffset.dx,
            maxFuelOffset.dy-deltaOffset.dy),
        Offset(maxFuelOffset.dx-deltaOffset.dx,
            maxFuelOffset.dy+deltaOffset.dy),
        paint);

    canvas.drawLine(
        Offset(minFuelOffset.dx+deltaOffset.dx,
            minFuelOffset.dy-deltaOffset.dy),
        Offset(minFuelOffset.dx-deltaOffset.dx,
            minFuelOffset.dy+deltaOffset.dy),
        paint);

    Offset centragePoint = Offset((totalNm.value - minNm) * Nm_PX,
        defaultHeight - (totalkg.value - minkg) * kg_PX);

    TextPainter textPainterFull = TextPainter(
      text:const TextSpan(text: "F",style: TextStyle(color: Color.fromRGBO(120, 120, 120, 1.0))) ,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left
    );
    textPainterFull.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    TextPainter textPainterEmpty = TextPainter(
      text:const TextSpan(text: "E",style: TextStyle(color: Color.fromRGBO(120, 120, 120, 1.0))) ,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,

    );
    textPainterEmpty.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    textPainterFull.paint(canvas, maxFuelOffset+const Offset(0,-14));
    textPainterEmpty.paint(canvas, minFuelOffset+const Offset(-8,0));

    bool isInPolygon =PolygonCollision.isPointInPolygon(currentPlane.gabarit,
        Point(this.totalNm.value, this.totalkg.value));
    paint.color = isInPolygon?Colors.amber:Colors.red ;
    paint.strokeWidth=isInPolygon?2.5:4;
    canvas.drawLine(Offset(centragePoint.dx-5, centragePoint.dy-5),Offset(centragePoint.dx+5, centragePoint.dy+5),paint);
    canvas.drawLine(Offset(centragePoint.dx+5, centragePoint.dy-5),Offset(centragePoint.dx-5, centragePoint.dy+5),paint);

    paint.color = Colors.black;
    canvas.drawLine(const Offset(0, 0), Offset(0, defaultHeight), paint);
    canvas.drawLine(
        Offset(0, defaultHeight), Offset(size.width, defaultHeight), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

double hypotenuse(double x, double y) {
  return sqrt(x * x + y * y);
}
