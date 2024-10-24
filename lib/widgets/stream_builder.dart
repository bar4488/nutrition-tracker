// import 'package:app_platform/app_platform.dart';
// import 'package:flutter/material.dart';

// class StateBuilder<T extends AppObject, K> extends StatefulWidget {
//   const StateBuilder({
//     super.key,
//   });
//   T state;
//   K Function(T)? transformation;

//   @override
//   State<StateBuilder> createState() => _StateBuilderState<T>();
// }

// class _StateBuilderState<T extends AppObject> extends State<StateBuilder<T>> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       initialData: initialTotals.getValue(),
//       stream: widget.meal.items.updates().map(
//         (event) {
//           Map<String, int> totals = {};
//           for (var item in widget.meal.items.value
//               .where((v) => v.value != null)
//               .map((v) => v.value!)) {
//             for (var entry in item.nutritionalValues.value.entries) {
//               totals[entry.key] = (totals[entry.key] ?? 0) + entry.value.value;
//             }
//           }
//           return totals;
//         },
//       ).distinct(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Text("meal deleted!");
//         }
//         var totals = snapshot.data!;
//         return Column(
//           children: [
//             for (var total in totals.entries)
//               Text("total ${total.key}: ${total.value}"),
//           ],
//         );
//       },
//     );
//   }
// }
