import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:notely/core/animations.dart';
import 'package:notely/core/styles.dart';
import 'package:notely/screens/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateToHome();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: AppAnimations.extraSlowDuration,
      vsync: this,
    );

    _textController = AnimationController(
      duration: AppAnimations.slowDuration,
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _logoController.forward();
    _textController.forward();
  }

  void _navigateToHome() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          AppAnimations.fadeRoute(
            child: const HomeScreen(),
            duration: AppAnimations.mediumDuration,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoScale.value,
                  child: Opacity(
                    opacity: _logoOpacity.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.note_alt_rounded,
                        size: 60,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                );
              },
            ).animate().scale(
              duration: 600.ms,
              curve: Curves.elasticOut,
            ).fadeIn(
              duration: 400.ms,
            ),

            const SizedBox(height: AppStyles.lg),

            // App Name
            AnimatedBuilder(
              animation: _textSlide,
              builder: (context, child) {
                return SlideTransition(
                  position: _textSlide,
                  child: Column(
                    children: [
                      Text(
                        'Aj Verse',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: AppStyles.sm),
                      Text(
                        'Your thoughts, beautifully organized',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ).animate().slideY(
              begin: 0.3,
              duration: 500.ms,
              delay: 300.ms,
              curve: Curves.easeOutCubic,
            ).fadeIn(
              duration: 400.ms,
              delay: 300.ms,
            ),

            const SizedBox(height: AppStyles.xxl),

            // Loading indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.primary.withOpacity(0.6),
                ),
              ),
            ).animate().fadeIn(
              duration: 400.ms,
              delay: 600.ms,
            ).scale(
              duration: 800.ms,
              delay: 600.ms,
              curve: Curves.easeInOut,
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom splash screen with more animations
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _particleAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _particleAnimations = AppAnimations.createStaggeredAnimations(
      _controller,
      8,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          // Background particles
          ...List.generate(8, (index) {
            final animation = _particleAnimations[index];
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Positioned(
                  top: 100 + (index * 80),
                  left: index % 2 == 0 ? 50 : 250,
                  child: Transform.scale(
                    scale: animation.value,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with hero animation
                Hero(
                  tag: AppAnimations.heroAppBar,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.note_alt_rounded,
                      size: 50,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ).animate().scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ).rotate(
                  duration: 800.ms,
                  curve: Curves.easeInOut,
                  begin: 0.1,
                  end: 0.0,
                ),

                const SizedBox(height: AppStyles.lg),

                // App name with letter-by-letter animation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: 'Aj Verse'.split('').map((letter) {
                    return Text(
                      letter,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ).animate().slideY(
                      begin: 0.5,
                      duration: 400.ms,
                      delay: Duration(milliseconds: 'Aj Verse'.indexOf(letter) * 100),
                      curve: Curves.easeOutCubic,
                    ).fadeIn(
                      duration: 300.ms,
                      delay: Duration(milliseconds: 'Aj Verse'.indexOf(letter) * 100),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppStyles.md),

                // Tagline
                Text(
                  'Your thoughts, beautifully organized',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(
                  duration: 500.ms,
                  delay: 800.ms,
                ).slideY(
                  begin: 0.2,
                  duration: 400.ms,
                  delay: 800.ms,
                ),
              ],
            ),
          ),

          // Bottom decoration
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(
            duration: 1000.ms,
            delay: 1000.ms,
          ),
        ],
      ),
    );
  }
}
