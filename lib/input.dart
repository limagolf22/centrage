import 'dart:math';
import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final ValueNotifier<double> valNot;
  final double min, max, step;
  final String label;
  final String unit;

  const Input(
      {Key? key,
      required this.valNot,
      required this.min,
      required this.max,
      required this.label,
      required this.unit,
      required this.step})
      : super(key: key);

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
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
                SizedBox(
                    width: 60,
                    child: Text(widget.label, textAlign: TextAlign.left)),
                SizedBox(
                    width: (MediaQuery.of(context).size.width) - 155,
                    child: Slider(
                      value: min(widget.max, max(widget.min, _val)),
                      onChanged: onSliderChanged,
                      min: widget.min,
                      max: widget.max,
                      divisions:
                          ((widget.max - widget.min) / widget.step).floor(),
                      activeColor: widget.unit == "L"
                          ? Colors.blue.shade900
                          : Colors.amber.shade900,
                    )),
                SizedBox(
                    width: 40,
                    child: TextFormField(
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.number,
                      validator: validateFieldValue,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onFieldSubmitted: (value) {
                        onSliderChanged(double.tryParse(value) ?? 0.0);
                      },
                      onEditingComplete: () {
                        onSliderChanged(widget.valNot.value);
                      },
                      controller: TextEditingController()
                        ..text = widget.valNot.value.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                          errorStyle: TextStyle(fontSize: 10.0)),
                    )),
                SizedBox(
                    width: 53,
                    child: Text(
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
                    ))
              ])
        : Container();
  }

  onSliderChanged(double v) {
    widget.valNot.value = (v * 10).round() / 10;
  }

  void refresh() {
    _val = widget.valNot.value;
    setState(() {});
  }

  String? validateFieldValue(String? val) {
    double? parsed = double.tryParse(val ?? "");
    return parsed != null
        ? ((parsed < widget.min || parsed > widget.max) ? null : null)
        : "invalide";
  }
}
