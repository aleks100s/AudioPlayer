//
//  CompactPlayerView.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftUI

@available(iOS 26.0, *)
struct GlassMiniPlayerView: View {
    let onExpand: () -> Void
    @Environment(\.playerService) private var playerService
    
    private var chapter: Chapter? {
        playerService.currentBook?.currentChapter
    }
    
    private var chapterProgress: Double {
        guard let chapter, chapter.duration.isFinite, chapter.duration > 0,
              chapter.currentTime.isFinite else { return 0 }
        return min(max(chapter.currentTime / chapter.duration, 0), 1)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: onExpand) {
                HStack(spacing: 12) {
                    Image(uiImage: chapter?.image ?? playerService.currentBook?.image ?? .placeholder)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(chapter?.name ?? "")
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ProgressView(value: chapterProgress)
                            .progressViewStyle(.linear)
                            .tint(.primary)
                            .accessibilityLabel("Прогресс главы")
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint("Открыть плеер")
            
            Button {
                playerService.pauseOrResume()
            } label: {
                Image(systemName: playerService.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title3.weight(.semibold))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(playerService.isPlaying ? "Пауза" : "Воспроизвести")
            .sensoryFeedback(playerService.isPlaying ? .stop : .start, trigger: playerService.isPlaying)
        }
        .padding(.leading, 10)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}

@available(iOS 26.0, *)
struct ExpandedPlayerView: View {
    @Binding var isSliderBusy: Bool
    @Binding var progress: Double
    let onTimerTap: () -> Void
    
    @Environment(\.playerService) private var playerService
    @AppStorage(Constants.playbackRate) private var rate: Double = 1
    
    private var chapter: Chapter? { playerService.currentBook?.currentChapter }
    private var playbackRate: PlaybackRate { .init(rawValue: rate) ?? .x100 }
    private var chapterPosition: Int? {
        guard let book = playerService.currentBook, let chapter,
              let index = book.orderedChapters.firstIndex(of: chapter) else { return nil }
        return index + 1
    }
    
    var body: some View {
        GlassEffectContainer(spacing: 4) {
            VStack(spacing: 8) {
                HStack {
                    Image(uiImage: chapter?.image ?? playerService.currentBook?.image ?? .placeholder)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.18), radius: 14, y: 8)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(playerService.currentBook?.title ?? "")
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        if let chapterPosition, let book = playerService.currentBook {
                            Text("Глава \(chapterPosition) из \(book.orderedChapters.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(chapter?.name ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 0) {
                    SliderView(isSliderBusy: $isSliderBusy, progress: $progress)
                    HStack {
                        Text(timeText(chapter?.currentTime))
                        Spacer()
                        Text(timeText(chapter?.duration))
                    }
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                }
                
                transportControls
                bottomControls
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .frame(maxWidth: 620)
        .onChange(of: rate) { _, newValue in
            playerService.changePlayback(rate: .init(rawValue: newValue) ?? .x100)
        }
        
    }
    
    private var transportControls: some View {
        HStack(spacing: 0) {
            transportButton("backward.end.fill", label: "Предыдущая глава") {
                do { try playerService.previousChapter() } catch { Log.error(error.localizedDescription) }
            }
            Spacer(minLength: 0)
            transportButton("gobackward.\(Constants.skipBackwardInterval)", label: "Назад на \(Constants.skipBackwardInterval) секунд") {
                playerService.skipBackward(time: TimeInterval(Constants.skipBackwardInterval))
            }
            Spacer(minLength: 0)
            Button { playerService.pauseOrResume() } label: {
                Image(systemName: playerService.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2.bold())
                    .frame(width: 64, height: 64)
            }
            .buttonBorderShape(.circle)
            .accessibilityLabel(playerService.isPlaying ? "Пауза" : "Воспроизвести")
            .sensoryFeedback(playerService.isPlaying ? .stop : .start, trigger: playerService.isPlaying)
            Spacer(minLength: 0)
            transportButton("goforward.\(Constants.skipForwardInterval)", label: "Вперёд на \(Constants.skipForwardInterval) секунд") {
                playerService.skipForward(time: TimeInterval(Constants.skipForwardInterval))
            }
            Spacer(minLength: 0)
            transportButton("forward.end.fill", label: "Следующая глава") {
                do { try playerService.nextChapter() } catch { Log.error(error.localizedDescription) }
            }
        }
        .buttonStyle(.glass)
    }
    
    private func transportButton(_ symbol: String, label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.title2)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(label)
    }
    
    private func timeText(_ value: Double?) -> String {
        guard let value, value.isFinite, value >= 0 else { return "00:00" }
        return value.timeString
    }
    
    private var bottomControls: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                speedMenu
                Spacer(minLength: 8)
                timerButton
            }
            VStack(spacing: 8) {
                speedMenu
                timerButton
            }
        }
        .controlSize(.large)
    }
    
    private var speedMenu: some View {
        Menu {
            ForEach(PlaybackRate.allCases, id: \.rawValue) { option in
                Button {
                    rate = option.rawValue
                } label: {
                    if option == playbackRate {
                        Label(option.title, systemImage: "checkmark")
                    } else {
                        Text(option.title)
                    }
                }
            }
        } label: {
            Label(playbackRate.title, systemImage: "chevron.up.chevron.down")
                .labelStyle(.titleAndIcon)
        }
        .buttonStyle(.glass)
    }
    
    private var timerButton: some View {
        Button(action: onTimerTap) {
            Label(playerService.sleepTimer == nil ? "Таймер сна" : "Таймер сна •", systemImage: "moon.zzz")
                .labelStyle(.titleAndIcon)
        }
        .buttonStyle(.glass)
    }
}

