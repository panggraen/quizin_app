import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/models/quiz_model.dart';

/// Jalur modul vertikal berkelok: modul 1 di bawah, naik ke atas.
/// Latar langit dengan awan. Node: biru = tersedia/selesai (bintang 0-5),
/// abu-abu + gembok = terkunci. [modules] harus sudah urut naik.
class ModuleMap extends StatelessWidget {
  const ModuleMap({super.key, required this.modules, required this.onSelect});

  final List<QuizModuleModel> modules;
  final ValueChanged<QuizModuleModel> onSelect;

  static const double step = 104; // jarak vertikal antar node
  static const double topPad = 40;
  static const double bottomPad = 56;
  static const List<double> _xs = [.52, .40, .56, .38, .54];

  static double heightFor(int n) => topPad + (n - 1) * step + bottomPad;

  /// Titik tengah node ke-[i] (0 = modul 1, paling bawah).
  static double centerY(int i, int n) => heightFor(n) - bottomPad - i * step;

  static const List<Offset> _clouds = [
    Offset(.17, .10), Offset(.86, .22), Offset(.14, .36),
    Offset(.88, .52), Offset(.16, .68), Offset(.85, .84),
  ];

  @override
  Widget build(BuildContext context) {
    final n = modules.length;
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final h = heightFor(n);
      final d = (w * 0.155).clamp(52.0, 68.0).toDouble();
      final points = [for (var i = 0; i < n; i++) Offset(_xs[i % _xs.length] * w, centerY(i, n))];
      final currentIdx = modules.indexWhere((m) => !m.isLocked && !m.isCompleted);
      return SizedBox(
        height: h,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _BackdropPainter(points, _clouds, d)),
            ),
            for (var i = 0; i < n; i++)
              Positioned(
                left: points[i].dx - (d + 40) / 2,
                top: points[i].dy - (d + 40) / 2,
                width: d + 40,
                height: d + 40,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(modules[i]),
                  child: Center(child: _Node(module: modules[i], size: d, current: i == currentIdx)),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.module, required this.size, required this.current});

  final QuizModuleModel module;
  final double size;
  final bool current;

  /// Kuis berisi 5 soal, tiap soal = 20% -> 1 bintang per jawaban benar (0..5).
  int get _stars {
    final s = module.bestScore ?? 0;
    return (s / 20).round().clamp(0, 5).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final locked = module.isLocked;
    final done = module.isCompleted;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: locked
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFE6EAF2), Color(0xFFB2BBCC)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF3FA0FF), Color(0xFF0A62E8)],
                    ),
              border: Border.all(color: locked ? const Color(0xFFCDD4E0) : Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: locked ? const Color(0xFF8E9AB2) : const Color(0x661F7BEF),
                  blurRadius: locked ? 0 : 14,
                  offset: Offset(0, locked ? 6 : 5),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '${module.moduleNumber}',
              style: TextStyle(
                fontSize: size * 0.46,
                fontWeight: FontWeight.w800,
                height: 1,
                color: locked ? const Color(0xFF4A5675) : Colors.white,
              ),
            ),
          ),
          // kilap
          Positioned(
            left: size * 0.18,
            top: size * 0.10,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: size * 0.30,
                height: size * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(locked ? 0.7 : 0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          if (locked)
            Positioned(
              right: -size * 0.12,
              top: -size * 0.14,
              child: Container(
                padding: EdgeInsets.all(size * 0.05),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFD84D), Color(0xFFF5A800)],
                  ),
                  borderRadius: BorderRadius.circular(size * 0.12),
                  boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Icon(Icons.lock_rounded, size: size * 0.24, color: const Color(0xFF6B4300)),
              ),
            ),
          if (current)
            Positioned(
              right: -size * 0.30,
              top: -size * 0.22,
              child: CustomPaint(size: Size(size * 0.36, size * 0.36), painter: _SparklePainter()),
            ),
          if (done)
            Positioned(
              bottom: -size * 0.16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: size * 0.07, vertical: size * 0.03),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Color(0x261F5FD6), blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < 5; i++)
                      Icon(Icons.star_rounded,
                          size: size * 0.17,
                          color: i < _stars ? AppColors.yellow : const Color(0xFFD5DBE6)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.yellow
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final origin = Offset(0, size.height);
    for (final deg in const [-80.0, -45.0, -10.0]) {
      final a = deg * math.pi / 180;
      canvas.drawLine(
        origin + Offset(math.cos(a), math.sin(a)) * (size.width * 0.55),
        origin + Offset(math.cos(a), math.sin(a)) * (size.width * 1.0),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.points, this.clouds, this.nodeSize);
  final List<Offset> points;
  final List<Offset> clouds;
  final double nodeSize;

  @override
  void paint(Canvas canvas, Size size) {
    const cloudColor = Color(0xFFD6E6FB);
    final cp = Paint()..color = cloudColor;
    final s = size.width * 0.11;
    for (final c in clouds) {
      final o = Offset(c.dx * size.width, c.dy * size.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: o, width: s * 2.0, height: s * 0.85), Radius.circular(s * 0.42)),
        cp,
      );
      canvas.drawCircle(o + Offset(-s * 0.35, -s * 0.32), s * 0.42, cp);
      canvas.drawCircle(o + Offset(s * 0.20, -s * 0.42), s * 0.55, cp);
    }

    // Jalur penghubung antar node
    final pathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = nodeSize * 0.30
      ..color = const Color(0xFFBCD8FB);
    final path = Path();
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i], b = points[i + 1];
      final midY = (a.dy + b.dy) / 2;
      path
        ..moveTo(a.dx, a.dy)
        ..cubicTo(a.dx, midY, b.dx, midY, b.dx, b.dy);
    }
    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter old) => true;
}