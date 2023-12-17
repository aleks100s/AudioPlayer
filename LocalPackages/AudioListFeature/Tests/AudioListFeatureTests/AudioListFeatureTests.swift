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
			$0.files = [file]
		}
	}
	
	func test_errorMessage_afterErrorAlertDismissed() async {
		await store.send(.errorOccurred("Error occurred")) {
			$0.errorMessage = "Error occurred"
		}
		await store.send(.errorAlertDismissed) {
			$0.errorMessage = nil
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
}
