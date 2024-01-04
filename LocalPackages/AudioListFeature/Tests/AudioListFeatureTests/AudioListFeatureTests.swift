import AudioService
import ComposableArchitecture
import Domain
import DomainMock
import XCTest
@testable import AudioListFeature

final class AudioListFeatureTests: XCTestCase {
	private var store: TestStore<AudioListFeature.State, AudioListFeature.Action>!
	
	override func setUp() {
		super.setUp()
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.fileService = .mock()
		}
	}
	
	override func tearDown() {
		store = nil
		super.tearDown()
	}
	
	func test_errorMessage_afterErrorAlertDismissed() async {
		await store.send(.errorOccurred("Error occurred")) {
			$0.errorMessage = "Error occurred"
		}
		await store.send(.errorAlertDismissed) {
			$0.errorMessage = nil
		}
	}
	
	func test_searchTextChanged() async {
		let file1 = AudioFile.mock(name: "qwerty")
		let file2 = AudioFile.mock(name: "123456")
		store = TestStore(initialState: AudioListFeature.State(files: [file1, file2])) {
			AudioListFeature()
		}
		await store.send(.searchTextChanged("qwe")) {
			$0.filteredFiles = [file1]
		}
		await store.send(.searchTextChanged("")) {
			$0.filteredFiles = [file1, file2]
		}
	}
	
	func test_playbackTimeChanged_whilePlaying() async {
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		let status = PlaybackStatus(currentTime: 123, duration: 1000, isPlaying: true)
		await store.send(.playbackStatusChanged(status)) {
			$0.currentTime = "02:03"
			$0.duration = "16:40"
			$0.playerState = .playing
			$0.playbackStatus = status
		}
	}
	
	func test_playbackTimeChanged_onPause() async {
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		let status = PlaybackStatus(currentTime: 123, duration: 1000, isPlaying: false)
		await store.send(.playbackStatusChanged(status)) {
			$0.currentTime = "02:03"
			$0.duration = "16:40"
			$0.playerState = .paused
			$0.playbackStatus = status
		}
	}
	
	func test_playbackSliderPositionChanged() async {
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		await store.send(.playbackSliderPositionChanged(123))
	}
	
	func test_skipForward() async {
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		await store.send(.skipForwardButtonTapped)
	}
	
	func test_skipBackward() async {
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		await store.send(.skipBackwardButtonTapped)
	}
	
	func test_changePlaybackRateButtonTapped() async {
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		await store.send(.changePlaybackRateButtonTapped) {
			$0.playbackRate = .x125
		}
		await store.send(.changePlaybackRateButtonTapped) {
			$0.playbackRate = .x150
		}
		await store.send(.changePlaybackRateButtonTapped) {
			$0.playbackRate = .x175
		}
		await store.send(.changePlaybackRateButtonTapped) {
			$0.playbackRate = .x200
		}
		await store.send(.changePlaybackRateButtonTapped) {
			$0.playbackRate = .x100
		}
	}
	
	func test_playNextTrackButtonTapped_noCurrentAudio() async {
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		await store.send(.playNextTrackButtonTapped)
	}
	
	func test_playNextTrackButtonTapped_withCurrentAudio() async {
		let allAudio: [AudioFile] = [.mock(), .mock(), .mock()]
		var state = AudioListFeature.State(files: allAudio)
		state.currentAudio = allAudio[1]
		store = TestStore(initialState: state) {
			AudioListFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		await store.send(.playNextTrackButtonTapped)
		await store.receive(.audioTapped(allAudio[2]))
		await store.receive(.playerStarted(allAudio[2])) {
			$0.currentAudio = allAudio[2]
			$0.playerState = .playing
		}
		await store.receive(.playNextTrackButtonTapped)
	}
}

// MARK: - Files

extension AudioListFeatureTests {
	func test_fileServiceFails_afterViewDidLoad() async {
		let error = MockError.unknown(UUID().uuidString)
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.fileService = .mock(getAudioFilesResult: { .failure(error) })
		}
		
