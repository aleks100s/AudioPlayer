//
//  Logger+Extensions.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import OSLog

extension Logger {
	static let viewCycle = Logger(subsystem: subsystem, category: "viewCycle")
	static let `default` = Logger(subsystem: subsystem, category: "default")
	
	private static let subsystem = Bundle.main.bundleIdentifier!
}
