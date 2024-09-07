//
//  PlaybackRate.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

enum PlaybackRate: Float, CaseIterable {
	case x100 = 1.0
	case x125 = 1.25
	case x150 = 1.5
	case x175 = 1.75
	case x200 = 2.0
	
	var title: String {
		switch self {
		case .x100: "1x"
			
		case .x125: "1.25x"
			
		case .x150: "1.5x"
			
		case .x175: "1.75x"
			
		case .x200: "2x"
		}
	}
}

extension PlaybackRate {
	static func nextRate(after rate: PlaybackRate) -> PlaybackRate {
		let allRates = PlaybackRate.allCases
		guard let index = allRates.firstIndex(of: rate) else {
			return .x100
		}
		
		if index == allRates.count - 1 {
			return .x100
		} else {
			return allRates[index + 1]
		}
	}
}

