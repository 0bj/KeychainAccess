//
//  TestHostApp.swift
//  TestHost
//
//  Licensed under the MIT License. See LICENSE for details.
//

import SwiftUI

/// Empty host app: keychain tests need an app process with the keychain sharing entitlement.
@main
struct TestHostApp: App {
    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
    }
}
