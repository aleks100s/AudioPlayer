//
//  Double+Extensions.swift
//  AudioPlayer
//
//  Created by Alexander on 08.09.2024.
//

extension Double {
	var timeString: String {
		let time = Int(self)
		let minutes = String(format: "%02d", time / 60)
		let seconds = String(format: "%02d", time % 60)
		return "\(minutes):\(seconds)"
	}
}
