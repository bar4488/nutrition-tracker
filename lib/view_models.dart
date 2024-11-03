import 'package:app_platform/app_platform.dart';

class SimpleListData extends ViewModel {
  Primitive<String> title;
  ListObject<AbstractListType, SimpleTileData> items;

  SimpleListData({
    required this.title,
    required this.items,
  }) : super([title, items], [], SimpleTileData.Type);

  static final ViewModelType Type = ViewModelType(
      "SimpleListPage",
      [
        ViewFieldType("title", stringType),
        ViewFieldType("items", stringType),
      ],
      [],
      constructor: SimpleTileData._from);

  SimpleListData._from(super.fields, super.actions, super.type)
      : title = fields[0] as Primitive<String>,
        items = fields[1] as ListObject<AbstractListType, SimpleTileData>;

  SimpleListData.from({
    required List<AppObject> fields,
    required List<ViewAction> actions,
  }) : this._from(fields, actions, SimpleTileData.Type);
}

class SimpleTileData extends ViewModel {
  Primitive<String> title;
  Primitive<String> subtitle;
  ViewAction<void, void> onPress;

  SimpleTileData({
    required this.title,
    required this.subtitle,
    required this.onPress,
  }) : super([title, subtitle], [onPress], SimpleTileData.Type);

  static final ViewModelType Type = ViewModelType(
      "SimpleTileData",
      [
        StateFieldType("title", stringType),
        StateFieldType("subtitle", stringType),
      ],
      [
        ActionType("onPress"),
      ],
      constructor: SimpleTileData._from);

  SimpleTileData._from(super.fields, super.actions, super.type)
      : title = fields[0] as Primitive<String>,
        subtitle = fields[1] as Primitive<String>,
        onPress = actions[0];

  SimpleTileData.from({
    required List<AppObject> fields,
    required List<ViewAction> actions,
  }) : this._from(fields, actions, SimpleTileData.Type);

  static Transformation transformation<T extends AppObject>({
    required Transformation title,
    required Transformation subtitle,
  }) {
    return ChainTransformation(
      [
        ModelTransformation(
          fields: [
            (name: "title", transformation: title),
            (name: "subtitle", transformation: subtitle)
          ],
        ),
        CastModel(
          SimpleListData.Type,
          (f) => SimpleListData.from(
            actions: [ViewAction()],
            fields: f,
          ),
        ),
      ],
    );
  }
}
