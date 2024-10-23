import 'dart:convert';
import 'dart:io';

import 'package:app_platform/app_platform.dart';
import 'package:flutter/material.dart';
import 'package:nutrition_routine/models.dart';
import 'package:nutrition_routine/persistence.dart';
import 'package:nutrition_routine/save_controller.dart';
import 'package:nutrition_routine/widgets/dual_button.dart';
import 'package:nutrition_routine/widgets/item_picker.dart';
import 'package:nutrition_routine/widgets/model_creator.dart';
import 'package:nutrition_routine/widgets/model_tile.dart';
import 'package:nutrition_routine/widgets/save_button.dart';
import 'package:path_provider/path_provider.dart';

Future initAppState() async {
  AppState state;
  try {
    final directory = await getApplicationDocumentsDirectory();
    var file = File('${directory.path}/state.json');
    var stateString = await file.readAsString();
    var stateJson = jsonDecode(stateString);
    state = AppState.modelType.create(stateJson);
  } catch (e) {
    state = AppState.modelType.create({
      "routines": [
        {
          "name": "routine a",
          "meals": [
            {
              "meal": {
                "name": "nutty pudding",
                "items": [
                  "strawberries",
                ],
              },
              "time": 123,
            },
          ],
        }
      ],
      "foodItems": [
        {
          "name": "strawberries",
          "nutritionalValues": {
            "calories": 100,
          },
        }
      ]
    });
  }
  app.initialize(state);
}

AppState getState() {
  return app.state;
}

late AppState state;

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

Future<T?> showCreateModelDialog<T extends Model>(
    BuildContext context, ModelType<T> modelType) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(modelType.name),
        content: CreateModel(
          modelType: modelType,
          onCreate: (model) {
            Navigator.of(context).pop(model);
          },
        ),
        actions: [],
        actionsAlignment: MainAxisAlignment.spaceBetween,
      );
    },
  );
}

Future<T?> showItemPickerDialog<T extends Model>(
  BuildContext context,
  ListObject<T> items,
  String Function(T) toString,
  Widget Function(BuildContext, T, void Function() onTap) build,
) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Search"),
        content: ConstrainedBox(
          constraints: BoxConstraints.loose(Size.fromHeight(350)),
          child: ItemPicker(
            items: items,
            itemToString: toString,
            buildItem: build,
            onSelect: (context, index) {
              Navigator.of(context).pop(items.value[index]);
            },
          ),
        ),
      );
    },
  );
}

Future<String?> showTextFieldDialog(
    BuildContext context, String title, String hint) async {
  String? value;
  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          onChanged: (v) => value = v,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text("cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(value),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text("add"),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
      );
    },
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var saveController = SaveController(state: state);
  var loadController = LoadController(state: state);
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
            label: "1",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "2",
          ),
        ],
      ),
    );
  }
}

class FoodItemsView extends StatelessWidget {
  const FoodItemsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Text(
            "All food items",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Expanded(
            child: StreamBuilder(
              stream: state.foodItems.updates(),
              builder: (context, snapshot) {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    if (index == state.foodItems.value.length) {
                      return TextButton(
                        onPressed: () async {
                          FoodItemModel? model = await showCreateModelDialog(
                            context,
                            FoodItemModel.modelType,
                          );

                          if (model != null) {
                            state.foodItems.add(model);
                          }
                        },
                        child: Icon(Icons.add),
                      );
                    }
                    var foodItem = state.foodItems.value[index];
                    return FoodItemTile(item: foodItem);
                  },
                  itemCount: state.foodItems.value.length + 1,
                );
              },
            ),
          ),
        ],
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
                    if (index == state.routines.value.length) {
                      return TextButton(
                        onPressed: () async {
                          RoutineModel? model = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(RoutineModel.modelType.name),
                                content: CreateModel(
                                  modelType: RoutineModel.modelType,
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
                    var routine = state.routines.value[index];
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
                              "number of meals: ${routine.meals.value.length}"),
                        ),
                      ),
                    );
                  },
                  itemCount: state.routines.value.length + 1,
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
                  if (index == routine.meals.value.length) {
                    return TextButton(
                      onPressed: () async {
                        Model? model = await showCreateModelDialog(
                            context, TimedMealModel.modelType);
                        if (model != null) {
                          routine.meals.add(model as TimedMealModel);
                        }
                      },
                      child: Icon(Icons.add),
                    );
                  }
                  var meal = routine.meals.value[index];
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
                                "number of items: ${meal.meal.items.value.length}"),
                            Text("time: ${meal.time.value.format(context)}"),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: routine.meals.value.length + 1,
              ),
            )
          ]),
        );
      },
    );
  }
}

