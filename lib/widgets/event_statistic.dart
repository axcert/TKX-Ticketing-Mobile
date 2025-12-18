import 'package:flutter/material.dart';

class EventStatisticWidget extends StatefulWidget {
  final int registerCount;
  final int checkInCount;
  final int remainingCount;

  const EventStatisticWidget({
    super.key,
    required this.registerCount,
    required this.checkInCount,
    required this.remainingCount,
  });

  @override
  State<EventStatisticWidget> createState() => _EventStatisticWidgetState();
}

class _EventStatisticWidgetState extends State<EventStatisticWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<int> _percentageAnimation;

  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _updateAnimations();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(EventStatisticWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if values changed
    if (oldWidget.checkInCount != widget.checkInCount ||
        oldWidget.registerCount != widget.registerCount) {
      _updateAnimations();
      _animationController.forward(from: 0.0);
    }
  }

  void _updateAnimations() {
    final double currentProgress = widget.registerCount > 0
        ? widget.checkInCount / widget.registerCount
        : 0.0;

    final int currentPercentage = widget.registerCount > 0
        ? ((widget.checkInCount / widget.registerCount) * 100).toInt()
        : 0;

    final int previousPercentage = widget.registerCount > 0
        ? ((_previousProgress) * 100).toInt()
        : 0;

    _progressAnimation =
        Tween<double>(begin: _previousProgress, end: currentProgress).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _percentageAnimation =
        IntTween(begin: previousPercentage, end: currentPercentage).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _previousProgress = currentProgress;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Progress Circle (Left side) - Now Animated!
          SizedBox(
            width: 80,
            height: 80,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: _progressAnimation.value,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                      ),
                    ),
                    Text(
                      '${_percentageAnimation.value}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 24),

          // Stats Grid
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First Row: Registered and Checked-In
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Registered
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.registerCount}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Registered',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Checked-In
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.checkInCount}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Checked-In',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Second Row: Remaining and Empty/Spacer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Remaining
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.remainingCount}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Remaining',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Spacer for alignment
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
