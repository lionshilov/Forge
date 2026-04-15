import SwiftUI

struct ExampleView: View {
    @State var viewModel: ExampleViewModel

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            content
        }
        .padding(Theme.Spacing.lg)
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Text("Ready.")
                .foregroundStyle(.secondary)
        case .loading:
            ProgressView()
                .accessibilityLabel("Loading")
        case let .loaded(message):
            Text(message)
                .font(.title2)
                .multilineTextAlignment(.center)
        case let .failed(message):
            Text("Failed: \(message)")
                .foregroundStyle(.red)
                .accessibilityLabel("Load failed: \(message)")
        }
    }
}

#Preview("Loaded") {
    let vm = ExampleViewModel()
    return ExampleView(viewModel: vm)
}
