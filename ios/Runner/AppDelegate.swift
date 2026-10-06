import Flutter
import Security
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    clearKeychainOnFreshInstall()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  /// Keychain items survive uninstall but UserDefaults don't, so a missing
  /// flag means a fresh install: drop leftover secrets (tokens, cached user)
  /// before Flutter starts. Android needs nothing: uninstall removes both.
  private func clearKeychainOnFreshInstall() {
    let key = "hasLaunchedBefore"
    let defaults = UserDefaults.standard
    guard !defaults.bool(forKey: key) else { return }

    let classes = [
      kSecClassGenericPassword,
      kSecClassInternetPassword,
      kSecClassCertificate,
      kSecClassKey,
      kSecClassIdentity,
    ]
    for secClass in classes {
      SecItemDelete([kSecClass as String: secClass] as CFDictionary)
    }
    defaults.set(true, forKey: key)
  }
}
