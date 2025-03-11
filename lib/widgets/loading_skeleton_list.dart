import 'package:flutter/material.dart';

class LoadingSkeletonList extends StatefulWidget {
  final int itemCount;
  final double itemWidth;
  final double itemHeight;

  const LoadingSkeletonList({
    super.key,
    this.itemCount = 4, // Đã thay đổi itemCount thành 4
    this.itemWidth = 30,
    this.itemHeight = 10,
  });

  @override
  _LoadingSkeletonListState createState() => _LoadingSkeletonListState();
}

class _LoadingSkeletonListState extends State<LoadingSkeletonList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        double opacity = 1.0 - (index * 0.2);
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: opacity * _animation.value,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                width: widget.itemWidth,
                height: widget.itemHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
