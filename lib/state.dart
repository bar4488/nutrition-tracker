import 'dart:convert';
import 'dart:io';

import 'package:nutrition_routine/models.dart';
import 'package:path_provider/path_provider.dart';

const String currentStateVersion = "1.1";

Map<String?, Migration> migrations = {
  null: Migration(
    startVersion: "None",
    endVersion: "1.0",
    description: "introduced versioning",
    doMigration: (oldState) {
      oldState["version"] = "1.0";
      return oldState;
    },
  ),
  "1.0": Migration(
    startVersion: "1.0",
    endVersion: "1.1",
    description: "changed amount to be a double in foodItems",
    doMigration: (oldState) {
      for (var item in oldState["foodItems"]) {
        for (var value
            in (item["nutritionalValues"] as Map<String, dynamic>).values) {
          if (value["amount"] is int) {
            value["amount"] = (value["amount"] as int).toDouble();
          }
        }
      }
      return oldState;
    },
  ),
};

Future<Map<String, dynamic>> loadState() async {
  final directory = await getApplicationDocumentsDirectory();
  var file = File('${directory.path}/state.json');
  var stateString = await file.readAsString();
  return jsonDecode(stateString);
}

Future<void> saveState(Map<String, dynamic> state) async {
  state["version"] = currentStateVersion;
  final directory = await getApplicationDocumentsDirectory();
  var file = File('${directory.path}/state.json');
  await file.create();

  await file.writeAsString(jsonEncode(state));
}

Future initAppState() async {
  AppState state;
  var stateJson = await loadState();
  try {
    while (stateJson["version"] != currentStateVersion) {
      stateJson = migrations[stateJson["version"]]!.apply(stateJson);
    }
    stateJson.remove("version"); // the version is not a part of the state
    state = AppState.Type.create(stateJson);
  } catch (e) {
    // we dont want to override our state anymore...
    if (stateJson["version"] != null) rethrow;
    state = AppState.Type.create({
      "version": 1,
      "routines": [
        {
          "name": "routine a",
          "meals": [
            {
              "meal": {
                "name": "nutty pudding",
                "items": [
                  {
                    "item": "strawberries",
                    "amount": 123,
                  }
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
            "calories": {
              "amount": 100,
              "unit": "cal",
            },
          },
        }
      ]
    });
  }
  app.initialize(state);
}

class Migration {
  final String startVersion;
  final String endVersion;
  final String description;

  final Map<String, dynamic> Function(Map<String, dynamic> oldState)
      doMigration;

  Migration({
    required this.startVersion,
    required this.endVersion,
    required this.doMigration,
    required this.description,
  });

  Map<String, dynamic> apply(Map<String, dynamic> oldState) {
    var state = doMigration(oldState);
    state["version"] = endVersion;
    return state;
  }
}

AppState getState() {
  return app.state;
}

late AppState state;
