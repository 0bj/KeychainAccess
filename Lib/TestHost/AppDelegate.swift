//
//  AppDelegate.swift
//  TestHost
//
//  Licensed under the MIT License. See LICENSE for details.
//

#if os(macOS)
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    func applicationDidFinishLaunching(_ notification: Notification) {}
}
#else
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
}
#endif
