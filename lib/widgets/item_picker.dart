import 'package:app_platform/app_platform.dart';
import 'package:flutter/material.dart';

class ItemPicker<T extends Model> extends StatefulWidget {
  final ListObject<T> items;
  final String Function(T) itemToString;
  final Widget Function(BuildContext, T, void Function() onTap) buildItem;
  final void Function(BuildContext, int) onSelect;

  const ItemPicker({
    super.key,
    required this.items,
    required this.itemToString,
    required this.buildItem,
    required this.onSelect,
  });

  @override
  State<ItemPicker<T>> createState() => _ItemPickerState<T>();
}

class _ItemPickerState<T extends Model> extends State<ItemPicker<T>> {
  Primitive<String> searchContent = stringType.create("");
  List<(int, T)>? items;

  @override
  void initState() {
    super.initState();
    updateItems();
    searchContent.updates().listen(
          (event) => updateItems(),
        );
    widget.items.updates().listen(
          (event) => updateItems(),
        );
  }

  void updateItems() {
    setState(() {
      items = widget.items.value.indexed
          .where((e) => widget.itemToString(e.$2).contains(searchContent.value))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.items.updates(),
        builder: (context, snapshot) {
          return Column(
            children: [
              TextField(
                decoration: InputDecoration(hintText: "search"),
                onChanged: (value) => searchContent.set(value,
                    debounce: Duration(milliseconds: 200)),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) => widget.buildItem(
                    context,
                    items![index].$2,
                    () => widget.onSelect(context, items![index].$1),
                  ),
                  itemCount: items?.length ?? 0,
                ),
              )
            ],
          );
        });
  }
}
