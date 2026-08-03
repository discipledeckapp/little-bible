import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/music_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final container = ProviderContainer();
  await container.read(musicServiceProvider).init();
  runApp(UncontrolledProviderScope(
    container: container,
    child: const LittleBibleApp(),
  ));
}
