//
//  Log.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
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

