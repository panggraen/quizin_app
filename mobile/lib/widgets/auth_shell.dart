import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/responsive.dart';
import 'package:quizin_app/widgets/cloud_mascot.dart';

class AuthLayout {
  const AuthLayout({
    required this.isWide,
    required this.isShort,
    required this.logoSize,
  });

  final bool isWide;
  final bool isShort;
  final double logoSize;
}

/// Kerangka Login & Register.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.builder,
    this.maxWidth = 460,
  });

  final Widget Function(BuildContext context, AuthLayout layout) builder;
  final double maxWidth;

  static const double _shortHeight = 520;

  /// Slogan di layar login/daftar. Ubah teks di sini saja.
  static const String tagline = 'Belajar lewat kuis,\nraih nilai terbaikmu!';

  /// Biru tua -> biru -> cyan, mengikuti gaya referensi.
  static const LinearGradient _bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1240B8), AppColors.primary, Color(0xFF27C6E8)],
    stops: [0.0, 0.55, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final screenH = screen.height;
    final isShort = screenH < _shortHeight;
    final isWide = !isShort && screen.width >= Breakpoints.authSplit;
    final layout = AuthLayout(
      isWide: isWide,
      isShort: isShort,
      logoSize: isShort ? 52 : 64,
    );

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: LayoutBuilder(
        builder: (context, c) {
          if (isShort) return _plain(context, layout);
          if (isWide) return _split(context, layout);
          return _stacked(context, c, layout, screenH);
        },
      ),
    );
  }

  /// Layar sangat pendek (HP landscape): tanpa maskot, hanya form.
  Widget _plain(BuildContext context, AuthLayout layout) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, vc) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.max(0.0, vc.maxHeight - 48),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: builder(context, layout),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Web / desktop: latar gradien penuh layar. Di kiri ada slogan + Nimbi besar
  /// dengan hiasan melayang, di kanan kartu putih melayang berisi form.
  /// Kartu bisa di-scroll di layar yang pendek.
  Widget _split(BuildContext context, AuthLayout layout) {
    final cardColor = Theme.of(context).scaffoldBackgroundColor;

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: _bgGradient)),
        const CustomPaint(painter: _WavePainter()),
        SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(flex: 6, child: _BrandPanel()),
              Expanded(
                flex: 5,
                child: LayoutBuilder(
                  builder: (context, vc) => SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(8, 32, 48, 32),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(0.0, vc.maxHeight - 64),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth + 72),
                          child: Container(
                            padding: const EdgeInsets.all(36),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000F4D),
                                  blurRadius: 40,
                                  offset: Offset(0, 16),
                                ),
                              ],
                            ),
                            child: builder(context, layout),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// HP / tablet portrait: tanpa maskot. Latar gradien penuh layar, slogan di
  /// atas, lalu kartu putih berisi form.
  Widget _stacked(
    BuildContext context,
    BoxConstraints c,
    AuthLayout layout,
    double screenH,
  ) {
    final pad = MediaQuery.paddingOf(context);
    final cardColor = Theme.of(context).scaffoldBackgroundColor;

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: _bgGradient)),
        const CustomPaint(painter: _WavePainter()),
        SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            20,
            pad.top + 28,
            20,
            pad.bottom + 28,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(0.0, c.maxHeight - pad.top - pad.bottom - 56),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth + 56),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      tagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000F4D),
                            blurRadius: 32,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: builder(context, layout),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Panel kiri di layar lebar: slogan + Nimbi besar + hiasan melayang.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Lebar Nimbi mengikuti panel, tapi dibatasi tinggi layar supaya
        // slogan + Nimbi selalu muat.
        final byWidth = c.maxWidth * 0.62;
        final byHeight = (c.maxHeight * 0.42) * CloudMascot.aspect;
        final mascotW = math.min(byWidth, byHeight).clamp(220.0, 520.0).toDouble();
        final size = mascotW / CloudMascot.widthFactor;
        final mascotH = mascotW / CloudMascot.aspect;
        final stageW = mascotW * 1.45;
        final stageH = mascotH * 1.6;
        final titleSize = (c.maxWidth / 17).clamp(24.0, 40.0).toDouble();

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AuthShell.tagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: stageW,
                  height: stageH,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // cahaya lembut di belakang Nimbi
                      Container(
                        width: mascotW * 1.1,
                        height: mascotW * 1.1,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [Color(0x66FFFFFF), Color(0x00FFFFFF)],
                          ),
                        ),
                      ),
                      _Floaty(
                        amplitude: 8,
                        duration: const Duration(milliseconds: 2600),
                        child: CloudMascot(size: size),
                      ),
                      const Align(
                        alignment: Alignment(-0.95, -0.55),
                        child: _Floaty(
                          amplitude: 10,
                          duration: Duration(milliseconds: 2200),
                          child: _Coin(size: 46),
                        ),
                      ),
                      const Align(
                        alignment: Alignment(0.95, -0.7),
                        child: _Floaty(
                          amplitude: 12,
                          duration: Duration(milliseconds: 2900),
                          child: _XpBadge(),
                        ),
                      ),
                      const Align(
                        alignment: Alignment(-0.85, 0.7),
                        child: _Floaty(
                          amplitude: 9,
                          duration: Duration(milliseconds: 3100),
                          child: _IconBubble(Icons.menu_book_rounded),
                        ),
                      ),
                      const Align(
                        alignment: Alignment(0.9, 0.65),
                        child: _Floaty(
                          amplitude: 11,
                          duration: Duration(milliseconds: 2400),
                          child: _Coin(size: 36),
                        ),
                      ),
                      const Align(
                        alignment: Alignment(0.3, -1.0),
                        child: _Floaty(
                          amplitude: 7,
                          duration: Duration(milliseconds: 2000),
                          child: Icon(Icons.auto_awesome,
                              color: Colors.white, size: 28),
                        ),
                      ),
                      const Align(
                        alignment: Alignment(-0.4, 1.0),
                        child: _Floaty(
                          amplitude: 7,
                          duration: Duration(milliseconds: 2700),
                          child: Icon(Icons.star_rounded,
                              color: AppColors.yellow, size: 30),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Gerak naik-turun pelan untuk hiasan.
class _Floaty extends StatefulWidget {
  const _Floaty({
    required this.child,
    required this.duration,
    this.amplitude = 10,
  });

  final Widget child;
  final Duration duration;
  final double amplitude;

  @override
  State<_Floaty> createState() => _FloatyState();
}

class _FloatyState extends State<_Floaty> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration)
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
    return AnimatedBuilder(
      animation: curve,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, (curve.value * 2 - 1) * widget.amplitude),
        child: child,
      ),
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Icon(
        Icons.monetization_on,
        color: AppColors.yellow,
        size: size,
        shadows: const [Shadow(color: Color(0x40000000), blurRadius: 10)],
      );
}

class _IconBubble extends StatelessWidget {
  const _IconBubble(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x55FFFFFF)),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      );
}

class _XpBadge extends StatelessWidget {
  const _XpBadge();

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: -0.12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Color(0x40000000), blurRadius: 10),
            ],
          ),
          child: const Text(
            '+50 XP',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
      );
}

/// Bentuk gelombang halus di pojok kanan atas dan kiri bawah.
class _WavePainter extends CustomPainter {
  const _WavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    final top = Path()
      ..moveTo(w * 0.55, 0)
      ..cubicTo(w * 0.68, h * 0.14, w * 0.84, h * 0.0, w, h * 0.2)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(top, Paint()..color = const Color(0x14FFFFFF));

    final bottom = Path()
      ..moveTo(0, h * 0.78)
      ..cubicTo(w * 0.18, h * 0.68, w * 0.34, h * 0.96, w * 0.55, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(bottom, Paint()..color = const Color(0x1AFFFFFF));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}