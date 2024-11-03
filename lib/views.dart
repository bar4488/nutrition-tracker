import 'package:flutter/material.dart';
import 'package:flutter_app_platform/widgets/value_builder.dart';

import 'view_models.dart';

class SimpleListPage extends StatefulWidget {
  const SimpleListPage({
    super.key,
    required this.model,
    this.tag,
  });

  final SimpleListData model;

  final Object? tag;

  @override
  State<SimpleListPage> createState() => _SimpleListPageState();
}

class _SimpleListPageState extends State<SimpleListPage> {
  @override
  build(BuildContext context) {
    Widget title = Text(
      widget.model.title.value,
      style: Theme.of(context).textTheme.titleLarge,
    );
    if (widget.tag != null) {
      title = Hero(tag: widget.tag!, child: title);
    }
    return StreamBuilder(
      stream: widget.model.items.updates(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: title,
          ),
          body: Column(children: [
            const Text("Items:"),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  var item = widget.model.items.list[index];
                  return SimpleCardTile(
                    model: item,
                  );
                },
                itemCount: widget.model.items.list.length,
              ),
            )
          ]),
        );
      },
    );
  }
}

class SimpleCardTile extends StatefulWidget {
  const SimpleCardTile({
    super.key,
    required this.model,
  });

  final SimpleTileData model;

  @override
  State<SimpleCardTile> createState() => _SimpleCardTileState();
}

class _SimpleCardTileState extends State<SimpleCardTile> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: ValueBuilder(
          valueHolder: widget.model.title,
          builder: (context, data) {
            return Text(
              data,
              style: Theme.of(context).textTheme.titleMedium,
            );
          },
        ),
        subtitle: ValueBuilder(
          valueHolder: widget.model.subtitle,
          builder: (context, value) {
            return Text(
              value,
            );
          },
        ),
      ),
    );
  }
}
