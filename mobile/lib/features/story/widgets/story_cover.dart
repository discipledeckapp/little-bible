import 'package:flutter/material.dart';
import 'animated_story_scene.dart';

/// Card-size story cover illustration for home-screen tiles.
///
/// Renders scene 0 at t=1.0 (the fully-resolved frame per § 1 of the
/// Animation Standard). The design-box fit in ScenePainter handles all
/// aspect ratios correctly — no live-canvas fractions here.
class StoryCover extends StatelessWidget {
  const StoryCover({super.key, required this.storyId, required this.size});

  final String storyId;
  final double size; // kept for API compatibility; layout handled by parent

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: StaticStoryScene(storyId: storyId),
    );
  }
}
