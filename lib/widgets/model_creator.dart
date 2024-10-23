import 'package:app_platform/app_platform.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CreateModel extends StatefulWidget {
  const CreateModel({
    super.key,
    required this.modelType,
    required this.onCreate,
  });

  final ModelType modelType;
  final void Function(Model) onCreate;

  @override
  State<CreateModel> createState() => _CreateModelState();
}

class _CreateModelState extends State<CreateModel> {
  bool isValid = false;
  late final FormGroup form;

  AbstractControl toFormGroup(AppType valueType) {
    switch (valueType) {
      case PrimitiveType value:
        switch (value.getValueType()) {
          case const (int):
            return FormControl<int>(
              validators: [Validators.required, Validators.number()],
            );
          case const (String):
            return FormControl<String>(
              validators: [Validators.required],
            );
          case Type v:
            throw UnimplementedError("PrimitiveType<${v.toString()}>");
        }
      case ModelType modelType:
        var controls = Map.fromEntries(
          modelType.fields
              .where(
                (e) =>
                    e.defaultValue ==
                    null, // take all the fields that do not have default value
              )
              .map(
                (e) => MapEntry(e.name, toFormGroup(e.valueType)),
              ),
        );
        return FormGroup(controls);
      case ListType v:
        throw UnimplementedError(v.toString());
      case MapType v:
        throw UnimplementedError(v.toString());
      case SerializedType v:
        throw UnimplementedError(v.toString());
      case FieldType v:
        throw UnimplementedError(v.toString());
    }
  }

  @override
  void initState() {
    form = toFormGroup(widget.modelType) as FormGroup;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CreateModelContent(
            modelType: widget.modelType,
            form: form,
          ),
          ReactiveFormConsumer(
            builder: (context, form, child) {
              print("form valid? ${form.valid}");
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: form.valid
                    ? FilledButton(
                        onPressed: () {
                          print(form.value);
                          var model = widget.modelType.create(form.value);
                          widget.onCreate(model);
                        },
                        child: Text("Create!"),
                      )
                    : child,
              );
            },
            child: FilledButton(
              onPressed: null,
              child: Text("Create!"),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateModelContent extends StatelessWidget {
  final ModelType modelType;
  final FormGroup form;

  const _CreateModelContent({
    super.key,
    required this.modelType,
    required this.form,
  });

  Widget buildField(FieldType field) {
    print("value type: ${field.valueType}");
    if (field.valueType is PrimitiveType) {
      switch ((field.valueType as PrimitiveType).getValueType()) {
        case const (int):
          return ReactiveTextField(
            formControlName: field.name,
            decoration: InputDecoration(hintText: field.name),
            validationMessages: {
              ValidationMessage.number: (e) => "Invalid number!",
            },
            // validator: (value) {
            //   var a = int.tryParse(value ?? "");
            //   if (a == null) {
            //     return "invalid number!";
            //   }
            //   return null;
            // },
          );
        case const (String):
          print("string!");
          return ReactiveTextField(
            formControlName: field.name,
            decoration: InputDecoration(hintText: field.name),
            validationMessages: {
              ValidationMessage.number: (e) => "Invalid number!",
            },
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return "Field cannot be empty";
            //   }
            //   return null;
            // },
          );
        default:
          print("default!");
          return Text("Unknown Type!");
      }
    } else if (field.valueType is ModelType) {
      var nestedForm = form.control(field.name) as FormGroup;
      return ReactiveForm(
        formGroup: nestedForm,
        child: _CreateModelContent(
          modelType: field.valueType as ModelType,
          form: nestedForm,
        ),
      );
    }
    return Text(field.name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var field in modelType.fields.where(
          (f) => f.defaultValue == null,
        ))
          buildField(field),
      ],
    );
  }
}
