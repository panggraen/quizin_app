import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/models/progress_model.dart';
import 'package:quizin_app/models/user_model.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/widgets/async_view.dart';
import 'package:quizin_app/widgets/tab_page.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<ProgressModel> _future;

  static const Color _line = Color(0xFFD6E2F7);
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = context.read<ProfileProvider>().progress();

  String _date(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final u = context.watch<ProfileProvider>().user;
    return TabPage(
      title: 'Progress Belajar',
      child: AsyncView<ProgressModel>(
        future: _future,
        onRetry: () => setState(_load),
        builder: (context, p) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            if (u != null) ...[
              _LevelCard(user: u),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _StatCard(
                          icon: Icons.menu_book_rounded,
                          value: u.materialsCompleted,
                          label: 'Materi Selesai')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _StatCard(
                          icon: Icons.sports_esports_rounded,
                          value: u.modulesCompleted,
                          label: 'Kuis Selesai')),
                ],
              ),
              const SizedBox(height: 20),
            ],
            _sectionTitle(context, 'Riwayat Belajar'),
            const SizedBox(height: 8),
            if (p.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Belum ada riwayat. Selesaikan materi atau kuis pertamamu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.muted)),
              ),
            for (final it in p.items) _historyTile(context, it),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Text(text,
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.accent(context)));

  static const List<BoxShadow> _shadow = [
    BoxShadow(color: Color(0x141F5FD6), blurRadius: 10, offset: Offset(0, 3)),
  ];

  /// Backend mengirim path dengan tanda "-" (mis. "IPA-Biologi-Sel"). Ambil
  /// tiga bagian pertama; sisanya (judul yang memuat "-") digabung kembali.
  List<String> _splitPath(String s) {
    final parts = s.split('-').map((e) => e.trim()).toList();
    if (parts.length <= 3) return parts;
    return [parts[0], parts[1], parts.sublist(2).join('-')];
  }

  /// Rapikan item riwayat jadi: judul, subtitle "IPA \u2022 Biologi", dan skor "5/5".
  ({String title, String subtitle, String? score}) _display(ProgressItemModel it) {
    final isQuiz = it.type == 'quiz';

    if (!isQuiz) {
      final parts = _splitPath(it.subtitle);
      if (parts.length >= 3) {
        return (title: parts[2], subtitle: '${parts[0]} \u2022 ${parts[1]}', score: null);
      }
      return (title: it.title, subtitle: it.subtitle.replaceAll(' \u00b7 ', ' \u2022 '), score: null);
    }

    // Skor kuis dikirim backend di akhir subtitle, mis. "... \u00b7 80%".
    // Satu kuis = 5 soal (1 soal = 20%), jadi ditampilkan sebagai "4/5".
    var sub = it.subtitle;
    String? score;
    final m = RegExp(r'\s*[\u00b7\u2022]\s*(\d{1,3})%\s*$').firstMatch(sub);
    if (m != null) {
      final pct = int.tryParse(m.group(1)!) ?? 0;
      score = '${(pct / 20).round().clamp(0, 5)}/5';
      sub = sub.substring(0, m.start);
    }
    final segs = sub.split(RegExp(r'\s*[\u00b7\u2022]\s*'));
    final path = _splitPath(segs.first);
    final module = segs.length > 1 ? segs[1].trim() : null;
    return (
      title: 'Kuis: ${module ?? (path.isNotEmpty ? path.last : it.title)}',
      subtitle: path.join(' \u2022 '),
      score: score,
    );
  }

  Widget _historyTile(BuildContext context, ProgressItemModel it) {
    final isQuiz = it.type == 'quiz';
    final d = _display(it);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
        boxShadow: _shadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isQuiz ? const Color(0xFFEDE4FF) : const Color(0xFFE3EEFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(isQuiz ? Icons.sports_esports_rounded : Icons.menu_book_rounded,
                size: 22, color: isQuiz ? const Color(0xFF7B4DE0) : AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text(context))),
                Text(d.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              d.score != null
                  ? _pill(Icons.star_rounded, d.score!, const Color(0xFFFFF0C2), const Color(0xFFB07A00))
                  : _pill(Icons.check_rounded, 'Selesai', const Color(0xFFDDF6E6), const Color(0xFF1E8E4E)),
              if (it.createdAt != null) ...[
                const SizedBox(height: 4),
                Text(_date(it.createdAt!),
                    style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ],
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.accent(context)),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 3),
            Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
          ],
        ),
      );
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final xp = user.xpInLevel;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.headerTop, AppColors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Level ${user.level}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('$xp / 100 XP',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (xp / 100).clamp(0.0, 1.0).toDouble(),
                    minHeight: 12,
                    backgroundColor: const Color(0x55BFE6FF),
                    color: const Color(0xFFBFE6FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${100 - xp} XP lagi menuju Level ${user.level + 1}',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.value, required this.label});

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6E2F7)),
        boxShadow: const [
          BoxShadow(color: Color(0x141F5FD6), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE3EEFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 26, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$value',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accent(context))),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}