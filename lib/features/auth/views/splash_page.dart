import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double>    _fadeAnim;
  late Animation<double>    _scaleAnim;
  late Animation<Offset>    _slideAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  Future<void> _startSequence() async {
    // Start animation
    await _animController.forward();
    // Then check auth state and navigate
    await Get.find<AuthController>().checkAuthState();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: _LogoIcon(),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: _AppName(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: FadeTransition(
        opacity: _fadeAnim,
        child: const Padding(
          padding: EdgeInsets.only(bottom: 32),
          child: Text(
            'v1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontFamily: AppTextStyles.fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}
class _LogoIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: _buildLogoContent(),
      ),
    );
  }

  Widget _buildLogoContent() {
    // ── Swap this out with your actual logo asset ──────────────────────────
    // If you have an asset:
    // return Image.asset('assets/images/logo.png', width: 70, height: 70);
    //
    // If you have an SVG:
    // return SvgPicture.asset('assets/icons/logo.svg', width: 70, height: 70);
    //
    // Placeholder until logo is ready:
    return const Icon(
      Icons.handyman_rounded,
      size: 56,
      color: AppColors.primary,
    );
  }
}

// ── App Name Widget ───────────────────────────────────────────────────────────
class _AppName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bengali + English stacked
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'কাজ আছে',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'kajache.com',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}