import 'package:flutter/material.dart';

BoxDecoration softShadow({bool reversed = false}) {
  return BoxDecoration(
    color: const Color(0xFFE9EEF5),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: reversed ? Colors.white : Colors.grey.shade400,
        offset: reversed ? const Offset(-4, -4) : const Offset(4, 4),
        blurRadius: 10,
      ),
      BoxShadow(
        color: reversed ? Colors.grey.shade400 : Colors.white,
        offset: reversed ? const Offset(4, 4) : const Offset(-4, -4),
        blurRadius: 10,
      ),
    ],
  );
}
