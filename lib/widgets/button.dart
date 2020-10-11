import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Button extends StatelessWidget {
  Button({@required this.onPressed, @required this.label});

  final GestureTapCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: RawMaterialButton(
        fillColor: Colors.blueGrey,
        splashColor: Colors.white,
        constraints: const BoxConstraints(minWidth: 30.0, minHeight: 36.0),
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: BorderSide(color: Colors.black)),
      ),
    );
  }
}
