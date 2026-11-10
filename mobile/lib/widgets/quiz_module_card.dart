import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/models/quiz_model.dart';

/// Lingkaran nomor modul dengan status: tersedia, terkunci, selesai.
class QuizModuleCard extends StatelessWidget {
  const QuizModuleCard({super.key, required this.module, required this.selected, required this.onTap});

  final QuizModuleModel module;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = module.isLocked;
    final fill = selected ? AppColors.navy : AppColors.surface(context);
    final textColor = selected
        ? Colors.white
        : (locked ? Colors.grey : AppColors.accent(context));
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fill,
                  shape: BoxShape.circle,
                  border: Border.all(color: locked ? Colors.grey : AppColors.navy, width: 1.5),
                ),
                child: Text('${module.moduleNumber}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor)),
              ),
              if (locked)
                const Positioned(right: -2, top: -2, child: Icon(Icons.lock, size: 16, color: AppColors.yellow)),
              if (module.isCompleted)
                const Positioned(
                    right: -2, top: -2, child: Icon(Icons.check_circle, size: 18, color: AppColors.green)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            module.isCompleted ? '${module.bestScore}%' : (locked ? 'Terkunci' : 'Tersedia'),
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
