import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ExampleView(viewModel: ExampleViewModel())
        }
    }
}
