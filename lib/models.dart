import 'package:app_platform/app_platform.dart';
import 'package:flutter/material.dart';

class FoodItemModel extends Model<FoodItemModel> {
  Primitive<String> name;
  MapType<Primitive<int>> nutritionalValues;

  static final List<FieldBase> fields = [
    FieldBase<Primitive<String>>("name", stringType),
    FieldBase<MapType<Primitive<int>>>(
      "nutritionalValues",
      MapBase<Primitive<int>>(intType),
    ),
  ];

  static final ModelBase<FoodItemModel> modelBase = ModelBase(
    "FoodItemModel",
    FoodItemModel.fields,
    FoodItemModel.fromFields,
  );

  FoodItemModel.fromFields(super.fields)
      : name = fields[0].value as Primitive<String>,
        nutritionalValues = fields[1].value as MapType<Primitive<int>>,
        super(base: modelBase);
}

class MealModel extends Model<MealModel> {
  Primitive<String> name;
  ListType<FoodItemModel> items;

  static final List<FieldBase> fields = [
    FieldBase<Primitive<String>>("name", stringType),
    FieldBase<ListType<FoodItemModel>>(
      "items",
      ListBase<FoodItemModel>(FoodItemModel.modelBase),
    ),
  ];

  static final ModelBase<MealModel> modelBase = ModelBase(
    "MealModel",
    MealModel.fields,
    MealModel.fromFields,
  );

  MealModel.fromFields(super.fields)
      : name = fields[0].value as Primitive<String>,
        items = fields[1].value as ListType<FoodItemModel>,
        super(base: modelBase);
}

class TimedMealModel extends Model<TimedMealModel> {
  MealModel meal;
  Primitive<TimeOfDay> time;

  static final List<FieldBase> fields = [
    FieldBase<MealModel>("meal", MealModel.modelBase),
    FieldBase<Primitive<TimeOfDay>>(
        "time",
        SerializedBase<TimeOfDay>(
          (value) => value.hour * 60 + value.minute,
          (value) => TimeOfDay(hour: value ~/ 60, minute: value % 60),
          (value) => value is int,
        )),
  ];

  static final ModelBase<TimedMealModel> modelBase = ModelBase(
    "TimedMealModel",
    TimedMealModel.fields,
    TimedMealModel.fromFields,
  );

  TimedMealModel.fromFields(super.fields)
      : meal = fields[0].value as MealModel,
        time = fields[1].value as Primitive<TimeOfDay>,
        super(base: modelBase);
}

class RoutineModel extends Model<RoutineModel> {
  Primitive<String> name;
  ListType<TimedMealModel> meals;

  // boilerplate
  static final List<FieldBase> fields = [
    FieldBase<ListType<TimedMealModel>>(
      "meals",
      ListBase<TimedMealModel>(TimedMealModel.modelBase),
    ),
    FieldBase<Primitive<String>>("name", stringType)
  ];

  static final ModelBase<RoutineModel> modelBase = ModelBase(
    "RoutineModel",
    RoutineModel.fields,
    RoutineModel.fromFields,
  );

  RoutineModel.fromFields(super.fields)
      : meals = fields[0].value as ListType<TimedMealModel>,
        name = fields[1].value as Primitive<String>,
        super(base: modelBase);
}

class AppState extends Model<AppState> {
  ListType<RoutineModel> routines;

  // boilerplate
  static final List<FieldBase> fields = [
    FieldBase<ListType<RoutineModel>>(
        "routines", ListBase<RoutineModel>(RoutineModel.modelBase)),
  ];

  static final ModelBase<AppState> modelBase = ModelBase(
    "State",
    AppState.fields,
    AppState.fromFields,
  );

  AppState.fromFields(super.fields)
      : routines = fields[0].value as ListType<RoutineModel>,
        super(base: modelBase);
}
