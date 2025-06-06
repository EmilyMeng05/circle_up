import 'package:flutter/material.dart';

/// A reusable text field component that follows a consistent design pattern.
/// This text field is styled with a light grey background, white borders,
/// and supports both regular and password input modes.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  /// The constructor for the customTextfield class
  /// Parameters: 
  /// - controller: manages the text field's content
  /// - hintText: specifies the placeholder text
  /// - obscureText: determines if the text should be hidden
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
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
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            fillColor: Colors.grey.shade200,
            filled: true,
            hintText: hintText,
          ),
        ),
      ),
    );
  }
}
