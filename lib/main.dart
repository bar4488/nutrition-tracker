import 'dart:async';

import 'package:app_platform/app_platform.dart';
import 'package:flutter_app_platform/widgets/dialogs.dart';
import 'package:flutter_app_platform/widgets/dual_button.dart';
import 'package:flutter_app_platform/widgets/model_creator.dart';
import 'package:flutter_app_platform/widgets/model_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nutrition_routine/meal_page.dart';
import 'package:nutrition_routine/models.dart';
import 'package:nutrition_routine/shufersal/food_widget.dart';
import 'package:nutrition_routine/shufersal/shufersal_sheli.dart';
import 'package:nutrition_routine/state.dart';
import 'package:nutrition_routine/view_models.dart';
import 'package:nutrition_routine/views.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppState();
  state = getState();
  var saving = false;
  state.updates().listen(
    (event) async {
      if (saving) return;
      saving = true;
      print("saving state...");
      await saveState(state.serialize());
      print("saved state!");
      saving = false;
    },
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          RoutinesView(),
          FoodItemsView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Routines",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "All items",
          ),
        ],
      ),
    );
  }
}

class FoodItemsView extends StatefulWidget {
  const FoodItemsView({
    super.key,
  });

  @override
  State<FoodItemsView> createState() => _FoodItemsViewState();
}

class _FoodItemsViewState extends State<FoodItemsView> {
  late SimpleListData foodItemsView;

  static ListTransformation? _transformation;
  static ListTransformation getTransformation() {
    _transformation ??= ListTransformation(
      SimpleTileData.transformation(
        title: ChainTransformation([ExtractField(FoodItemModel.Type, "name")]),
        subtitle: ChainTransformation([
          ExtractField(FoodItemModel.Type, "nutritionalValues"),
          MapValue((nutritionalValues) =>
              "calories: ${nutritionalValues.get("calories")?.displayValue}")
        ]),
      ),
    );
    return _transformation!;
  }

  @override
  void initState() {
    // init food items view
    foodItemsView = transformationFunc(state.foodItems);
    super.initState();
  }

  @override
  void dispose() {
    foodItemsView.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SimpleListPage(
        model: foodItemsView,
        title: stringType.create("All food items"),
        items: state.foodItems,
        itemTitle: (item) {
          return item.name.value;
        },
        itemSubTitle: (item) {
          return "calories: ${item.nutritionalValues.get("calories")?.displayValue}";
        },
        itemOnPress: (item) async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FoodItemPage(item: item, tag: item),
            ),
          );
        },
        onDeleteItems: (toDelete) {
          state.foodItems.removeN(toDelete);
        },
        bottomItem: DualButton(
            onPressed1: () async {
              FoodItemModel? model = await showCreateModelDialog(
                context,
                FoodItemModel.Type,
              );

              if (model != null) {
                state.foodItems.add(model);
              }
            },
            child1: Icon(Icons.add),
            onPressed2: () async {
              var barcode = await showDialog<String?>(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: MobileScanner(
                      onDetect: (capture) {
                        if (capture.barcodes.isNotEmpty) {
                          for (var c in capture.barcodes) {
                            if (c.type == BarcodeType.product &&
                                c.rawValue != null) {
                              Navigator.of(context).pop(c.rawValue!);
                            }
                          }
                        }
                      },
                    ),
                  );
                },
              );
              if (barcode == null || !context.mounted) return;

              var foodFuture = fetchFoodFromBarcode(barcode);
              await showDialog(
                context: context,
                builder: (dialogContext) {
                  return Dialog(
                    clipBehavior: Clip.hardEdge,
                    child: FutureBuilder(
                        future: foodFuture,
                        builder: (futureContext, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Center(child: CircularProgressIndicator());
                            case ConnectionState.done:
                              if (snapshot.hasData) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0)
                                      .add(EdgeInsets.only(bottom: 16)),
                                  child: FoodWidget(food: snapshot.data!),
                                );
                              } else {
                                Timer(Duration(milliseconds: 200), () async {
                                  if (context.mounted) {
                                    await showAlertDialog(
                                        context, "Item not found!",
                                        subtitle:
                                            "item with barcode $barcode was not found!");
                                  }
                                });
                                Navigator.of(futureContext).pop("invalid");
                                return Center();
                              }
                            default:
                              throw Exception();
                          }
                        }),
                  );
                },
              );
            },
            child2: Icon(CupertinoIcons.barcode)),
      ),
    );
  }
}

