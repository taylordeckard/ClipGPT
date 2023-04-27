//
//  ClipGPTApp.swift
//  ClipGPT
//
//  Created by tadeckar on 4/24/23.
//

import SwiftUI


@main
struct ClipGPTApp: App {
    @StateObject private var appState = AppState()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        MenuBarExtra("ClipGPT", systemImage: appState.loading ? "paperclip.badge.ellipsis" : "paperclip") {}
    }
}
