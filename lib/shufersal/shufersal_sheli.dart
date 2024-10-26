// import 'package:shufersal_sheli/shufersal_sheli.dart' as shufersal_sheli;

import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

Map<String, String> nutritionalValuesTranslation = {
  "אנרגיה": "calories",
  "כולסטרול": "cholesterol",
  "נתרן": "sodium",
  "מתוכם שומן רווי": "saturated fats",
  "חומצות שומן טאנס": "trans fats",
  "פחמימות": "carbs",
  "חלבונים": "proteins",
  "שומנים": "fats",
  "סוכרים מתוך פחמימות": "sugars",
  "סוכרים": "sugars",
  "סיבים תזונתיים": "fibers",
};
Map<String, String> unitsTranslation = {
  "גרם": "g",
  "מג": "mg",
  "מ\"ג": "mg",
  "קל": "cal",
  "קלוריות": "cal",
};

Map<String, double> unitToGrams = {
  "milligrams": 0.001,
  "kg": 1000,
};

class Food {
  String name;
  String company;
  String amount;
  String code;
  String? country;
  Map<String, String> others;
  String ingredients;
  String? contains;
  String? mayContain;
  String? type;

  Map<String, Map<String, Map<String, dynamic>>> nutritionValue;
  Food({
    required this.name,
    required this.company,
    required this.amount,
    required this.code,
    required this.country,
    required this.others,
    required this.ingredients,
    required this.contains,
    this.mayContain,
    required this.type,
    required this.nutritionValue,
  });

  @override
  String toString() {
    return 'Food(name: $name, company: $company, amount: $amount, code: $code, country: $country, others: $others, ingredients: $ingredients, contains: $contains, mayContain: $mayContain, type: $type, nutritionValue: $nutritionValue)';
  }
}

Map<String, String> parseContent(Element e) {
  return {
    for (var v in e.getElementsByClassName("box"))
      v.children[0].text.trim().replaceAll(":", ""): v.children[1].text.trim()
  };
}

Map<String, Map<String, dynamic>> parseNutritionValues(Element e) {
  return {
    for (var v in e.getElementsByClassName("nutritionItem"))
      v.getElementsByClassName("text")[0].text.trim(): {
        "unit": v.getElementsByClassName("name")[0].text.trim(),
        "amount": v.getElementsByClassName("number")[0].text.trim(),
      }
  };
}

Future<Food?> fetchFoodFromBarcode(String barcode) async {
  if (barcode.startsWith("729000")) {
    barcode = barcode.substring(3);
    barcode = barcode.replaceFirst(RegExp("0+"), "");
  }
  var res = await http.read(
      Uri.parse('https://www.shufersal.co.il/online/he/p/P_$barcode/json'));

  var document = parse(res);

  var name = document.getElementById("modalTitle")!.innerHtml.trim();

  var details = document.getElementById("techDetails")!;
  var container = details.getElementsByClassName("productContainer")[0];

  var list = container.children;
  Map<String, dynamic> itemsMap = {
    for (var v in list.where((e) =>
        e.children.length == 2 &&
        e.children[0].className == "title" &&
        e.children[1].className == "info"))
      v.children[0].text.trim(): v.children[1]
  };

  Map<String, Map<String, Map<String, dynamic>>> nutritionsMap = {
    for (var v in list.where((Element e) =>
        e.children.length == 2 &&
        e.children[0].className == "title nutritionListTitle"))
      v.children[0].children[1].text: parseNutritionValues(v.children[1])
  };

  var contents = parseContent(itemsMap["נתונים"]!);
  itemsMap.remove("נתונים");

  var map = itemsMap.map(
    (key, value) => MapEntry(key, (value as Element).text.trim()),
  );
  return Food(
    name: name,
    company: contents["מותג/יצרן"]!,
    amount: contents["מידה/סוג"]!,
    code: contents["מק\"ט"]!,
    country: contents["ארץ ייצור"],
    others: contents,
    ingredients: map["רכיבים"]!,
    contains: map["מכיל"],
    mayContain: map["עלול להכיל"],
    nutritionValue: nutritionsMap,
    type: map["סימון בריאותי"],
  );
}
