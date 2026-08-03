import 'package:flutter/material.dart';
import 'scene_painter.dart';

/// Renders an animated story illustration driven by [animation].
///
/// When [MediaQuery.disableAnimations] is true the scene is rendered at t=1.0
/// (the fully-resolved frame) as required by § 3 of the Animation Standard.
///
/// Home cards should pass a fixed [Animation] with value 1.0 rather than a
/// live controller, so they always show the resolved frame (§ 1 static uses).
class AnimatedStoryScene extends StatelessWidget {
  const AnimatedStoryScene({
    super.key,
    required this.storyId,
    required this.sceneIndex,
    required this.animation,
  });

  final String storyId;
  final int sceneIndex;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = reduceMotion ? 1.0 : animation.value.clamp(0.0, 1.0);
        return CustomPaint(
          painter: sceneFor(storyId, sceneIndex, t),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

/// A resolved (t=1.0) snapshot of a scene — for home cards and static previews.
class StaticStoryScene extends StatelessWidget {
  const StaticStoryScene({super.key, required this.storyId, this.sceneIndex = 0});

  final String storyId;
  final int sceneIndex;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: sceneFor(storyId, sceneIndex, 1.0),
      child: const SizedBox.expand(),
    );
  }
}
