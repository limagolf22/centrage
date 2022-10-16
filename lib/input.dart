import 'dart:math';
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
    widget.valNot.addListener(refresh);

    _val = widget.valNot.value;
  }

  @override
  Widget build(BuildContext context) {
    return (widget.min != widget.max)
        ? Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                Container(
                    width: 45,
                    child: Text(widget.label, textAlign: TextAlign.left)),
                Container(
                    width: (MediaQuery.of(context).size.width) - 140,
                    child: Slider(
                        value: min(widget.max, max(widget.min, _val)),
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
                            (widget.unit == "L"
                                ? ((_val / widget.max * 100).round() == 100
                                    ? " (full)"
                                    : " (" +
                                        (_val / widget.max * 100)
                                            .round()
                                            .toString() +
                                        "%)")
                                : ""),
                        textAlign: TextAlign.left))
              ]))
        : Container();
  }

  onSliderChanged(double v) {
    widget.valNot.value = (v * 10).round() / 10;
  }

  void refresh() {
    _val = widget.valNot.value;
    setState(() {});
  }
}
