//
//  TimerMode.swift
//  AudioPlayer
//
//  Created by Alexander on 26.09.2025.
//

enum TimerMode {
    enum Minutes: Int, CaseIterable {
        case five = 5
        case ten = 10
        case fifteen = 15
        case twenty = 20
        case twentyFive = 25
        case thirty = 30
        case thirtyFive = 35
        case forty = 40
        case fortyFive = 45
        case fifty = 50
        case fiftyFive = 55
        case sixty = 60
    }

    case nextChapter
    case time(Minutes)
}
