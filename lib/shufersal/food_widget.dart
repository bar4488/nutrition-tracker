// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:nutrition_routine/models.dart';
import 'package:nutrition_routine/shufersal/shufersal_sheli.dart';
import 'package:nutrition_routine/state.dart';

class FoodWidget extends StatefulWidget {
  final Food food;

  const FoodWidget({super.key, required this.food});

  @override
  State<FoodWidget> createState() => _FoodWidgetState();
}

class _FoodWidgetState extends State<FoodWidget> {
  String? chosenTable;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Text(widget.food.name),
            Text(
              "כמות:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.food.amount),
            Text(
              "קוד:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.food.code),
            Text(
              "כמות:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.food.company),
            Text(
              "רכיבים:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.food.ingredients
                .replaceAll("\n", "")
                .replaceAll(RegExp(r"\s+"), " ")),
            Text(
              "מכיל:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
                "${widget.food.contains?.replaceAll("\n", "").replaceAll(RegExp(r"\s+"), " ")}"),
            Text(
              "עלול להכיל:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
                "${widget.food.mayContain?.replaceAll("\n", "").replaceAll(RegExp(r"\s+"), " ")}"),
            Text(
              "מדינה:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("${widget.food.country}"),
            Text(
              "הערות:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("${widget.food.type}"),
            for (var nutrition in widget.food.nutritionValue.keys)
              Column(
                children: [
                  Text(
                    "ערכים תזונתיים",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(nutrition),
                  Material(
                    color: chosenTable == nutrition
                        ? Color.lerp(
                            Theme.of(context).primaryColor,
                            Colors.white,
                            0.7,
                          )
                        : Theme.of(context).dialogBackgroundColor,
                    elevation: chosenTable == nutrition ? 10 : 0,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          chosenTable = nutrition;
                        });
                      },
                      child: Table(
                        border: TableBorder.all(),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: <TableRow>[
                          TableRow(
                            children: <Widget>[
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.top,
                                child: Text("רכיב"),
                              ),
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.top,
                                child: Text("כמות"),
                              ),
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.top,
                                child: Text("יחידת מידה"),
                              ),
                            ],
                          ),
                          for (var item
                              in widget.food.nutritionValue[nutrition]!.entries)
                            TableRow(
                              children: <Widget>[
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.top,
                                  child: Text(item.key),
                                ),
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.top,
                                  child: Text(item.value["amount"]),
                                ),
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.top,
                                  child: Text(item.value["unit"]),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            TextButton(
              onPressed: chosenTable == null
                  ? null
                  : () {
                      var ourTable = widget.food.nutritionValue[chosenTable]!;
                      Map<String, String?> additionalValues = {
                        "company": widget.food.company,
                        "amount": widget.food.amount,
                        "code": widget.food.code,
                        "country": widget.food.country,
                        "ingredients": widget.food.ingredients,
                        "contains": widget.food.contains,
                        "mayContain": widget.food.mayContain,
                        "type": widget.food.type,
                      };
                      additionalValues
                          .removeWhere((key, value) => value == null);
                      Map<String, dynamic> nutritionalValues = {};
                      for (var MapEntry(key: name, value: entry)
                          in ourTable.entries) {
                        var amount = double.tryParse(entry["amount"]);
                        var unit = entry["unit"];
                        if (unit != null && amount != null) {
                          nutritionalValues[name] = {
                            "amount": amount,
                            "unit": unit
                          };
                        } else if (entry["unit"] != null &&
                            entry["amount"] != null) {
                          additionalValues[name] =
                              "${entry['amount']} ${entry['unit']}";
                        }
                      }

                      nutritionalValues = nutritionalValues.map(
                        (key, value) {
                          key = nutritionalValuesTranslation[key] ?? key;
                          String unit =
                              unitsTranslation[value["unit"]] ?? value["unit"];
                          // if (unitToGrams.containsKey(unit)) {
                          //   value["amount"] =
                          //       value["amount"] * unitToGrams[unit];
                          //   unit = "grams";
                          // }
                          value["unit"] = unit;
                          return MapEntry(key, value);
                        },
                      );
                      additionalValues = additionalValues.map(
                        (key, value) => MapEntry(
                            nutritionalValuesTranslation[key] ?? key, value),
                      );

                      var foodItem = {
                        "name": widget.food.name,
                        "additionalValues": additionalValues,
                        "nutritionalValues": nutritionalValues,
                      };
                      state.foodItems.add(FoodItemModel.create(foodItem));
                      Navigator.of(context).pop();
                    },
              child: Text("Create"),
            ),
          ],
        ),
      ),
    );
  }
}
