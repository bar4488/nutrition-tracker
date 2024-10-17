import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<Map<String, dynamic>> loadState() async {
  final directory = await getApplicationDocumentsDirectory();
  var file = File('${directory.path}/state.json');
  var stateString = await file.readAsString();
  return jsonDecode(stateString);
}

Future<void> saveState(Map<String, dynamic> state) async {
  final directory = await getApplicationDocumentsDirectory();
  var file = File('${directory.path}/state.json');
  await file.create();

  await file.writeAsString(jsonEncode(state));
}
