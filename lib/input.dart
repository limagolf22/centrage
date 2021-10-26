import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final ValueNotifier<double> valNot;
  final double min, max;
  final String label;
  String unit = "kg";

  Input({
    Key? key,
    required this.valNot,
    required this.min,
    required this.max,
    required this.label,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InputState();
  }
}

class _InputState extends State<Input> {
  double _val = 0;

  @override
  void initState() {
    super.initState();
    _val = widget.valNot.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
          Container(
              width: 45, child: Text(widget.label, textAlign: TextAlign.left)),
          Container(
              width: (MediaQuery.of(context).size.width) - 140,
              child: Slider(
                  value: _val,
                  onChanged: onSliderChanged,
                  min: widget.min,
                  max: widget.max,
                  divisions: (widget.max - widget.min).floor() * 2)),
          Container(
              width: 93,
              child: Text(
                  _val.toString() +
                      " " +
                      widget.unit +
                      " (" +
                      (_val / widget.max * 100).round().toString() +
                      "%)",
                  textAlign: TextAlign.left))
        ]));
  }

  onSliderChanged(double v) {
    widget.valNot.value = (v * 10).round() / 10;
    _val = (v * 10).round() / 10;
    setState(() {});
  }
}
