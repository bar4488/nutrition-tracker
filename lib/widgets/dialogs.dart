import 'package:app_platform/app_platform.dart';
import 'package:flutter/material.dart';
import 'package:nutrition_routine/widgets/item_picker.dart';
import 'package:nutrition_routine/widgets/model_creator.dart';

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
        insetPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        contentPadding: EdgeInsets.all(16),
        title: Text(
          "Search",
        ),
        content: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ItemPicker(
              items: items,
              itemToString: toString,
              buildItem: build,
              onSelect: (context, index) {
                Navigator.of(context).pop(items.value[index]);
              },
            ),
          ),
        ),
        actionsPadding: EdgeInsets.only(right: 16, left: 16, bottom: 16),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"))
        ],
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
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(value),
            child: Text("Add"),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
      );
    },
  );
}

Future<void> showAlertDialog(
    BuildContext context, String title, String subtitle) async {
  String? value;
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(subtitle),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text("Ok"),
          ),
        ],
      );
    },
  );
}
