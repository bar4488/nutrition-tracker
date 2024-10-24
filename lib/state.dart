import 'dart:convert';
import 'dart:io';

import 'package:nutrition_routine/models.dart';
import 'package:path_provider/path_provider.dart';

const String currentStateVersion = "1.0";

Map<String?, Migration> migrations = {
  null: Migration(
    startVersion: "None",
    endVersion: "1.0",
    doMigration: (oldState) {
      oldState["version"] = "1.0";
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
      stateJson = migrations[stateJson["version"]]!.doMigration(stateJson);
    }
    stateJson.remove("version"); // the version is not a part of the state
    state = AppState.modelType.create(stateJson);
  } catch (e) {
    // we dont want to override our state anymore...
    if (stateJson["version"] != null) rethrow;
    state = AppState.modelType.create({
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

  final Map<String, dynamic> Function(Map<String, dynamic> oldState)
      doMigration;

  Migration({
    required this.startVersion,
    required this.endVersion,
    required this.doMigration,
  });
}

AppState getState() {
  return app.state;
}

late AppState state;
