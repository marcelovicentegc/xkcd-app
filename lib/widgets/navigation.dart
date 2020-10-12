import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xkcd/widgets/button.dart';

class Navigation extends StatelessWidget {
  Navigation(
      {@required this.onPressedNext,
      @required this.onPressedPrevious,
      @required this.onPressedRandom,
      @required this.onPressedLast,
      @required this.onPressedFirst});

  final GestureTapCallback onPressedNext;
  final GestureTapCallback onPressedPrevious;
  final GestureTapCallback onPressedRandom;
  final GestureTapCallback onPressedLast;
  final GestureTapCallback onPressedFirst;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Button(
          onPressed: () {
            onPressedFirst();
          },
          label: "|<",
        ),
        Button(
          onPressed: () {
            onPressedPrevious();
          },
          label: "< Prev",
        ),
        Button(
          onPressed: () {
            onPressedRandom();
          },
          label: "Random",
        ),
        Button(
          onPressed: () {
            onPressedNext();
          },
          label: "Next >",
        ),
        Button(
          onPressed: () {
            onPressedLast();
          },
          label: ">|",
        )
      ],
    );
  }
}
