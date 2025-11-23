import 'package:flutter/material.dart';
import 'package:notely/core/animations.dart';
import 'package:notely/core/styles.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final BoxShadow? shadow;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final bool isDisabled;
  final bool isLoading;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.shadow,
    this.animationDuration,
    this.animationCurve,
    this.isDisabled = false,
    this.isLoading = false,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration ?? AppAnimations.fastDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve ?? Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.reverse();
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: widget.isDisabled ? 0.5 : _opacityAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? colorScheme.primary,
                borderRadius: widget.borderRadius ?? AppStyles.mdRadius,
                boxShadow: widget.shadow != null ? [widget.shadow!] : AppStyles.lightShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
                  borderRadius: widget.borderRadius ?? AppStyles.mdRadius,
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.foregroundColor ?? colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : widget.child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FloatingActionButtonAnimated extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool isExtended;
  final String? label;
  final Duration? animationDuration;
  final bool isLoading;

  const FloatingActionButtonAnimated({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.isExtended = false,
    this.label,
    this.animationDuration,
    this.isLoading = false,
  });

  @override
  State<FloatingActionButtonAnimated> createState() => _FloatingActionButtonAnimatedState();
}

class _FloatingActionButtonAnimatedState extends State<FloatingActionButtonAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration ?? AppAnimations.mediumDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: widget.isLoading ? _rotationAnimation.value * 2 * 3.14159 : 0.0,
            child: FloatingActionButton.extended(
              onPressed: widget.isLoading ? null : widget.onPressed,
              backgroundColor: widget.backgroundColor ?? colorScheme.primary,
              foregroundColor: widget.foregroundColor ?? colorScheme.onPrimary,
              elevation: widget.elevation ?? 6,
              isExtended: widget.isExtended,
              label: widget.isExtended && widget.label != null
                  ? Text(widget.label!)
                  : null,
              icon: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.foregroundColor ?? colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : widget.child,
            ),
          ),
        );
      },
    );
  }
}

class IconButtonAnimated extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? iconSize;
  final String? tooltip;
  final Duration? animationDuration;
  final bool isLoading;

  const IconButtonAnimated({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.iconSize,
    this.tooltip,
    this.animationDuration,
    this.isLoading = false,
  });

  @override
  State<IconButtonAnimated> createState() => _IconButtonAnimatedState();
}

class _IconButtonAnimatedState extends State<IconButtonAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration ?? AppAnimations.fastDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown() {
    if (!widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp() {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: IconButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            icon: widget.isLoading
                ? SizedBox(
                    width: widget.iconSize ?? 24,
                    height: widget.iconSize ?? 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.color ?? colorScheme.onSurface,
                      ),
                    ),
                  )
                : Icon(
                    widget.icon,
                    size: widget.iconSize,
                    color: widget.color,
                  ),
            tooltip: widget.tooltip,
          ),
        );
      },
    );
  }
}

class ChipAnimated extends StatefulWidget {
  final Widget label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? checkmarkColor;
  final bool selected;
  final EdgeInsets? padding;
  final Duration? animationDuration;

  const ChipAnimated({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.selectedColor,
    this.checkmarkColor,
    this.selected = false,
    this.padding,
    this.animationDuration,
  });

  @override
  State<ChipAnimated> createState() => _ChipAnimatedState();
}

class _ChipAnimatedState extends State<ChipAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration ?? AppAnimations.fastDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    _colorAnimation = ColorTween(
      begin: widget.backgroundColor ?? colorScheme.surface,
      end: widget.selectedColor ?? colorScheme.primary.withOpacity(0.2),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.selected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ChipAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      if (widget.selected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FilterChip(
            label: widget.label,
            selected: widget.selected,
            onSelected: (selected) => widget.onPressed?.call(),
            backgroundColor: widget.backgroundColor ?? colorScheme.surface,
            selectedColor: widget.selectedColor ?? colorScheme.primary.withOpacity(0.2),
            checkmarkColor: widget.checkmarkColor ?? colorScheme.primary,
            padding: widget.padding,
          ),
        );
      },
    );
  }
}

class CardAnimated extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? shadowColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Duration? animationDuration;
  final Curve? animationCurve;

  const CardAnimated({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.color,
    this.shadowColor,
    this.elevation,
    this.borderRadius,
    this.margin,
    this.padding,
    this.animationDuration,
    this.animationCurve,
  });

  @override
  State<CardAnimated> createState() => _CardAnimatedState();
}

class _CardAnimatedState extends State<CardAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration ?? AppAnimations.fastDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve ?? Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 2.0,
      end: (widget.elevation ?? 2.0) + 4.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown() {
    _controller.forward();
  }

  void _handleTapUp() {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: widget.margin,
          child: Card(
            color: widget.color,
            elevation: _elevationAnimation.value,
            shadowColor: widget.shadowColor ?? colorScheme.shadow,
            shape: RoundedRectangleBorder(
              borderRadius: widget.borderRadius ?? AppStyles.lgRadius,
            ),
            child: InkWell(
              onTap: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onLongPress: widget.onLongPress,
              borderRadius: widget.borderRadius ?? AppStyles.lgRadius,
              child: Padding(
                padding: widget.padding ?? AppStyles.mdPadding,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
