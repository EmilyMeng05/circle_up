import 'package:flutter/material.dart';

/// A reusable text field component that follows a consistent design pattern.
/// This text field is styled with a light grey background, white borders,
/// and supports both regular and password input modes.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? prefixIcon;

  /// The constructor for the customTextfield class
  /// Parameters:
  /// - controller: manages the text field's content
  /// - hintText: specifies the placeholder text
  /// - obscureText: determines if the text should be hidden
  /// - prefixIcon: optional prefix icon to be displayed before the text field
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.prefixIcon,
  });

  /// The build method that creates the text field widget
  /// Returns:
  /// - a padded Textfield with semantic labels,
  /// the text has light grey background and obscure text option for password
  /// white border when inactive and greyy border when focused
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Semantics(
        label: hintText,
        textField: true,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            fillColor: Colors.white,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }
}
