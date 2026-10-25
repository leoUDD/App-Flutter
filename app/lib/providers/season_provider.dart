import 'package:flutter/foundation.dart';

class SeasonProvider extends ChangeNotifier {
  int _season = DateTime.now().year;

  int get season => _season;

  void setseason(int year) {
    if (year == _season) return;
    _season = year;
    notifyListeners();
  }
}
