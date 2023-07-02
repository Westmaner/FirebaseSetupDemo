//
//  FirebaseSetupDemoApp.swift
//  FirebaseSetupDemo
//
//  Created by Tim Yoon on 7/2/23.
//

import SwiftUI

@main
struct FirebaseSetupDemoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
