import 'package:flutter/material.dart';
import 'package:centrage/values.dart';

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
        child: Column(
            children: <Widget>[
                  Text(
                    "masse : " +
                        ((widget.valtotkg.value * 10).round() / 10).toString() +
                        " kg, centre de gravité : " +
                        ((widget.valtotNm.value * 1000).round() / 1000)
                            .toString() +
                        " m",
                    style: TextStyle(
                        color: isInBounds ? Colors.black : Colors.red,
                        fontWeight:
                            isInBounds ? FontWeight.normal : FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Text("________________________")
                ] +
                groupAlerts
                    .map((a) => Text(
                          a,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ))
                    .toList() +
                balanceSuggestions
                    .map((s) => Row(
                          children: [
                            const Icon(Icons.tips_and_updates,
                                color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              s,
                              style: const TextStyle(
                                  color: Colors.green, fontSize: 16.0, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ))
                    .toList()));
  }
}
