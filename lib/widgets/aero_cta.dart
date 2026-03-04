import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AeroCTA extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDestructive;
  final Widget? icon;

  const AeroCTA({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
    this.icon,
  });

  @override
  State<AeroCTA> createState() => _AeroCTAState();
}

class _AeroCTAState extends State<AeroCTA> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final gradient = widget.isDestructive
        ? AppColors.gradientCoral
        : AppColors.gradientHero;

    return GestureDetector(
      onTapDown: widget.isLoading ? null : _onTapDown,
      onTapUp: widget.isLoading ? null : _onTapUp,
      onTapCancel: widget.isLoading ? null : _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(999), // radius-pill
            boxShadow: [
              // elevation-2 or none if loading
              if (!widget.isLoading)
                BoxShadow(
                  color: const Color(0xFF161A22).withAlpha(26),
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        widget.icon!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
