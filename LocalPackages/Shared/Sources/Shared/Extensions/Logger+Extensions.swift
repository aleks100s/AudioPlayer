//
//  Logger+Categories.swift
//  Player
//
//  Created by Alexander on 17.12.2023.
//

import OSLog

extension Logger {
	static let viewCycle = Logger(subsystem: subsystem, category: "viewCycle")
	static let `default` = Logger(subsystem: subsystem, category: "default")
	
	private static let subsystem = Bundle.main.bundleIdentifier!
}
