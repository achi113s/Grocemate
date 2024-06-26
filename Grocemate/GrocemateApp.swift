//
//  GrocemateApp.swift
//  Grocemate
//
//  Created by Giorgio Latour on 11/5/23.
//

import Firebase
import FirebaseAppCheck
import FirebaseFunctions
import SwiftUI

@main
struct GrocemateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, CoreDataController.shared.viewContext)
                .preferredColorScheme(.light)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
#if targetEnvironment(simulator)
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
#endif

            FirebaseApp.configure()

#if targetEnvironment(simulator)
            Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)
            Functions.functions().useEmulator(withHost: "127.0.0.1", port: 5001)
#endif

            return true
        }
}
