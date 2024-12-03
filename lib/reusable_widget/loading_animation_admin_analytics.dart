import 'package:flutter/material.dart';
import 'package:mobileapplication/config/theme_config.dart';

class ModernLoadingAnimation extends StatefulWidget {
  const ModernLoadingAnimation({super.key});

  @override
  State<ModernLoadingAnimation> createState() => _ModernLoadingAnimationState();
}

class _ModernLoadingAnimationState extends State<ModernLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 200,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Shimmer effect container
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            ThemeConfig.lightDeepBlue.withOpacity(0.2),
                            ThemeConfig.lightDeepBlue,
                            ThemeConfig.lightDeepBlue.withOpacity(0.2),
                          ],
                          stops: [
                            0.0,
                            _progressAnimation.value,
                            1.0,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Loading text with fade animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Loading',
                            style: TextStyle(
                              color: ThemeConfig.lightDeepBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          _buildDots(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      children: List.generate(3, (index) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.3,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                index * 0.2,
                0.6 + index * 0.2,
                curve: Curves.easeInOut,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Text(
              '.',
              style: TextStyle(
                color: ThemeConfig.lightDeepBlue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}
