// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:nutrition_routine/shufersal/shufersal_sheli.dart';

class FoodWidget extends StatelessWidget {
  final Food food;

  const FoodWidget({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Text(food.name),
            Text(
              "כמות:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(food.amount),
            Text(
              "קוד:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(food.code),
            Text(
              "כמות:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(food.company),
            Text(
              "רכיבים:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(food.ingredients
                .replaceAll("\n", "")
                .replaceAll(RegExp(r"\s+"), " ")),
            Text(
              "מכיל:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
                "${food.contains?.replaceAll("\n", "").replaceAll(RegExp(r"\s+"), " ")}"),
            Text(
              "עלול להכיל:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
                "${food.mayContain?.replaceAll("\n", "").replaceAll(RegExp(r"\s+"), " ")}"),
            Text(
              "מדינה:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("${food.country}"),
            Text(
              "הערות:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("${food.type}"),
            for (var nutrition in food.nutritionValue.keys)
              Column(
                children: [
                  Text(
                    "ערכים תזונתיים",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(nutrition),
                  Table(
                    border: TableBorder.all(),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.top,
                            child: Text("רכיב"),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.top,
                            child: Text("כמות"),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.top,
                            child: Text("יחידת מידה"),
                          ),
                        ],
                      ),
                      for (var item in food.nutritionValue[nutrition]!.entries)
                        TableRow(
                          children: <Widget>[
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.top,
                              child: Text(item.key),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.top,
                              child: Text(item.value["amount"]),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.top,
                              child: Text(item.value["unit"]),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
