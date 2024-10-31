import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CalcProvider(),
      child: CalcApp(),
    ),
  );
}

class CalcApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalcScreen(),
    );
  }
}

class CalcScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final calcProv = Provider.of<CalcProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Text(
                calcProv.displayText,
                style: TextStyle(color: Colors.white, fontSize: 70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Column(
            children: [
              buttonRow(['AC', '±', '%', '÷'], context),
              buttonRow(['7', '8', '9', '×'], context),
              buttonRow(['4', '5', '6', '-'], context),
              buttonRow(['1', '2', '3', '+'], context),
              bottomRow(context),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("History"),
                    content: Container(
                      width: double.maxFinite,
                      child: ListView(
                        children: calcProv.historyList
                            .map((item) => ListTile(title: Text(item)))
                            .toList(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Close"),
                      ),
                      TextButton(
                        onPressed: () {
                          calcProv.clearHist();
                          Navigator.of(context).pop();
                        },
                        child: Text("Clear"),
                      ),
                    ],
                  ),
                );
              },
              child: Text("History", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buttonRow(List<String> labels, BuildContext context) {
    return Row(
      children: labels.map((label) {
        return Expanded(
          child: CalcButton(label: label),
        );
      }).toList(),
    );
  }

  Widget bottomRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CalcButton(label: '0', wide: true),
        ),
        Expanded(
          child: CalcButton(label: '.'),
        ),
        Expanded(
          child: CalcButton(label: '='),
        ),
      ],
    );
  }
}

class CalcButton extends StatelessWidget {
  final String label;
  final bool wide;

  CalcButton({required this.label, this.wide = false});

  @override
  Widget build(BuildContext context) {
    final calcProv = Provider.of<CalcProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        if (label == 'AC') {
          calcProv.clearDisp();
        } else if (label == '=') {
          calcProv.evalResult();
        } else if (label == '±') {
          calcProv.negate();
        } else if (label == '%') {
          calcProv.toPercent();
        } else if (label == '+' ||
            label == '-' ||
            label == '×' ||
            label == '÷') {
          calcProv.setOp(label);
        } else {
          calcProv.addToDisp(label);
        }
      },
      child: Container(
        height: 80,
        alignment: Alignment.center,
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: label == '=' ||
                  label == '+' ||
                  label == '-' ||
                  label == '×' ||
                  label == '÷'
              ? Colors.orange
              : Colors.grey[800],
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
      ),
    );
  }
}

class CalcProvider extends ChangeNotifier {
  String displayText = '0';
  List<String> historyList = [];
  String curOp = '';
  double firstNum = 0;
  bool isNewEntry = true;

  void addToDisp(String value) {
    if (isNewEntry) {
      displayText = value == '.' ? '0.' : value;
      isNewEntry = false;
    } else {
      if (value == '.' && displayText.contains('.')) return;
      displayText += value;
    }
    notifyListeners();
  }

  void clearDisp() {
    displayText = '0';
    curOp = '';
    firstNum = 0;
    isNewEntry = true;
    notifyListeners();
  }

  void evalResult() {
    double secNum = double.tryParse(displayText) ?? 0;
    double res = 0;

    if (curOp == '+') {
      res = firstNum + secNum;
    } else if (curOp == '-') {
      res = firstNum - secNum;
    } else if (curOp == '×') {
      res = firstNum * secNum;
    } else if (curOp == '÷') {
      if (secNum != 0) {
        res = firstNum / secNum;
      } else {
        displayText = "Error";
        notifyListeners();
        return;
      }
    }

    displayText = res % 1 == 0 ? res.toInt().toString() : res.toString();
    historyList.add(
        "${firstNum.toString()} $curOp ${secNum.toString()} = $displayText");
    isNewEntry = true;
    notifyListeners();
  }

  void setOp(String operation) {
    firstNum = double.tryParse(displayText) ?? 0;
    curOp = operation;
    isNewEntry = true;
    notifyListeners();
  }

  void negate() {
    double currVal = double.tryParse(displayText) ?? 0;
    displayText = (currVal * -1).toString();
    notifyListeners();
  }

  void toPercent() {
    double currVal = double.tryParse(displayText) ?? 0;
    displayText = (currVal / 100).toString();
    notifyListeners();
  }

  void clearHist() {
    historyList.clear();
    notifyListeners();
  }
}
