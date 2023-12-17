//
//  MockError.swift
//  
//
//  Created by Alexander on 17.12.2023.
//

import Foundation

public enum MockError: LocalizedError {
	case unknown(String)
	
	public var errorDescription: String? {
		switch self {
		case let .unknown(message):
			return message
		}
	}
}
