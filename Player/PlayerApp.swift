//
//  PlayerApp.swift
//  Player
//
//  Created by Alexander on 16.12.2023.
//

import ComposableArchitecture
import SwiftUI

@main
struct PlayerApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
    var body: some Scene {
        WindowGroup {
			AppView(store: Store(initialState: AppFeature.State()) {
				AppFeature()
			})
        }
    }
}