class RoutinesView extends StatelessWidget {
  const RoutinesView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Text(
            "Routines",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Expanded(
            child: StreamBuilder(
              stream: state.routines.updates(),
              builder: (context, snapshot) {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    if (index == state.routines.list.length) {
                      return TextButton(
                        onPressed: () async {
                          RoutineModel? model = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(RoutineModel.Type.name),
                                content: CreateModel(
                                  modelType: RoutineModel.Type,
                                  onCreate: (model) {
                                    Navigator.of(context).pop(model);
                                  },
                                ),
                                actions: [],
                                actionsAlignment:
                                    MainAxisAlignment.spaceBetween,
                              );
                            },
                          );

                          if (model != null) {
                            state.routines.add(model);
                          }
                        },
                        child: Icon(Icons.add),
                      );
                    }
                    var routine = state.routines.list[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          print("tapped");
                          // TODO: a route that will delete in case the model is deleted (instead of material page route)
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  RoutinePage(routine: routine),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Hero(
                            tag: routine,
                            child: Text(
                              routine.name.value,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          subtitle: Text(
                              "number of meals: ${routine.meals.list.length}"),
                        ),
                      ),
                    );
                  },
                  itemCount: state.routines.list.length + 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RoutinePage extends StatelessWidget {
  final RoutineModel routine;
  const RoutinePage({super.key, required this.routine});

  @override
  build(BuildContext context) {
    return StreamBuilder(
      stream: routine.updates(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Hero(
              tag: routine,
              child: Text(
                routine.name.value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          body: Column(children: [
            Text("Meals:"),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  if (index == routine.meals.list.length) {
                    return TextButton(
                      onPressed: () async {
                        Model? model = await showCreateModelDialog(
                            context, TimedMealModel.Type);
                        if (model != null) {
                          routine.meals.add(model as TimedMealModel);
                        }
                      },
                      child: Icon(Icons.add),
                    );
                  }
                  var meal = routine.meals.list[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        // TODO: a route that will delete in case the model is deleted (instead of material page route)
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MealPage(meal: meal.meal),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Hero(
                          tag: meal.meal,
                          child: Text(
                            meal.meal.name.value,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "number of items: ${meal.meal.items.list.length}"),
                            Text("time: ${meal.time.value.format(context)}"),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: routine.meals.list.length + 1,
              ),
            )
          ]),
        );
      },
    );
  }
}

class FoodItemPage extends StatelessWidget {
  final FoodItemModel item;
  final Object tag;
  const FoodItemPage({
    super.key,
    required this.item,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return ModelListPage(
      title: item.name,
      tag: item,
      items: item.nutritionalValues.asList(),
      itemTitle: (item) => item.value.key,
      itemSubTitle: (item) => item.value.value.displayValue,
      itemOnPress: (item) {},
      bottomItem: TextButton(
        onPressed: () async {
          var model = await showCreateModelDialog(
            context,
            StateModelType("Nutritional value", [
              StateFieldType("name", stringType),
              StateFieldType("value", NutritionValueModel.Type),
            ]),
          );
          if (model != null) {
            var modelValues = model.serialize();
            item.nutritionalValues.add(
              modelValues["name"],
              NutritionValueModel.Type.create(modelValues["value"]),
            );
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ItemNutritionValue extends StatefulWidget {
  const ItemNutritionValue({
    super.key,
    required this.nutritionalValue,
  });

  final MapEntry<String, NutritionValueModel> nutritionalValue;

  @override
  State<ItemNutritionValue> createState() => _ItemNutritionValueState();
}

class _ItemNutritionValueState extends State<ItemNutritionValue> {
  String? error;
  String? unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          "${widget.nutritionalValue.key}: ",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Expanded(
          child: StreamBuilder(
              stream: widget.nutritionalValue.value.unit.updates(),
              builder: (context, _) {
                var nutritionValue = widget.nutritionalValue.value;
                return TextFormField(
                  initialValue: nutritionValue.displayValue,
                  onChanged: (value) {
                    var values = value.split(" ");
                    var number = double.tryParse(values[0]);
                    if (number == null) {
                      setState(() {
                        error = "invalid number $value!";
                      });
                      return;
                    }
                    if (values.length > 2) {
                      error = "invalid format! '<amount> <value?>!";
                    }
                    widget.nutritionalValue.value.unit
                        .set(values.length > 1 ? values[1] : "grams");
                    widget.nutritionalValue.value.amount.set(
                      number,
                      debounce: Duration(milliseconds: 300),
                    );
                    setState(() {
                      error = null;
                    });
                  },
                  decoration: InputDecoration(
                    errorText: error,
                    hintText: "<amount> <unit>",
                    suffixText: widget.nutritionalValue.value.unit.value,
                  ),
                );
              }),
        )
      ],
    );
  }
}
