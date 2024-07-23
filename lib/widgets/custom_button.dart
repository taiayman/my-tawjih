import 'package:flutter/material.dart';

class NeuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed; // Make onPressed nullable
  final Color color;
  final double height;
  final double width;

  const NeuButton({
    Key? key,
    required this.child,
    required this.onPressed, // Now onPressed is nullable
    this.color = Colors.white,
    this.height = 50,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  _NeuButtonState createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _isPressed = false;
    });
    // Call onPressed only if it's not null
    widget.onPressed?.call(); 
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(50),
          boxShadow: _isPressed
              ? []
              : [
                
                  
                ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}