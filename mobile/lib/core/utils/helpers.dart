import 'package:flutter/material.dart';

void pushScreen(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

IconData categoryIcon(String name) {
  switch (name) {
    case 'IPA':
      return Icons.science;
    case 'Sejarah':
      return Icons.account_balance;
    case 'Matematika':
      return Icons.calculate;
    case 'Teknologi':
      return Icons.memory;
    default:
      return Icons.menu_book;
  }
}

const List<Color> categoryColors = [
  Color(0xFF1F5FD6),
  Color(0xFFF5B301),
  Color(0xFFE5484D),
  Color(0xFF2EBD6B),
];

Color categoryColor(int index) => categoryColors[index % categoryColors.length];
