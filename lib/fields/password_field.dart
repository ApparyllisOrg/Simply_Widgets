import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({Key? key, required this.controller, this.validator})
      : super(key: key);

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool bObscuring = true;

  IconData getSuffixIcon() {
    if (bObscuring) {
      return Icons.visibility;
    }

    return Icons.visibility_off;
  }

  String getSemanticLabel() {
    if (bObscuring) {
      return "Show passowrd";
    }

    return "Hide passowrd";
  }

  void toggleObscuring() {
    setState(() {
      bObscuring = !bObscuring;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: bObscuring,
      decoration: InputDecoration(
          suffixIcon: IconButton(
        padding: EdgeInsets.all(0),
        icon: Icon(
          getSuffixIcon(),
          size: 16,
          semanticLabel: getSemanticLabel(),
        ),
        onPressed: toggleObscuring,
      )),
    ).padding(all: 0);
  }
}
