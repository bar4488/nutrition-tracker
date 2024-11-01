// ignore_for_file: non_constant_identifier_names

import 'package:app_platform/app_platform.dart';
import 'package:flutter/material.dart';

final app = AnApp<AppState>();

class NutritionValueModel extends Model {
  StatePrimitive<double> amount;
  StatePrimitive<String> unit;

  String get displayValue => "${amount.value} ${unit.value}";

  static final List<StateFieldType> Fields = [
    StateFieldType<StatePrimitive<double>>("amount", doubleType),
    StateFieldType<StatePrimitive<String>>("unit", stringType),
  ];

  static final StateModelType<NutritionValueModel> Type =
      StateModelType<NutritionValueModel>(
    "NutritionValueModel",
    NutritionValueModel.Fields,
    constructor: NutritionValueModel.fromFields,
  );

  NutritionValueModel.fromFields(super.fields, super.type)
      : amount = fields[0] as StatePrimitive<double>,
        unit = fields[1] as StatePrimitive<String>;
}

class FoodItemModel extends Model {
  StatePrimitive<String> name;
  MapObject<NutritionValueModel> nutritionalValues;
  MapObject<StatePrimitive<String>> additionalValues;

  static final List<StateFieldType> Fields = [
    StateFieldType<StatePrimitive<String>>("name", stringType),
    StateFieldType<MapObject<NutritionValueModel>>(
      "nutritionalValues",
      MapType<NutritionValueModel>(NutritionValueModel.Type),
      defaultValue: () => {},
    ),
    StateFieldType<MapObject<StatePrimitive<String>>>(
      "additionalValues",
      MapType<StatePrimitive<String>>(stringType),
      defaultValue: () => {},
    ),
  ];

  static final StateModelType<FoodItemModel> Type =
      StateModelType<FoodItemModel>(
    "FoodItemModel",
    FoodItemModel.Fields,
    constructor: FoodItemModel.fromFields,
  );

  FoodItemModel.fromFields(super.fields, super.type)
      : name = fields[0] as StatePrimitive<String>,
        nutritionalValues = fields[1] as MapObject<NutritionValueModel>,
        additionalValues = fields[2] as MapObject<StatePrimitive<String>>;

  factory FoodItemModel.create(Map<String, dynamic> map) {
    return FoodItemModel.Type.create(map);
  }
}

class MealItemModel extends Model {
  NamedReferenceObject<FoodItemModel, String> item;
  StatePrimitive<int> amount;

  static final List<StateFieldType> Fields = [
    StateFieldType<NamedReferenceObject<FoodItemModel, String>>(
      "item",
      NamedReferenceType<FoodItemModel, String>(
        FoodItemModel.Type,
        app,
        retrieve: (name, app) {
          return (app.state as AppState)
              .foodItems
              .list
              .where(
                (element) => element.name.value == name,
              )
              .firstOrNull;
        },
        shouldNotifyChanges: true,
      ),
    ),
    StateFieldType<StatePrimitive<int>>("amount", intType),
  ];

  static final StateModelType<MealItemModel> Type =
      StateModelType<MealItemModel>(
    "MealItemModel",
    MealItemModel.Fields,
    constructor: MealItemModel.fromFields,
  );

  MealItemModel.fromFields(super.fields, super.type)
      : item = fields[0] as NamedReferenceObject<FoodItemModel, String>,
        amount = fields[1] as StatePrimitive<int>;

  factory MealItemModel.create(Map<String, dynamic> map) {
    return MealItemModel.Type.create(map);
  }
}

class MealModel extends Model {
  StatePrimitive<String> name;
  ListObject<MealItemModel> items;

  static final List<StateFieldType> Fields = [
    StateFieldType<StatePrimitive<String>>("name", stringType),
    StateFieldType<ListObject<MealItemModel>>(
      "items",
      ListType<MealItemModel>(MealItemModel.Type),
      defaultValue: () => [],
    ),
  ];

  static final StateModelType<MealModel> Type = StateModelType<MealModel>(
    "MealModel",
    MealModel.Fields,
    constructor: MealModel.fromFields,
  );

  MealModel.fromFields(super.fields, super.type)
      : name = fields[0] as StatePrimitive<String>,
        items = fields[1] as ListObject<MealItemModel>;
}

class TimedMealModel extends Model {
  MealModel meal;
  StatePrimitive<TimeOfDay> time;

  static final List<StateFieldType> Fields = [
    StateFieldType<MealModel>("meal", MealModel.Type),
    StateFieldType<StatePrimitive<TimeOfDay>>(
      "time",
      SerializedType<TimeOfDay>(
        (value) => value.hour * 60 + value.minute,
        (value) => TimeOfDay(hour: value ~/ 60, minute: value % 60),
        (value) => value is int,
      ),
      defaultValue: () => TimeOfDay.now(),
    ),
  ];

  static final StateModelType<TimedMealModel> Type =
      StateModelType<TimedMealModel>(
    "TimedMealModel",
    TimedMealModel.Fields,
    constructor: TimedMealModel.fromFields,
  );

  TimedMealModel.fromFields(super.fields, super.type)
      : meal = fields[0] as MealModel,
        time = fields[1] as StatePrimitive<TimeOfDay>;
}

class RoutineModel extends Model {
  StatePrimitive<String> name;
  ListObject<TimedMealModel> meals;

  // boilerplate
  static final List<StateFieldType> Fields = [
    StateFieldType<ListObject<TimedMealModel>>(
      "meals",
      ListType<TimedMealModel>(TimedMealModel.Type),
      defaultValue: () => [],
    ),
    StateFieldType<StatePrimitive<String>>("name", stringType)
  ];

  static final StateModelType<RoutineModel> Type = StateModelType<RoutineModel>(
    "RoutineModel",
    RoutineModel.Fields,
    constructor: RoutineModel.fromFields,
  );

  RoutineModel.fromFields(super.fields, super.type)
      : meals = fields[0] as ListObject<TimedMealModel>,
        name = fields[1] as StatePrimitive<String>;
}

class AppState extends Model {
  ListObject<RoutineModel> routines;
  ListObject<FoodItemModel> foodItems;

  // boilerplate
  static final List<StateFieldType> Fields = [
    StateFieldType<ListObject<RoutineModel>>(
      "routines",
      ListType<RoutineModel>(RoutineModel.Type),
      defaultValue: () => [],
    ),
    StateFieldType<ListObject<FoodItemModel>>(
      "foodItems",
      ListType<FoodItemModel>(FoodItemModel.Type),
      defaultValue: () => [],
    ),
  ];

  static final StateModelType<AppState> Type = StateModelType<AppState>(
    "State",
    AppState.Fields,
    constructor: AppState.fromFields,
  );

  AppState.fromFields(super.fields, super.type)
      : routines = fields[0] as ListObject<RoutineModel>,
        foodItems = fields[1] as ListObject<FoodItemModel>;
}
