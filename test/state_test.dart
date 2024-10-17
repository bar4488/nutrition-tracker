import 'package:nutrition_routine/models.dart';

void main() {
  var v = {};
  AppState state = AppState.modelBase.create({
    "routines": [
      {
        "name": "routine a",
        "meals": [
          {
            "meal": {
              "items": [
                {
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
  print(state.serialize());
}
