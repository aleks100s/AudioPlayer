//
//  AppDelegate.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import AVFoundation
import UIKit
import YandexMobileAds

final class AppDelegate: NSObject, UIApplicationDelegate {
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
	) -> Bool {
		configureAudioSession()
		MobileAds.initializeSDK()
		return true
	}
	
	private func configureAudioSession() {
		do {
			try AVAudioSession.sharedInstance().setCategory(.playback)
		} catch {
			print("Failed to set audio session category. Error: \(error)")
		}
	}
}
