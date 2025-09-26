//
//  PlaybackRate.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

enum PlaybackRate: Double, CaseIterable, RawRepresentable {
    case x050 = 0.5
    case x075 = 0.75
	case x100 = 1.0
	case x125 = 1.25
	case x150 = 1.5
	case x175 = 1.75
	case x200 = 2.0
	
	var title: String {
        let speed = switch self {
        case .x050: "0.5x"

        case .x075: "0.75x"

        case .x100: "1x"
            
        case .x125: "1.25x"
            
        case .x150: "1.5x"
            
        case .x175: "1.75x"
            
        case .x200: "2x"
        }
        return String(localized: "Скорость \(speed)")
	}
	
	var float: Float {
		Float(rawValue)
	}
}
