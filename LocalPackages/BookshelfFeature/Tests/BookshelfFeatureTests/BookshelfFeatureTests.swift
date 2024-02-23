import AudioService
import BookMetaInfoService
import ComposableArchitecture
import Domain
import DomainMock
import FileService
import XCTest
@testable import BookshelfFeature

final class BookshelfFeatureTests: XCTestCase {
	private var store: TestStore<BookshelfFeature.State, BookshelfFeature.Action>!
	
	override func setUp() {
		super.setUp()
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.fileService = .mock()
			$0.storageService = .mock()
			$0.bookMetaInfoService = .mock()
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
}

// MARK: - Controls

extension BookshelfFeatureTests {
	func test_playbackTimeChanged_whilePlaying() async {
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
			$0.storageService = .previewValue
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
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
			$0.storageService = .previewValue
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
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		await store.send(.playbackSliderPositionChanged(123))
	}
	
	func test_skipForward() async {
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		await store.send(.skipForwardButtonTapped)
	}
	
	func test_skipBackward() async {
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		await store.send(.skipBackwardButtonTapped)
	}
	
	func test_changePlaybackRateButtonTapped() async {
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
			$0.storageService = .previewValue
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
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		await store.send(.playNextTrackButtonTapped)
	}
	
	func test_playNextTrackButtonTapped_withCurrentAudio() async {
		let chapters: [AudioFile] = [.mock(), .mock(), .mock()]
		let books: [Book] = [.mock(title: UUID().uuidString, chapters: chapters),]
		var state = BookshelfFeature.State(books: books)
		state.currentBook = books[0]
		state.currentAudio = chapters[1]
		store = TestStore(initialState: state) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
			$0.storageService = .previewValue
		}
		await store.send(.playNextTrackButtonTapped)
		await store.receive(.audioSelected(chapters[2]))
		await store.receive(.playerStarted(chapters[2])) {
			$0.currentAudio = chapters[2]
			$0.playerState = .playing
		}
		// Side effect of the mocked audio service
		await store.receive(.playNextTrackButtonTapped)
	}
	
	func test_playNextTrackButtonTapped_lastAudio() async {
		let chapters: [AudioFile] = [.mock(), .mock(), .mock()]
		let books: [Book] = [.mock(title: UUID().uuidString, chapters: chapters),]
		var state = BookshelfFeature.State(books: books)
		state.currentBook = books[0]
		state.currentAudio = chapters[2]
		store = TestStore(initialState: state) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		await store.send(.playNextTrackButtonTapped)
	}
	
	func test_playPreviousTrackButtonTapped_noCurrentAudio() async {
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		await store.send(.playPreviousTrackButtonTapped)
	}
	
	func test_playPreviousTrackButtonTapped_withCurrentAudio() async {
		let chapters: [AudioFile] = [.mock(), .mock(), .mock()]
		let books: [Book] = [.mock(title: UUID().uuidString, chapters: chapters),]
		var state = BookshelfFeature.State(books: books)
		state.currentBook = books[0]
		state.currentAudio = chapters[1]
		store = TestStore(initialState: state) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
			$0.storageService = .previewValue
		}
		await store.send(.playPreviousTrackButtonTapped)
		await store.receive(.audioSelected(chapters[0]))
		await store.receive(.playerStarted(chapters[0])) {
			$0.currentAudio = chapters[0]
			$0.playerState = .playing
		}
		// Side effect of the mocked audio service
		await store.receive(.playNextTrackButtonTapped)
		await store.receive(.audioSelected(chapters[1]))
		await store.receive(.playerStarted(chapters[1])) {
			$0.currentAudio = chapters[1]
			$0.playerState = .playing
		}
		await store.receive(.playNextTrackButtonTapped)
		await store.receive(.audioSelected(chapters[2]))
		await store.receive(.playerStarted(chapters[2])) {
			$0.currentAudio = chapters[2]
			$0.playerState = .playing
		}
		await store.receive(.playNextTrackButtonTapped)
	}
	
	func test_playPreviousTrackButtonTapped_firstAudio() async {
		let chapters: [AudioFile] = [.mock(), .mock(), .mock()]
		let books: [Book] = [.mock(title: UUID().uuidString, chapters: chapters),]
		var state = BookshelfFeature.State(books: books)
		state.currentBook = books[0]
		state.currentAudio = chapters[0]
		store = TestStore(initialState: state) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
			$0.storageService = .mock()
		}
		await store.send(.playPreviousTrackButtonTapped)
		await store.receive(.playbackSliderPositionChanged(0))
	}
	
	func test_playPreviousTrackButtonTapped_currentTimeIsBiggerThan5Seconds() async {
		let chapters: [AudioFile] = [.mock(), .mock(), .mock()]
		let books: [Book] = [.mock(title: UUID().uuidString, chapters: chapters),]
		var state = BookshelfFeature.State(books: books)
		state.currentBook = books[0]
		state.currentAudio = chapters[1]
		state.playbackStatus = PlaybackStatus(currentTime: 10, duration: 100, isPlaying: true)
		store = TestStore(initialState: state) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
			$0.storageService = .previewValue
		}
		await store.send(.playPreviousTrackButtonTapped)
		await store.receive(.playbackSliderPositionChanged(0))
	}
}

