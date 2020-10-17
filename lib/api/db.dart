import 'package:shared_preferences/shared_preferences.dart';
import 'package:xkcd/utils/consts.dart';

class Db {
  Future<List<String>> readFromFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final key = FAVORITES;
    final value = prefs.getStringList(key) ?? [];
    return value;
  }
}