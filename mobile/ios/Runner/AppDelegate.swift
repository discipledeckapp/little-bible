import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register the BGTaskScheduler handler for our background content sync
    // BEFORE anything can submit that task.
    //
    // iOS requires a launch handler to exist for every identifier listed in
    // Info.plist's BGTaskSchedulerPermittedIdentifiers. main.dart calls
    // Workmanager().registerPeriodicTask('org.littlebible.sync', …) on every
    // launch, and without this line iOS threw on startup and killed the app
    // before the first frame:
    //
    //   NSInternalInconsistencyException — No launch handler registered for
    //   task with identifier org.littlebible.sync
    //
    // The identifier must match Info.plist and main.dart exactly. It has to be
    // registered here, in didFinishLaunchingWithOptions, because iOS only
    // accepts handler registration during app launch.
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "org.littlebible.sync",
      frequency: NSNumber(value: 12 * 60 * 60)
    )

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
