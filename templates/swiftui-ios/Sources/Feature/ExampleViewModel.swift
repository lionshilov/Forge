import Foundation
import Observation

@MainActor
@Observable
final class ExampleViewModel {
    enum State {
        case idle
        case loading
        case loaded(String)
        case failed(String)
    }

    private(set) var state: State = .idle

    private let api: APIClient?

    init(api: APIClient? = nil) {
        self.api = api
    }

    func load() async {
        state = .loading
        do {
            try await Task.sleep(for: .milliseconds(400))
            state = .loaded("Hello from the ViewModel.")
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
