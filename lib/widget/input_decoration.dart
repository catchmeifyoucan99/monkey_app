import 'package:flutter/material.dart';

InputDecoration customInputDecoration(String label, IconData icon, {Widget? suffixIcon}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: const Color(0xFF242D35)),
    filled: true,
    fillColor: const Color(0xFFF5F6F7),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFFDCDFE3),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFF37ABFF),
        width: 2,
      ),
    ),
    labelStyle: const TextStyle(color: Colors.grey),
    suffixIcon: suffixIcon,
  );
}
