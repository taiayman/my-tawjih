import 'package:flutter/material.dart';

class DynamicText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const DynamicText({
    Key? key,
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
  }) : super(key: key);

  @override
  _DynamicTextState createState() => _DynamicTextState();
}

class _DynamicTextState extends State<DynamicText> {
  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      style: TextStyle(
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        color: widget.color, // Now expecting a non-nullable Color
      ),
      child: Text(widget.text),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}