		await store.send(.viewDidLoad)
		await store.receive(.errorOccurred(error.localizedDescription), timeout: .milliseconds(100)) {
			$0.errorMessage = error.localizedDescription
		}
	}
	
	func test_fileServiceReturnsNoAudioFiles_afterViewDidLoad() async {
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.fileService = .mock(getAudioFilesResult: { .success([]) })
		}
		
		await store.send(.viewDidLoad)
		await store.receive(.filesLoaded([]), timeout: .milliseconds(100))
	}
	
	func test_fileServiceReturnsAudioFiles_afterViewDidLoad() async {
		let file = AudioFile.mock()
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.fileService = .mock(getAudioFilesResult: { .success([file]) })
		}
		
		await store.send(.viewDidLoad)
		await store.receive(.filesLoaded([file]), timeout: .milliseconds(100)) {
			$0.allFiles = [file]
			$0.filteredFiles = [file]
		}
	}
	
	func test_saveEmptyArrayOfFiles() async {
		await store.send(.saveFiles([]))
	}
	
	func test_saveFilesSuccess() async {
		await store.send(.saveFiles([URL(string: "url://")!]))
		await store.receive(.viewDidLoad, timeout: .microseconds(100))
		await store.receive(.filesLoaded([]), timeout: .milliseconds(100))
	}
	
	func test_saveFilesFails() async {
		let error = MockError.unknown(UUID().uuidString)
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.fileService = .mock(saveAudioFilesResult: { _ in .failure(error) })
		}
		
		await store.send(.saveFiles([URL(string: "url://")!]))
		await store.receive(.errorOccurred(error.localizedDescription)) {
			$0.errorMessage = error.localizedDescription
		}
	}
	
	func test_deleteFiles_success() async {
		store = TestStore(initialState: AudioListFeature.State(files: [.mock()])) {
			AudioListFeature()
		} withDependencies: {
			$0.fileService = .mock(deleteAudioFilesResult: { _ in .success(()) })
		}
		
		await store.send(.deleteFiles(IndexSet(integer: 0))) {
			$0.allFiles = []
			$0.filteredFiles = []
		}
	}
	
	func test_deleteFiles_failure() async {
		let error = MockError.unknown(UUID().uuidString)
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.fileService = .mock(deleteAudioFilesResult: { _ in .failure(error) })
		}
		
		await store.send(.deleteFiles(IndexSet()))
		await store.receive(.errorOccurred(error.localizedDescription)) {
			$0.errorMessage = error.localizedDescription
		}
	}
}

// MARK: - Audio

extension AudioListFeatureTests {
	func test_audioTapped_audioSetupFails() async {
		let error = MockError.unknown(UUID().uuidString)
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock(setupAudioResult: { .failure(error) })
		}
		
		await store.send(.audioTapped(.mock()))
		await store.receive(.errorOccurred(error.localizedDescription)) {
			$0.errorMessage = error.localizedDescription
		}
	}
	
	func test_audioTapped_playCurrentAudioFails() async {
		let error = MockError.unknown(UUID().uuidString)
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock(playCurrentAudioResult: { .failure(error) })
		}
		
		await store.send(.audioTapped(.mock()))
		await store.receive(.errorOccurred(error.localizedDescription)) {
			$0.errorMessage = error.localizedDescription
		}
	}
	
	func test_audioTapped_success() async {
		let error = MockError.unknown(UUID().uuidString)
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		
		let file = AudioFile.mock()
		await store.send(.audioTapped(file))
		await store.receive(.playerStarted(file)) {
			$0.playerState = .playing
			$0.currentAudio = file
		}
		await store.receive(.playNextTrackButtonTapped)
	}
	
	func test_pauseButtonTapped() async {
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		
		await store.send(.pauseButtonTapped) {
			$0.playerState = .paused
		}
	}
	
	func test_resumeButtonTapped() async {
		store = TestStore(initialState: AudioListFeature.State()) {
			AudioListFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		
		await store.send(.resumeButtonTapped) {
			$0.playerState = .playing
		}
	}
}
