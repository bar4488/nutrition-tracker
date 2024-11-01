import 'package:app_platform/app_platform.dart';
import 'package:flutter_app_platform/widgets/computation.dart';
import 'package:flutter_app_platform/widgets/dialogs.dart';
import 'package:flutter_app_platform/widgets/dual_button.dart';
import 'package:flutter_app_platform/widgets/model_view.dart';
import 'package:flutter_app_platform/widgets/simple_tile.dart';
import 'package:flutter/material.dart';
import 'package:nutrition_routine/main.dart';
import 'package:nutrition_routine/models.dart';
import 'package:nutrition_routine/state.dart';

class MealPage extends StatefulWidget {
  final MealModel meal;
  const MealPage({super.key, required this.meal});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  List<int>? deleting;
  bool get isDeleting => deleting != null;

  late Computation<Map<String, double>> initialTotals;
  late Stream<Map<String, double>> totals;
  @override
  void initState() {
    super.initState();

    initialTotals = Computation(() {
      Map<String, double> totals = {};
      for (var item in widget.meal.items.list
          .where((v) => v.item.value != null)
          .map((v) => v.item.value!)) {
        for (var entry in item.nutritionalValues.map.entries) {
          totals[entry.key] =
              (totals[entry.key] ?? 0) + entry.value.amount.value;
        }
      }
      return totals;
    });
    totals = widget.meal.items.updates().map(
      (event) {
        Map<String, double> totals = {};
        for (var item in widget.meal.items.list
            .where((v) => v.item.value != null)
            .map((v) => v.item.value!)) {
          for (var entry in item.nutritionalValues.map.entries) {
            totals[entry.key] =
                (totals[entry.key] ?? 0) + entry.value.amount.value;
          }
        }
        return totals;
      },
    );
    totals.listen(
      (event) {
        print(event);
      },
    );
  }

  void toggleDelete(int index) {
    {
      setState(() {
        if (deleting == null) {
          setState(() {
            deleting = [index];
          });
        } else {
          if (deleting!.contains(index)) {
            deleting!.remove(index);
            if (deleting!.isEmpty) {
              deleting = null;
            }
          } else {
            deleting!.add(index);
          }
        }
      });
    }
  }

  @override
  build(BuildContext context) {
    return ModelListPage(
      title: widget.meal.name,
      items: widget.meal.items,
      tag: widget.meal.name,
      itemTitle: (item) => item.item.value == null
          ? "Unknown food item! (${item.item.key})"
          : item.item.value!.name.value,
      itemSubTitle: (item) =>
          item.item.value == null ? null : "amount: ${item.amount.value} gr",
      itemOnPress: (item) {
        if (item.item.value == null) return;
        // TODO: a route that will delete in case the model is deleted (instead of material page route)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                FoodItemPage(item: item.item.value!, tag: item),
          ),
        );
      },
      onDeleteItems: (toDelete) {
        widget.meal.items.removeN(toDelete);
      },
      bottomItem: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DualButton(
              onPressed1: () async {
                Model? model = await showCreateModelDialog(
                  context,
                  StateModelType(
                    "Create food item",
                    [
                      StateFieldType(
                        "item",
                        FoodItemModel.Type,
                      ),
                      StateFieldType(
                        "amount",
                        intType,
                      )
                    ],
                  ),
                );
                if (model != null) {
                  var serialized = model.serialize();
                  print(serialized);
                  if (state.foodItems.list.any((element) =>
                      element.name.value == serialized["item"]["name"])) {
                    await Future.delayed(Duration(milliseconds: 200));
                    if (context.mounted) {
                      await showAlertDialog(
                        context,
                        "Food item already exists!",
                        subtitle: "choose an item with another name",
                      );
                    }
                    return;
                  }
                  state.foodItems.add(FoodItemModel.create(serialized["item"]));
                  widget.meal.items.add(MealItemModel.create({
                    "amount": serialized["amount"],
                    "item": serialized["item"]["name"],
                  }));
                }
              },
              child1: Icon(Icons.add),
              onPressed2: () async {
                var model = await showItemPickerDialog(
                  context,
                  state.foodItems,
                  (e) => e.name.value,
                  (context, e, onTap) => SimpleCardTile(
                    onTap: onTap,
                    title: e.name.value,
                  ),
                );
                if (model != null) {
                  await Future.delayed(Duration(milliseconds: 200));
                  if (!context.mounted) return;
                  var amountStr = await showTextFieldDialog(
                    context,
                    "Choose amount in grams",
                    "amount in grams",
                  );
                  if (amountStr == null) return;
                  var amount = int.tryParse(amountStr);
                  if (amount == null) {
                    await Future.delayed(Duration(milliseconds: 200));
                    if (context.mounted) {
                      await showAlertDialog(context, "Invalid amount!",
                          subtitle: "amount must be a number, not $amountStr");
                    }
                    return;
                  }

                  widget.meal.items.add(MealItemModel.create({
                    "amount": amount,
                    "item": model.name.value,
                  }));
                }
              },
              child2: Icon(Icons.search),
            ),
          ),
          StreamBuilder(
            // initialData: initialTotals.getValue(),
            stream: totals,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text("meal deleted!");
              }
              var totals = snapshot.data!;
              return Column(
                children: [
                  for (var total in totals.entries)
                    Text("total ${total.key}: ${total.value}"),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
