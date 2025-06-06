import 'package:flutter/material.dart';

/// A reusable button component that follows a consistent design pattern.
/// This button is styled with a black background, white text, and rounded corners.
/// It's designed to be used for primary actions throughout the app.
class EnterButton extends StatelessWidget {
  /// The text to be displayed on the button
  final String text;

  /// The callback function to be executed when the button is tapped
  final Function()? onTap;

  /// Creates an EnterButton widget
  ///
  /// [text] is required and specifies the button label
  /// [onTap] is required and specifies the action to perform when pressed
  const EnterButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: text,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          // Make button take full width of parent
          width: double.infinity,
          // Fixed height for consistency
          height: 50.0,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          // Add horizontal margin around the button
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          // Style the button container
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.0),
          ),
          // Center the text within the button
          child: Center(
            child: Text(text, style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