class MealPage extends StatelessWidget {
  final MealModel meal;
  const MealPage({super.key, required this.meal});

  @override
  build(BuildContext context) {
    return StreamBuilder(
      stream: meal.updates(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Hero(
              tag: meal,
              child: Text(
                meal.name.value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          body: Column(children: [
            Text("Items:"),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  if (index == meal.items.value.length + 1) {
                    Map<String, int> totals = {};
                    for (var item in meal.items.value
                        .where((v) => v.value != null)
                        .map((v) => v.value!)) {
                      for (var entry in item.nutritionalValues.value.entries) {
                        totals[entry.key] =
                            (totals[entry.key] ?? 0) + entry.value.value;
                      }
                    }
                    return Column(
                      children: [
                        for (var total in totals.entries)
                          Text("total ${total.key}: ${total.value}"),
                      ],
                    );
                  }
                  if (index == meal.items.value.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: DualButton(
                        onPressed1: () async {
                          Model? model = await showCreateModelDialog(
                              context, FoodItemModel.modelType);
                          if (model != null) {
                            state.foodItems.add(model as FoodItemModel);
                            meal.items.createAndAdd(model.name.value);
                          }
                          // var name = await showTextFieldDialog(
                          //     context, "Add Meal", "something");
                          // if (name != null) {
                          //   meal.items.add(FoodItemModel.modelType.create({
                          //     "name": name,
                          //     "nutritionalValues": {},
                          //   }));
                          // }
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
                            meal.items.createAndAdd(model.name.value);
                          }
                        },
                        child2: Icon(Icons.search),
                      ),
                    );
                  }
                  var item = meal.items.value[index];
                  if (item.value == null) {
                    return SimpleCardTile(
                      title: "Unknown food item! (${item.key})",
                    );
                  }
                  return FoodItemTile(item: item.value!);
                },
                itemCount: meal.items.value.length + 2,
              ),
            )
          ]),
        );
      },
    );
  }
}

class FoodItemTile extends StatelessWidget {
  const FoodItemTile({
    super.key,
    required this.item,
  });

  final FoodItemModel item;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: a route that will delete in case the model is deleted (instead of material page route)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FoodItemPage(item: item, tag: this),
            ),
          );
        },
        child: ListTile(
          title: Hero(
            tag: this,
            child: Text(
              item.name.value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          subtitle: Text(
              "calories: ${item.nutritionalValues.get("calories")?.value}"),
        ),
      ),
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
    return StreamBuilder(
      stream: item.updates(),
      builder: (context, snapshot) {
        var nutritionalValues = item.nutritionalValues.value.entries.toList();
        return Scaffold(
          appBar: AppBar(
            title: Hero(
              tag: tag,
              child: Text(
                item.name.value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          body: Column(children: [
            Text("Nutritional values:"),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  if (index == nutritionalValues.length) {
                    return TextButton(
                      onPressed: () async {
                        var model = await showCreateModelDialog(
                          context,
                          ModelType("Nutritional value", [
                            FieldType("name", stringType),
                            FieldType("amount", intType),
                          ]),
                        );
                        if (model != null) {
                          var modelValues = model.serialize();
                          item.nutritionalValues.add(
                            modelValues["name"],
                            intType.create(
                              modelValues["amount"],
                            ),
                          );
                        }
                      },
                      child: Icon(Icons.add),
                    );
                  }
                  var nutritionalValue = nutritionalValues[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      title: Hero(
                        tag: nutritionalValue,
                        child: ItemNutritionValue(
                            nutritionalValue: nutritionalValue),
                      ),
                    ),
                  );
                },
                itemCount: nutritionalValues.length + 1,
              ),
            )
          ]),
        );
      },
    );
  }
}

class ItemNutritionValue extends StatefulWidget {
  const ItemNutritionValue({
    super.key,
    required this.nutritionalValue,
  });

  final MapEntry<String, Primitive<int>> nutritionalValue;

  @override
  State<ItemNutritionValue> createState() => _ItemNutritionValueState();
}

class _ItemNutritionValueState extends State<ItemNutritionValue> {
  String? error;
  int? number;

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
          child: TextFormField(
            initialValue: widget.nutritionalValue.value.value.toString(),
            onChanged: (value) {
              var number = int.tryParse(value);
              if (number != null) {
                widget.nutritionalValue.value.set(
                  number,
                  debounce: Duration(milliseconds: 300),
                );
                setState(() {
                  error = null;
                });
              } else {
                setState(() {
                  error = "invalid number $value!";
                });
              }
            },
            decoration: InputDecoration(errorText: error),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    if (number != null) {
      widget.nutritionalValue.value.set(number!);
    }
    super.dispose();
  }
}
