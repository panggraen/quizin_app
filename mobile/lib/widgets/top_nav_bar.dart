import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/responsive.dart';
import 'package:quizin_app/widgets/app_logo.dart';
import 'package:quizin_app/widgets/bottom_nav_bar.dart';

/// Navigasi atas horizontal untuk layar lebar (web / desktop / tablet landscape).
/// Lebarnya dibatasi [Breakpoints.contentMax], sama dengan konten halaman,
/// sehingga logo dan konten rata di tepi yang sama.
class AppTopNav extends StatelessWidget {
  const AppTopNav({super.key, required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: Breakpoints.contentMax),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.screenPadding,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const AppLogo(size: 36),
                    const SizedBox(width: 10),
                    Text(
                      'QUIZIN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent(context),
                      ),
                    ),
                    const Spacer(),
                    for (var i = 0; i < appNavItems.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      _tab(i),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(int i) {
    final selected = index == i;
    final isPlay = i == 2;
    final item = appNavItems[i];

    final Color bg = isPlay
        ? AppColors.green
        : (selected
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent);
    final Color fg = isPlay
        ? Colors.white
        : (selected ? AppColors.primary : AppColors.muted);

    final radius = BorderRadius.circular(999);

    return Semantics(
      selected: selected,
      child: Material(
        color: bg,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: () => onSelect(i),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.$1, size: 20, color: fg),
                const SizedBox(width: 6),
                Text(
                  item.$2,
                  style: TextStyle(
                    color: fg,
                    fontWeight:
                        selected || isPlay ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
