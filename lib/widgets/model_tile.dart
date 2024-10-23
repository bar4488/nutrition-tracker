import 'package:flutter/material.dart';

class SimpleCardTile extends StatelessWidget {
  const SimpleCardTile(
      {super.key, this.onTap, this.title, this.subtitle, this.heroTag});

  final void Function()? onTap;
  final String? title;
  final String? subtitle;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
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
