import 'dart:convert';
import 'dart:io';

import 'package:app_platform/app_platform.dart';
import 'package:flutter/material.dart';
import 'package:nutrition_routine/models.dart';
import 'package:nutrition_routine/save_controller.dart';
import 'package:nutrition_routine/widgets/model_creator.dart';
import 'package:nutrition_routine/widgets/save_button.dart';
import 'package:path_provider/path_provider.dart';

Future<AppState> getState() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    var file = File('${directory.path}/state.json');
    var stateString = await file.readAsString();
    var stateJson = jsonDecode(stateString);
    return AppState.modelType.create(stateJson);
  } catch (e) {
    return AppState.modelType.create({
      "routines": [
        {
          "name": "routine a",
          "meals": [
            {
              "meal": {
                "name": "nutty pudding",
                "items": [
                  {
                    "name": "strawberries",
                    "nutritionalValues": {
                      "calories": 100,
                    },
                  }
                ],
              },
              "time": 123,
            },
          ],
        }
      ],
    });
  }
}

late AppState state;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  state = await getState();
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

Future<Model?> showCreateModelDialog(
    BuildContext context, ModelType modelType) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.check)),
          AnimatedBuilder(
              animation: saveController,
              builder: (context, c) {
                return FutureIconButton(
                  status: loadController.downloadStatus,
                  downloadProgress: loadController.progress,
                  onDownload: loadController.load,
                  icon: Icons.upload,
                  tooltip: "Load state",
                );
              }),
          AnimatedBuilder(
              animation: saveController,
              builder: (context, c) {
                return FutureIconButton(
                  status: saveController.downloadStatus,
                  downloadProgress: saveController.progress,
                  onDownload: saveController.save,
                  tooltip: "Save state",
                );
              }),
        ],
      ),
      body: StreamBuilder(
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
                          actionsAlignment: MainAxisAlignment.spaceBetween,
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
                        builder: (context) => RoutinePage(routine: routine),
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
                    subtitle:
                        Text("number of meals: ${routine.meals.value.length}"),
                  ),
                ),
              );
            },
            itemCount: state.routines.value.length + 1,
          );
        },
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
                    for (var item in meal.items.value) {
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
                    return TextButton(
                      onPressed: () async {
                        Model? model = await showCreateModelDialog(
                            context, FoodItemModel.modelType);
                        if (model != null) {
                          meal.items.add(model as FoodItemModel);
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
                      child: Icon(Icons.add),
                    );
                  }
                  var item = meal.items.value[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        // TODO: a route that will delete in case the model is deleted (instead of material page route)
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ItemPage(item: item),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Hero(
                          tag: item,
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

class ItemPage extends StatelessWidget {
  final FoodItemModel item;
  const ItemPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: item.updates(),
      builder: (context, snapshot) {
        var nutritionalValues = item.nutritionalValues.value.entries.toList();
        return Scaffold(
          appBar: AppBar(
            title: Hero(
              tag: item,
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
                        var name = await showTextFieldDialog(
                            context, "Add Nutritional value", "something");
                        if (name != null) {
                          item.nutritionalValues.add(name, intType.create(0));
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
                widget.nutritionalValue.value.set(number);
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
}
