//
//  TimerSheetView.swift
//  AudioPlayer
//
//  Created by Alexander on 26.09.2025.
//

import SwiftUI

struct TimerSheetView: View {
    let currentTimer: TimerMode?
    let onSetTimer: (TimerMode) -> Void
    let onResetTimer: () -> Void
    @State private var selection: TimerMode.Minutes = .five
    @State private var isEndOfChapter: Bool = false
    
    init(currentTimer: TimerMode?, onSetTimer: @escaping (TimerMode) -> Void, onResetTimer: @escaping () -> Void) {
        self.currentTimer = currentTimer
        self.onSetTimer = onSetTimer
        self.onResetTimer = onResetTimer
        switch currentTimer {
        case .nextChapter:
            isEndOfChapter = true
        case .time(let minutes):
            selection = minutes
        default:
            selection = .five
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if let currentTimer {
                    Text("У вас установлен таймер на \(currentTimer.title)")
                } else {
                    Text("Выберите, через какое время автоматически остановить воспроизведение")
                    
                    Picker("Временной интервал", selection: $selection) {
                        ForEach(TimerMode.Minutes.allCases, id: \.rawValue) { option in
                            Text(option.title)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Toggle("Конец главы", isOn: $isEndOfChapter)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(currentTimer == nil ? "Установить таймер" : "Сбросить таймер") {
                        if currentTimer == nil {
                            if isEndOfChapter {
                                onSetTimer(.nextChapter)
                            } else {
                                onSetTimer(.time(selection))
                            }
                        } else {
                            onResetTimer()
                        }
                    }
                }
            }
            .navigationTitle("Таймер сна")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension TimerMode {
    var title: String {
        switch self {
        case .nextChapter:
            String(localized: "конец главы")
        case .time(let minutes):
            minutes.title
        }
    }
}

private extension TimerMode.Minutes {
    var title: String {
        String(localized: "\(rawValue) минут")
    }
}
