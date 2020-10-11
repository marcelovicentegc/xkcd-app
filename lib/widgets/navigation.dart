import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xkcd/widgets/button.dart';

class Navigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Button(
          onPressed: () {
            print('Navigate to first one');
          },
          label: "|<",
        ),
        Button(
          onPressed: () {
            print('Navigate to previous one');
          },
          label: "< Prev",
        ),
        Button(
          onPressed: () {
            print('Navigate to random one');
          },
          label: "Random",
        ),
        Button(
          onPressed: () {
            print('Navigate to next one');
          },
          label: "Next >",
        ),
        Button(
          onPressed: () {
            print('Navigate to last one');
          },
          label: ">|",
        )
      ],
    );
  }
}