// MARK: - Files

extension BookshelfFeatureTests {
	func test_fileServiceFails_afterViewDidLoad() async {
		let error = MockError.unknown(UUID().uuidString)
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.fileService = .mock(getBookAudioFilesResult: { _ in .failure(error) })
			$0.storageService = .mock(getBooks: { [BookDto(id: UUID(), title: "", author: "", files: [])] })
		}
		
		await store.send(.viewDidLoad)
		await store.receive(.errorOccurred(error.localizedDescription), timeout: .milliseconds(100)) {
			$0.errorMessage = error.localizedDescription
		}
	}
	
	func test_fileServiceReturnsNoAudioFiles_afterViewDidLoad() async {
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.fileService = .mock(getAudioFilesResult: { .success([]) })
			$0.storageService = .mock()
		}
		
		await store.send(.viewDidLoad)
		await store.receive(.booksLoaded([]), timeout: .milliseconds(100))
		await store.receive(.restoreAudioSession)
	}
	
	func test_fileServiceReturnsAudioFiles_afterViewDidLoad() async {
		let audio = AudioFile.mock()
		let book = Book.mock(chapters: [audio])
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.fileService = .mock(getBookAudioFilesResult: { _ in .success([audio]) })
			$0.storageService = .mock(getBooks: { [BookDto(id: UUID(), title: "Дюна", author: "Фрэнк Герберт", files: [])]})
			$0.bookMetaInfoService = .mock()
		}
		
		await store.send(.viewDidLoad)
		await store.receive(.booksLoaded([book]), timeout: .milliseconds(100)) {
			$0.books = [book]
		}
		await store.receive(.restoreAudioSession)
	}
	
	func test_saveEmptyArrayOfFiles() async {
		await store.send(.saveBookFiles([]))
	}
	
	func test_saveFilesSuccess() async {
		await store.send(.saveBookFiles([URL(string: "url://")!]))
		await store.receive(.viewDidLoad, timeout: .microseconds(100))
		await store.receive(.booksLoaded([]), timeout: .milliseconds(100))
		await store.receive(.restoreAudioSession)
	}
	
	func test_saveFilesFails() async {
		let error = MockError.unknown(UUID().uuidString)
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.fileService = .mock(saveBookAudioFilesResult: { _,_  in .failure(error) })
			$0.bookMetaInfoService = .mock()
			$0.storageService = .mock()
		}
		
		await store.send(.saveBookFiles([URL(string: "url://")!]))
		await store.receive(.errorOccurred(error.localizedDescription)) {
			$0.errorMessage = error.localizedDescription
		}
	}
	
//	func test_deleteFiles_success() async {
//		store = TestStore(initialState: BookshelfFeature.State(books: [.mock()])) {
//			BookshelfFeature()
//		} withDependencies: {
//			$0.fileService = .mock(deleteAudioFilesResult: { _ in .success(()) })
//		}
//		
//		await store.send(.deleteFiles(IndexSet(integer: 0))) {
//			$0.allFiles = []
//			$0.filteredFiles = []
//		}
//	}
//	
//	func test_deleteFiles_failure() async {
//		let error = MockError.unknown(UUID().uuidString)
//		store = TestStore(initialState: BookshelfFeature.State()) {
//			BookshelfFeature()
//		} withDependencies: {
//			$0.fileService = .mock(deleteAudioFilesResult: { _ in .failure(error) })
//		}
//		
//		await store.send(.deleteFiles(IndexSet()))
//		await store.receive(.errorOccurred(error.localizedDescription)) {
//			$0.errorMessage = error.localizedDescription
//		}
//	}
}

// MARK: - Audio

extension BookshelfFeatureTests {
	func test_audioTapped_audioSetupFails() async {
		let error = MockError.unknown(UUID().uuidString)
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock(setupAudioResult: { .failure(error) })
		}
		
		await store.send(.audioSelected(.mock()))
		await store.receive(.errorOccurred(error.localizedDescription)) {
			$0.errorMessage = error.localizedDescription
		}
	}
	
	func test_audioTapped_playCurrentAudioFails() async {
		let error = MockError.unknown(UUID().uuidString)
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock(playCurrentAudioResult: { .failure(error) })
		}
		
		await store.send(.audioSelected(.mock()))
		await store.receive(.errorOccurred(error.localizedDescription)) {
			$0.errorMessage = error.localizedDescription
		}
	}
	
	func test_audioTapped_success() async {
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
			$0.storageService = .previewValue
		}
		
		let file = AudioFile.mock()
		await store.send(.audioSelected(file))
		await store.receive(.playerStarted(file)) {
			$0.playerState = .playing
			$0.currentAudio = file
		}
		await store.receive(.playNextTrackButtonTapped)
	}
	
	func test_pauseButtonTapped() async {
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		
		await store.send(.pauseButtonTapped) {
			$0.playerState = .paused
		}
	}
	
	func test_resumeButtonTapped() async {
		store = TestStore(initialState: BookshelfFeature.State()) {
			BookshelfFeature()
		} withDependencies: {
			$0.audioService = AudioServiceImpl.mock()
		}
		
		await store.send(.resumeButtonTapped) {
			$0.playerState = .playing
		}
	}
}

