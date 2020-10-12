import 'dart:math';

class Utils {
  int generateRandomNumber({latestComicId: int}) {
    return Random().nextInt(latestComicId + 1);
  }
}
