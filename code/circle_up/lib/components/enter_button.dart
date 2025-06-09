import 'package:flutter/material.dart';

/// A reusable button component that follows a consistent design pattern.
/// This button is styled with a black background, white text, and rounded corners.
/// It's designed to be used for primary actions throughout the app.
class EnterButton extends StatelessWidget {
  /// The text to be displayed on the button
  final String text;

  /// The callback function to be executed when the button is tapped
  final Function()? onTap;

  /// The background color of the button
  final Color? backgroundColor;

  /// the constructor for the enterbutton class
  /// Parameters:
  /// - text: The button label.
  /// - onTap: The function to execute on tap
  /// - backgroundColor: The background color of the button
  const EnterButton({
    super.key,
    required this.onTap,
    required this.text,
    this.backgroundColor,
  });

  /// The build method that creates the widget for the class
  /// Parameters:
  /// - context: the build context from flutter's widget tree
  /// Returns: a semantic labels with a button with full-width layout,
  /// black background, white text, and rounded corners.
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
            color: backgroundColor ?? Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: (backgroundColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          // Center the text within the button
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
