import 'package:flutter/material.dart';
import 'dart:math' as math;

class BloodDonorSearchLoader extends StatefulWidget {
  final String bloodGroup;
  final Duration duration;
  final VoidCallback? onComplete;

  const BloodDonorSearchLoader({
    Key? key,
    required this.bloodGroup,
    this.duration = const Duration(seconds: 2),
    this.onComplete,
  }) : super(key: key);

  @override
  State<BloodDonorSearchLoader> createState() => _BloodDonorSearchLoaderState();
}

class _BloodDonorSearchLoaderState extends State<BloodDonorSearchLoader>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Rotation animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    // Progress animation
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _progressController.forward().then((_) {
      setState(() {
        _isComplete = true;
      });
      
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isComplete) ...[
            // Animated searching effect
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulsing circle
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 200 * _pulseAnimation.value,
                      height: 200 * _pulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
                      ),
                    );
                  },
                ),
                
                // Middle pulsing circle
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 150 * _pulseAnimation.value,
                      height: 150 * _pulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
                      ),
                    );
                  },
                ),
                
                // Inner circle with blood group
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade100,
                    border: Border.all(color: Colors.red, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      widget.bloodGroup,
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                
                // Rotating blood drops around the circle
                ...List.generate(8, (index) {
                  return AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      final angle = (_rotationController.value * 2 * math.pi) + (index * math.pi / 4);
                      final radius = 90.0;
                      final x = radius * math.cos(angle);
                      final y = radius * math.sin(angle);
                      
                      return Transform.translate(
                        offset: Offset(x, y),
                        child: Transform.rotate(
                          angle: angle + math.pi / 2,
                          child: Icon(
                            Icons.water_drop,
                            color: Colors.red.withOpacity(0.8),
                            size: 20,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Progress indicator
            SizedBox(
              width: 200,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.red,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Finding donors with ${widget.bloodGroup} blood group...",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ] else ...[
            // Completion state
            AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.shade100,
                          border: Border.all(color: Colors.green, width: 3),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Donors Found!",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Best matches for ${widget.bloodGroup} blood group",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}