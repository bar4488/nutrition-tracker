import 'package:flutter/material.dart';

class SimpleCardTile extends StatelessWidget {
  const SimpleCardTile({
    super.key,
    this.onTap,
    this.title,
    this.subtitle,
    this.heroTag,
    this.onDelete,
    this.onLongPress,
    this.deleting = false,
    this.isDeleteCandidate = false,
    this.icon,
  });

  final void Function()? onTap;
  final void Function()? onDelete;
  final void Function()? onLongPress;
  final bool deleting;
  final bool isDeleteCandidate;
  final Icon? icon;
  final String? title;
  final String? subtitle;
  final Object? heroTag;

  Widget getDeleteIconButton() {
    return isDeleteCandidate
        ? IconButton.filledTonal(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          )
        : IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: ListTile(
          leading: deleting ? getDeleteIconButton() : icon,
          title: Hero(
            tag: heroTag ?? 0,
            child: Text(
              title ?? "",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          subtitle: Text(subtitle ?? ""),
        ),
      ),
    );
  }
}
