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
    @Environment(\.dismiss) private var dismiss
    @State private var selection: TimerMode.Minutes = .fifteen
    @State private var isEndOfChapter: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    if let currentTimer {
                        Text("У вас установлен таймер на \(currentTimer.title)")
                            .multilineTextAlignment(.center)
                    } else {
                        Picker("Временной интервал", selection: $selection) {
                            ForEach(TimerMode.Minutes.allCases, id: \.rawValue) { option in
                                Text(option.title)
                                    .tag(option)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 180)
                        .clipped()
                        .disabled(isEndOfChapter)

                        Toggle("Конец главы", isOn: $isEndOfChapter)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
                    }
                }
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    timerButton
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Закрыть")
                }
            }
            .navigationTitle("Таймер сна")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var timerButton: some View {
        if #available(iOS 26.0, *) {
            Button(role: currentTimer == nil ? .confirm : .destructive) {
                if currentTimer != nil {
                    onResetTimer()
                } else if isEndOfChapter {
                    onSetTimer(.nextChapter)
                } else {
                    onSetTimer(.time(selection))
                }
            } label: {
                Label(
                    currentTimer == nil ? "Установить таймер" : "Сбросить таймер",
                    systemImage: currentTimer == nil ? "checkmark" : "arrow.counterclockwise"
                )
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
        } else {
            Button(role: currentTimer == nil ? nil : .destructive) {
                if currentTimer != nil {
                    onResetTimer()
                } else if isEndOfChapter {
                    onSetTimer(.nextChapter)
                } else {
                    onSetTimer(.time(selection))
                }
            } label: {
                Label(
                    currentTimer == nil ? "Установить таймер" : "Сбросить таймер",
                    systemImage: currentTimer == nil ? "checkmark" : "arrow.counterclockwise"
                )
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
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
