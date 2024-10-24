import 'package:app_platform/app_platform.dart';
import 'package:flutter/material.dart';
import 'package:nutrition_routine/widgets/simple_tile.dart';

abstract class AbstractListPage<T extends AppObject> {
  final Primitive<String> title;
  final ListObject<T> items;
  final List<T> onDeleteItems;
  final bool canDeletel;

  AbstractListPage({
    required this.title,
    required this.items,
    required this.onDeleteItems,
    required this.canDeletel,
  });
}

class ModelListPage<T extends AppObject> extends StatefulWidget {
  const ModelListPage({
    super.key,
    required this.title,
    required this.items,
    this.onDeleteItems,
    this.tag,
    this.bottomItem,
    required this.itemTitle,
    required this.itemSubTitle,
    required this.itemOnPress,
  });

  final Primitive<String> title;
  final ListObject<T> items;
  final Function(List<T> toDelete)? onDeleteItems;
  final String Function(T item) itemTitle;
  final String? Function(T item) itemSubTitle;
  final void Function(T item) itemOnPress;

  final Object? tag;
  final Widget? bottomItem;

  @override
  State<ModelListPage> createState() => _ModelListPageState<T>();
}

class _ModelListPageState<T extends AppObject> extends State<ModelListPage<T>> {
  List<T>? deleting;
  bool get isDeleting => deleting != null;

  void toggleDelete(T value) {
    {
      setState(() {
        if (deleting == null) {
          setState(() {
            deleting = [value];
          });
        } else {
          if (deleting!.contains(value)) {
            deleting!.remove(value);
            if (deleting!.isEmpty) {
              deleting = null;
            }
          } else {
            deleting!.add(value);
          }
        }
      });
    }
  }

  @override
  build(BuildContext context) {
    Widget title = Text(
      widget.title.value,
      style: Theme.of(context).textTheme.titleLarge,
    );
    if (widget.tag != null) {
      title = Hero(tag: widget.tag!, child: title);
    }
    return StreamBuilder(
      stream: widget.items.updates(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: title,
            actions: isDeleting
                ? [
                    TextButton(
                        onPressed: () {
                          widget.onDeleteItems?.call(deleting!);
                          deleting = null;
                        },
                        child: Text("Delete"))
                  ]
                : null,
          ),
          body: Column(children: [
            Text("Items:"),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  if (index == widget.items.list.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: widget.bottomItem,
                    );
                  }
                  var item = widget.items.list[index];
                  return SimpleCardTile(
                    onTap: () => isDeleting ? null : widget.itemOnPress(item),
                    onLongPress: () => toggleDelete(item),
                    onDelete: () => toggleDelete(item),
                    deleting: deleting != null,
                    isDeleteCandidate: deleting?.contains(item) ?? false,
                    heroTag: item,
                    title: widget.itemTitle(item),
                    subtitle: widget.itemSubTitle(item),
                  );
                },
                itemCount: widget.items.value.length + 1,
              ),
            )
          ]),
        );
      },
    );
  }
}
