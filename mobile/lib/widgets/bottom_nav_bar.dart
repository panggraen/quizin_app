import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';

/// Navigasi bawah 5 tab: Home, Materi, Play (tengah), Progress, Profil.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.menu_book_rounded, 'Materi'),
    (Icons.sports_esports_rounded, 'Play'),
    (Icons.emoji_events_rounded, 'Progress'),
    (Icons.person_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelect(i),
                    child: i == 2 ? _playItem(i) : _item(context, i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int i) {
    final selected = index == i;
    final color = selected ? AppColors.primary : AppColors.muted;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(_items[i].$1, color: color),
        Text(_items[i].$2,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
      ],
    );
  }

  Widget _playItem(int i) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Icon(_items[i].$1, color: Colors.white, size: 22),
        ),
        Text(_items[i].$2,
            style: TextStyle(
                fontSize: 11,
                color: index == i ? AppColors.green : AppColors.muted,
                fontWeight: index == i ? FontWeight.w700 : FontWeight.w400)),
      ],
    );
  }
}
