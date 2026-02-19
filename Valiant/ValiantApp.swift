//
//  ValiantApp.swift
//  Valiant
//
//  Created by Kalyan Thakur on 30/01/26.
//

import SwiftUI

@main
struct ValiantApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
