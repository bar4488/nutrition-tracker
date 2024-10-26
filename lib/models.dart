import 'package:app_platform/app_platform.dart';
import 'package:flutter/material.dart';

final app = AnApp<AppState>();

class NutritionValueModel extends Model {
  Primitive<double> amount;
  Primitive<String> unit;

  String get displayValue => "${amount.value} ${unit.value}";

  static final List<FieldType> fields = [
    FieldType<Primitive<double>>("amount", doubleType),
    FieldType<Primitive<String>>("unit", stringType),
  ];

  static final ModelType<NutritionValueModel> modelType =
      ModelType<NutritionValueModel>(
    "NutritionValueModel",
    NutritionValueModel.fields,
    constructor: NutritionValueModel.fromFields,
  );

  NutritionValueModel.fromFields(super.fields, super.type)
      : amount = fields[0].value as Primitive<double>,
        unit = fields[1].value as Primitive<String>;
}

class FoodItemModel extends Model {
  Primitive<String> name;
  MapObject<NutritionValueModel> nutritionalValues;
  MapObject<Primitive<String>> additionalValues;

  static final List<FieldType> fields = [
    FieldType<Primitive<String>>("name", stringType),
    FieldType<MapObject<NutritionValueModel>>(
      "nutritionalValues",
      MapType<NutritionValueModel>(NutritionValueModel.modelType),
      defaultValue: () => {},
    ),
    FieldType<MapObject<Primitive<String>>>(
      "additionalValues",
      MapType<Primitive<String>>(stringType),
      defaultValue: () => {},
    ),
  ];

  static final ModelType<FoodItemModel> modelType = ModelType<FoodItemModel>(
    "FoodItemModel",
    FoodItemModel.fields,
    constructor: FoodItemModel.fromFields,
  );

  FoodItemModel.fromFields(super.fields, super.type)
      : name = fields[0].value as Primitive<String>,
        nutritionalValues = fields[1].value as MapObject<NutritionValueModel>,
        additionalValues = fields[2].value as MapObject<Primitive<String>>;
}

class MealItemModel extends Model {
  NamedReferenceObject<FoodItemModel, String> item;
  Primitive<int> amount;

  static final List<FieldType> fields = [
    FieldType<NamedReferenceObject<FoodItemModel, String>>(
      "item",
      NamedReferenceType<FoodItemModel, String>(
        FoodItemModel.modelType,
        app,
        retrieve: (name, app) {
          return (app.state as AppState)
              .foodItems
              .value
              .where(
                (element) => element.name.value == name,
              )
              .firstOrNull;
        },
        shouldNotifyChanges: true,
      ),
    ),
    FieldType<Primitive<int>>("amount", intType),
  ];

  static final ModelType<MealItemModel> modelType = ModelType<MealItemModel>(
    "MealItemModel",
    MealItemModel.fields,
    constructor: MealItemModel.fromFields,
  );

  MealItemModel.fromFields(super.fields, super.type)
      : item = fields[0].value as NamedReferenceObject<FoodItemModel, String>,
        amount = fields[1].value as Primitive<int>;
}

class MealModel extends Model {
  Primitive<String> name;
  ListObject<MealItemModel> items;

  static final List<FieldType> fields = [
    FieldType<Primitive<String>>("name", stringType),
    FieldType<ListObject<MealItemModel>>(
      "items",
      ListType<MealItemModel>(MealItemModel.modelType),
      defaultValue: () => [],
    ),
  ];

  static final ModelType<MealModel> modelType = ModelType<MealModel>(
    "MealModel",
    MealModel.fields,
    constructor: MealModel.fromFields,
  );

  MealModel.fromFields(super.fields, super.type)
      : name = fields[0].value as Primitive<String>,
        items = fields[1].value as ListObject<MealItemModel>;
}

class TimedMealModel extends Model {
  MealModel meal;
  Primitive<TimeOfDay> time;

  static final List<FieldType> fields = [
    FieldType<MealModel>("meal", MealModel.modelType),
    FieldType<Primitive<TimeOfDay>>(
      "time",
      SerializedType<TimeOfDay>(
        (value) => value.hour * 60 + value.minute,
        (value) => TimeOfDay(hour: value ~/ 60, minute: value % 60),
        (value) => value is int,
      ),
      defaultValue: () => TimeOfDay.now(),
    ),
  ];

  static final ModelType<TimedMealModel> modelType = ModelType<TimedMealModel>(
    "TimedMealModel",
    TimedMealModel.fields,
    constructor: TimedMealModel.fromFields,
  );

  TimedMealModel.fromFields(super.fields, super.type)
      : meal = fields[0].value as MealModel,
        time = fields[1].value as Primitive<TimeOfDay>;
}

class RoutineModel extends Model {
  Primitive<String> name;
  ListObject<TimedMealModel> meals;

  // boilerplate
  static final List<FieldType> fields = [
    FieldType<ListObject<TimedMealModel>>(
      "meals",
      ListType<TimedMealModel>(TimedMealModel.modelType),
      defaultValue: () => [],
    ),
    FieldType<Primitive<String>>("name", stringType)
  ];

  static final ModelType<RoutineModel> modelType = ModelType<RoutineModel>(
    "RoutineModel",
    RoutineModel.fields,
    constructor: RoutineModel.fromFields,
  );

  RoutineModel.fromFields(super.fields, super.type)
      : meals = fields[0].value as ListObject<TimedMealModel>,
        name = fields[1].value as Primitive<String>;
}

class AppState extends Model {
  ListObject<RoutineModel> routines;
  ListObject<FoodItemModel> foodItems;

  // boilerplate
  static final List<FieldType> fields = [
    FieldType<ListObject<RoutineModel>>(
      "routines",
      ListType<RoutineModel>(RoutineModel.modelType),
      defaultValue: () => [],
    ),
    FieldType<ListObject<FoodItemModel>>(
      "foodItems",
      ListType<FoodItemModel>(FoodItemModel.modelType),
      defaultValue: () => [],
    ),
  ];

  static final ModelType<AppState> modelType = ModelType<AppState>(
    "State",
    AppState.fields,
    constructor: AppState.fromFields,
  );

  AppState.fromFields(super.fields, super.type)
      : routines = fields[0].value as ListObject<RoutineModel>,
        foodItems = fields[1].value as ListObject<FoodItemModel>;
}
