import 'package:app_platform/app_platform.dart';
import 'package:flutter/material.dart';

class FoodItemModel extends Model {
  Primitive<String> name;
  MapObject<Primitive<int>> nutritionalValues;

  static final List<FieldType> fields = [
    FieldType<Primitive<String>>("name", stringType),
    FieldType<MapObject<Primitive<int>>>(
      "nutritionalValues",
      MapType<Primitive<int>>(intType),
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
        nutritionalValues = fields[1].value as MapObject<Primitive<int>>;
}

class MealModel extends Model {
  Primitive<String> name;
  ListObject<FoodItemModel> items;

  static final List<FieldType> fields = [
    FieldType<Primitive<String>>("name", stringType),
    FieldType<ListObject<FoodItemModel>>(
      "items",
      ListType<FoodItemModel>(FoodItemModel.modelType),
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
        items = fields[1].value as ListObject<FoodItemModel>;
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
