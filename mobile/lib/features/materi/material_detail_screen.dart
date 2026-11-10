import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/features/materi/material_done_screen.dart';
import 'package:quizin_app/features/quiz/module_list_screen.dart';
import 'package:quizin_app/models/material_model.dart';
import 'package:quizin_app/models/subject_model.dart';
import 'package:quizin_app/providers/material_provider.dart';
import 'package:quizin_app/providers/profile_provider.dart';
import 'package:quizin_app/widgets/async_view.dart';
import 'package:quizin_app/widgets/primary_button.dart';
import 'package:quizin_app/widgets/screen_scaffold.dart';
import 'package:quizin_app/widgets/secondary_button.dart';

class _DetailData {
  _DetailData(this.material, this.allDone);
  final MaterialModel material;
  final bool allDone; // semua materi di bidang ini sudah selesai
}

class MaterialDetailScreen extends StatefulWidget {
  const MaterialDetailScreen({super.key, required this.materialId, required this.subject});

  final int materialId;
  final SubjectModel subject;

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  late Future<_DetailData> _future;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final provider = context.read<MaterialProvider>();
    _future = () async {
      final material = await provider.material(widget.materialId);
      final all = await provider.materials(widget.subject.id);
      return _DetailData(material, all.every((m) => m.isCompleted));
    }();
  }

  Future<void> _complete(MaterialModel m) async {
    setState(() => _saving = true);
    try {
      final r = await context.read<MaterialProvider>().complete(m.id);
      if (!mounted) return;
      context.read<ProfileProvider>().load();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MaterialDoneScreen(xpAwarded: r.xpAwarded)),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, 'Gagal menyimpan. Coba lagi.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: widget.subject.name,
      child: AsyncView<_DetailData>(
        future: _future,
        onRetry: () => setState(_load),
        builder: (context, d) {
          final m = d.material;
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Container(
                height: 170,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F1FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                // PLACEHOLDER: ganti dengan gambar materi dari server (Laravel Storage).
                child: const Icon(Icons.landscape, size: 80, color: AppColors.primary),
              ),
              const SizedBox(height: 14),
              Text('Pengertian ${m.title}',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text(context))),
              const SizedBox(height: 6),
              Text(m.content, style: TextStyle(height: 1.4, color: AppColors.text(context))),
              const SizedBox(height: 20),
              if (!d.allDone) ...[
                Text('Peringatan',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
                Text('Selesaikan semua materi di bidang ini dulu sebelum melakukan uji pemahaman (Kuis).',
                    style: TextStyle(fontSize: 12, color: AppColors.text(context))),
                const SizedBox(height: 8),
              ],
              SecondaryButton(
                label: 'Uji Pemahaman',
                onPressed: d.allDone ? () => pushScreen(context, ModuleListScreen(material: m)) : null,
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: m.isCompleted ? 'Sudah Selesai' : 'Tandai Selesai',
                loading: _saving,
                onPressed: m.isCompleted ? null : () => _complete(m),
              ),
            ],
          );
        },
      ),
    );
  }
}