struct CompactPlayerView: View {
    @Binding var isSliderBusy: Bool
    @Binding var progress: Double
    
    var showsBackground = true
    let onPlaylistTap: () -> Void
    
    @Environment(\.playerService) private var playerService
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            title
            
            SeekerView(isSliderBusy: $isSliderBusy, progress: $progress)
            
            ControlsView()
            
            PlaybackRateView(onTimerTap: onPlaylistTap)
        }
        .padding(.padding)
        .background {
            if showsBackground {
                Rectangle().fill(.regularMaterial)
            }
        }
    }
    
    private var title: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(playerService.currentBook?.currentChapter?.name ?? "")
                    .lineLimit(2)
                
                Text(playerService.currentBook?.title ?? "")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

private struct HandlerView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(.gray.opacity(0.4))
            .frame(width: 50, height: 6)
    }
}

private struct SeekerView: View {
    @Binding var isSliderBusy: Bool
    @Binding var progress: Double
    
    @State private var durationRange: ClosedRange<TimeInterval> = 0...0
    
    @Environment(\.playerService) private var playerService
    
    var body: some View {
        HStack {
            TimeView(text: playerService.currentBook?.currentChapter?.currentTime.timeString ?? "")
            
            SliderView(isSliderBusy: $isSliderBusy, progress: $progress)
            
            TimeView(text: playerService.currentBook?.currentChapter?.duration.timeString ?? "")
        }
    }
}

private struct TimeView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .monospaced()
            .contentTransition(.numericText())
    }
}

private struct SliderView: View {
    @Binding var isSliderBusy: Bool
    @Binding var progress: Double
    
    @Environment(\.playerService) private var playerService
    
    private var duration: TimeInterval {
        let value = playerService.currentBook?.currentChapter?.duration ?? 0
        return value.isFinite && value > 0 ? value : 0
    }
    
    var body: some View {
        Slider(
            value: Binding(
                get: { progress.isFinite ? min(max(progress, 0), duration) : 0 },
                set: { progress = $0 }
            ),
            in: 0...(duration > 0 ? duration : 1)
        ) { isSliderBusy in
            self.isSliderBusy = isSliderBusy
        }
        .disabled(duration == 0)
        .accessibilityLabel("Позиция воспроизведения")
        .onChange(of: progress) { _, newValue in
            if isSliderBusy, duration > 0, newValue.isFinite {
                playerService.setPlayback(time: min(max(newValue, 0), duration))
            }
        }
    }
}

private struct ControlsView: View {
    enum Control: CaseIterable {
        case previousTrack
        case skipBack
        case play
        case skipForward
        case nextTrack
    }
    
    @Environment(\.playerService) private var playerService
    
    var body: some View {
        HStack {
            Spacer()
            
            ForEach(Control.allCases, id: \.self) { control in
                switch control {
                case .previousTrack:
                    ImageButton(systemName: "backward.end.fill", label: "Предыдущая глава") {
                        do {
                            try playerService.previousChapter()
                        } catch {
                            Log.error(error.localizedDescription)
                        }
                    }
                    
                case .skipBack:
                    ImageButton(systemName: "gobackward.\(Constants.skipBackwardInterval)", label: "Назад на \(Constants.skipBackwardInterval) секунд") {
                        playerService.skipBackward(time: TimeInterval(Constants.skipBackwardInterval))
                    }
                    
                case .play:
                    ImageButton(systemName: playerService.isPlaying ? "pause.fill" : "play.fill", label: playerService.isPlaying ? "Пауза" : "Воспроизвести") {
                        playerService.pauseOrResume()
                    }
                    .animation(.spring, value: playerService.isPlaying)
                    .sensoryFeedback(playerService.isPlaying ? .stop : .start, trigger: playerService.isPlaying)
                    
                case .skipForward:
                    ImageButton(systemName: "goforward.\(Constants.skipForwardInterval)", label: "Вперёд на \(Constants.skipForwardInterval) секунд") {
                        playerService.skipForward(time: TimeInterval(Constants.skipForwardInterval))
                    }
                    
                case .nextTrack:
                    ImageButton(systemName: "forward.end.fill", label: "Следующая глава") {
                        do {
                            try playerService.nextChapter()
                        } catch {
                            Log.error(error.localizedDescription)
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}

private struct PlaybackRateView: View, Equatable {
    static func == (lhs: PlaybackRateView, rhs: PlaybackRateView) -> Bool {
        lhs.playbackRate == rhs.playbackRate
    }
    
    let onTimerTap: () -> Void
    
    @AppStorage(Constants.playbackRate) private var rate: Double = 1
    
    @Environment(\.playerService) private var playerService
    
    private var playbackRate: PlaybackRate {
        .init(rawValue: rate) ?? .x100
    }
    
    var body: some View {
        HStack {
            Picker(
                playbackRate.title,
                selection: .init(get: { playbackRate }, set: { rate = $0.rawValue }),
                content: {
                    ForEach(PlaybackRate.allCases, id: \.rawValue) { rate in
                        Text(rate.title)
                            .tag(rate)
                    }
                }
            )
            .pickerStyle(.menu)
            
            Spacer()
            
            Button {
                onTimerTap()
            } label: {
                if playerService.sleepTimer != nil {
                    Label("Таймер сна •", systemImage: "timer")
                        .bold()
                } else {
                    Label("Таймер сна", systemImage: "timer")
                }
            }
        }
        .onChange(of: rate) { oldValue, newValue in
            playerService.changePlayback(rate: .init(rawValue: newValue) ?? .x100)
        }
    }
}

private struct ImageButton: View {
    let systemName: String
    let label: LocalizedStringKey
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Image(systemName: systemName)
                .font(.title)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(label)
    }
}

private extension CGFloat {
    static let padding: CGFloat = 16
}
