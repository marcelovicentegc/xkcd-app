import 'package:flutter/material.dart';
import 'package:xkcd/utils/consts.dart';

void displayAltContent({ctx: BuildContext, title: String, alt: String}) {
  showDialog(
    context: ctx,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return new AlertDialog(
        title: new Text(title),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: [
              new Text(alt),
            ],
          ),
        ),
        actions: [
          new FlatButton(
            child: new Text(CLOSE),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void displayConfirmationModal(
    {ctx: BuildContext,
    title: String,
    content: String,
    onPressedOk: Function}) {
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      onPressedOk();
      Navigator.pop(ctx);
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: ctx,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
