import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.title, this.showBack = true, this.actions = const []});

  final String title;
  final bool showBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          if (showBack) ...[
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF0B1F5B)),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
