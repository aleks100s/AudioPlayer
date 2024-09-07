//
//  URL+Extensions.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import Foundation

extension URL {
	var isAudioFile: Bool {
		isFileURL && audioExtensions.contains(where: { $0 == pathExtension })
	}
	
	private var audioExtensions: [String] {
		["mp3", "wav", "m4a"]
	}
}

