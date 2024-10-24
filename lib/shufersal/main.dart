// ignore_for_file: prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nutrition_routine/shufersal/food_widget.dart';
import 'package:nutrition_routine/shufersal/shufersal_sheli.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Food? food;
  String? text = "אנא חפש פריט";
  TextEditingController controller = TextEditingController();

  // Future scanAndSearchFood() async {
  //   String barcode = await FlutterBarcodeScanner.scanBarcode(
  //       "#ff0000", "cancel", true, ScanMode.BARCODE);
  //   searchFoodFromBarcode(barcode);
  // }

  Future searchFoodFromBarcode(String barcode) async {
    setState(() {
      text = "טוען $barcode ...";
    });
    try {
      var food = await fetchFoodFromBarcode(barcode);
      setState(() {
        this.food = food;
        text = null;
      });
    } on ClientException {
      setState(() {
        text = "פריט $barcode לא נמצא";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: null,
                    child: Text("scan!"),
                  ),
                  Text("or..."),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(hintText: "הכנס ברקוד"),
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              searchFoodFromBarcode(controller.text);
                            },
                            child: Text("חפש!"))
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: text != null ? Text(text!) : FoodWidget(food: food!),
            ),
          ],
        ),
      ),
    );
  }
}
