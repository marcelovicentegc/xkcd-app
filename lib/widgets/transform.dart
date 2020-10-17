import 'package:flutter/widgets.dart';

class TransformWidget extends StatefulWidget {
  final Widget child;
  final Matrix4 matrix;

  const TransformWidget({Key key, @required this.child, @required this.matrix})
      : assert(child != null),
        super(key: key);

  @override
  TransformWidgetState createState() => TransformWidgetState();
}

class TransformWidgetState extends State<TransformWidget> {
  Matrix4 _matrix = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    return _matrix != null
        ? Transform(
            transform: (widget.matrix * _matrix),
            child: widget.child,
          )
        : Container();
  }

  void setMatrix(Matrix4 matrix) {
    setState(() {
      _matrix = matrix;
    });
  }
}
