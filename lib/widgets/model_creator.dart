import 'package:app_platform/app_platform.dart';
import 'package:flutter/material.dart';

class CreateModel extends StatefulWidget {
  const CreateModel({
    super.key,
    required this.modelBase,
  });

  final ModelBase modelBase;

  @override
  State<CreateModel> createState() => _CreateModelState();
}

class _CreateModelState extends State<CreateModel> {
  Widget buildField(FieldBase field) {
    if (field.valueBase is PrimitiveBase) {
      switch ((field.valueBase as PrimitiveBase).getValueType()) {
        case int:
          print("int!");
        case String:
          print("string!");
        default:
          print("default!");
      }
    }
    return Text(field.name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var field in widget.modelBase.fields) buildField(field),
      ],
    );
  }
}
