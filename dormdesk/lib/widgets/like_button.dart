import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final int initialLikes;
  final Function(int)? onLikeChanged;
  final bool showCount;

  const LikeButton({
    this.initialLikes = 0,
    this.onLikeChanged,
    this.showCount = true,
    super.key,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> with TickerProviderStateMixin {
  late bool _isLiked;
  late int _likeCount;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likeCount = widget.initialLikes;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      } else {
        _likeCount--;
      }
    });

    widget.onLikeChanged?.call(_likeCount);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.grey,
                  size: 24,
                ),
                onPressed: _toggleLike,
                tooltip: _isLiked ? 'Unlike' : 'Like',
              ),
            );
          },
        ),
        if (widget.showCount)
          Text(
            '$_likeCount',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _isLiked ? Colors.red : Colors.grey,
              fontWeight: _isLiked ? FontWeight.bold : FontWeight.normal,
            ),
          ),
      ],
    );
  }
}
