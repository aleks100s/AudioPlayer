//
//  Log.swift
//  Player
//
//  Created by Alexander on 17.12.2023.
//

import OSLog

public enum Log {
	public static func debug(_ message: String) {
		Logger.default.debug("\(message)")
	}
	
	public static func error(_ error: String) {
		Logger.default.error("\(error)")
	}
}
