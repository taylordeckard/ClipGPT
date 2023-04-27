//
//  AppState.swift
//  ClipGPT
//
//  Created by tadeckar on 4/27/23.
//

import Foundation

class AppState: ObservableObject {
    @Published var loading: Bool

    init() {
        self.loading = false
    }
}
