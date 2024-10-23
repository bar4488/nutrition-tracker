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

  static final ModelType<FoodItemModel> modelType = ModelType(
    "FoodItemModel",
    FoodItemModel.fields,
    FoodItemModel.fromFields,
  );

  FoodItemModel.fromFields(super.fields)
      : name = fields[0].value as Primitive<String>,
        nutritionalValues = fields[1].value as MapObject<Primitive<int>>,
        super(type: modelType);
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

  static final ModelType<MealModel> modelType = ModelType(
    "MealModel",
    MealModel.fields,
    MealModel.fromFields,
  );

  MealModel.fromFields(super.fields)
      : name = fields[0].value as Primitive<String>,
        items = fields[1].value as ListObject<FoodItemModel>,
        super(type: modelType);
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

  static final ModelType<TimedMealModel> modelType = ModelType(
    "TimedMealModel",
    TimedMealModel.fields,
    TimedMealModel.fromFields,
  );

  TimedMealModel.fromFields(super.fields)
      : meal = fields[0].value as MealModel,
        time = fields[1].value as Primitive<TimeOfDay>,
        super(type: modelType);
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

  static final ModelType<RoutineModel> modelType = ModelType(
    "RoutineModel",
    RoutineModel.fields,
    RoutineModel.fromFields,
  );

  RoutineModel.fromFields(super.fields)
      : meals = fields[0].value as ListObject<TimedMealModel>,
        name = fields[1].value as Primitive<String>,
        super(type: modelType);
}

class AppState extends Model {
  ListObject<RoutineModel> routines;

  // boilerplate
  static final List<FieldType> fields = [
    FieldType<ListObject<RoutineModel>>(
      "routines",
      ListType<RoutineModel>(RoutineModel.modelType),
      defaultValue: () => [],
    ),
  ];

  static final ModelType<AppState> modelType = ModelType(
    "State",
    AppState.fields,
    AppState.fromFields,
  );

  AppState.fromFields(super.fields)
      : routines = fields[0].value as ListObject<RoutineModel>,
        super(type: modelType);
}
