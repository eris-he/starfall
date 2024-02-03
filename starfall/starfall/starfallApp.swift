//
//  starfallApp.swift
//  starfall
//
//  Created by Eris He on 2/3/24.
//

import SwiftUI

@main
struct starfallApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
