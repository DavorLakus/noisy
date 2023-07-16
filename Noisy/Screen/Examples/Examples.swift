import SwiftUI
import Combine

enum ExamplePath: Hashable {
    case firstLevelDetail
    case secondLevelDetail
}

protocol AlertCoordinatorProtocol: ObservableObject {
    var isAlertPresented: Bool { get set }
    func presentAlert() -> Alert
}

final class ExampleCoordinator: VerticalCoordinatorProtocol, AlertCoordinatorProtocol {
    @Published var navigationPath = NavigationPath()
    @Published var isAlertPresented: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    private var firstViewModel: FirstViewModel?
    private var firstLevelDetailViewModel: FirstLevelDetailViewModel?
    private var secondLevelDetailViewModel: SecondLevelDetailViewModel?

    func start() -> ExampleCoordinatorView<ExampleCoordinator> {
        ExampleCoordinatorView(coordinator: self)
    }
    
    init() {
        bindRootViewModel()
    }
    
    func bindRootViewModel() {
        firstViewModel = FirstViewModel()
        
        firstViewModel?.onDidTapNavigateButton
            .sink { [weak self] in
                self?.isAlertPresented = true
//                self?.push(ExamplePath.firstLevelDetail)
            }
            .store(in: &cancellables)
    }
    
    @ViewBuilder
    func rootView() -> some View {
        if let firstViewModel {
            FirstView(viewModel: firstViewModel)
                .navigationDestination(for: ExamplePath.self, destination: navigationDestination)
        }
    }
    
    func presentAlert() -> Alert {
        Alert(title: Text("Text"), primaryButton: .cancel(), secondaryButton: .default(Text("OK")))
    }
    
    @ViewBuilder
    func navigationDestination(_ path: ExamplePath) -> some View {
        switch path {
        case .firstLevelDetail:
            pushFirstLevelDetailView()
        case .secondLevelDetail:
            pushSecondLevelDetailView()
        }
    }
    
    func push(_ path: ExamplePath) {
        switch path {
        case .firstLevelDetail:
            bindFirstLevelDetailViewModel(with: path)
        case .secondLevelDetail:
            bindSecondLevelDetailViewModel(with: path)
        }
        navigationPath.append(path)
    }

    func pop() {
        navigationPath.removeLast()
    }
    
    func bindFirstLevelDetailViewModel(with path: ExamplePath) {
        firstLevelDetailViewModel = FirstLevelDetailViewModel()
        
        firstLevelDetailViewModel?.onDidTapNavigateButton
            .sink { [weak self] in
                self?.push(ExamplePath.firstLevelDetail)
            }
            .store(in: &cancellables)
    }
    
    func bindSecondLevelDetailViewModel(with path: ExamplePath) {
        secondLevelDetailViewModel = SecondLevelDetailViewModel()
    }
    
    @ViewBuilder
    func pushFirstLevelDetailView() -> some View {
        if let firstLevelDetailViewModel {
            FirstLevelDetailView(viewModel: firstLevelDetailViewModel)
        }
    }

    @ViewBuilder
    func pushSecondLevelDetailView() -> some View {
        if let secondLevelDetailViewModel {
            SecondLevelDetailView(viewModel: secondLevelDetailViewModel)
            
        }
    }
}

struct ExampleCoordinatorView<Coordinator: VerticalCoordinatorProtocol & AlertCoordinatorProtocol>: CoordinatorViewProtocol {
    @ObservedObject var coordinator: Coordinator

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath, root: coordinator.rootView)
            .alert(isPresented: $coordinator.isAlertPresented, content: coordinator.presentAlert)
    }
}







class FirstViewModel: ObservableObject {
    let onDidTapNavigateButton = PassthroughSubject<Void, Never>()
    let onDidTapAlertButton = PassthroughSubject<Void, Never>()
}

struct FirstView: View {
    @ObservedObject var viewModel: FirstViewModel
    
    var body: some View {
        Button {
            viewModel.onDidTapNavigateButton.send()
        } label: {
            Text("First level detail")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

class FirstLevelDetailViewModel: ObservableObject {
    @Published var state: Int = 1
    
    let onDidTapNavigateButton = PassthroughSubject<Void, Never>()
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
}

struct FirstLevelDetailView: View {
    @ObservedObject var viewModel: FirstLevelDetailViewModel
    
    var body: some View {
        VStack {
            Button {
                viewModel.onDidTapNavigateButton.send()
            } label: {
                Text("First level detail")
            }
            .background {
                Color.blue.ignoresSafeArea()
            }

            Button {
                viewModel.state = viewModel.state + 1
            } label: {
                Text("\(viewModel.state)")
            }
            .background(.gray)
            
            Button {
                viewModel.onDidTapBackButton.send()
            } label: {
                Text("Back")
            }
            .background {
                Color.blue.ignoresSafeArea()
            }
        }
    }
}


class SecondLevelDetailViewModel: ObservableObject {
    let onDidTapNavigateButton = PassthroughSubject<Void, Never>()
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
}

struct SecondLevelDetailView: View {
    @ObservedObject var viewModel: SecondLevelDetailViewModel

    var body: some View {
        Button {
            viewModel.onDidTapNavigateButton.send()
        } label: {
            Text("Second level detail")
        }
        .background {
            Color.red.ignoresSafeArea()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        Button {
            viewModel.onDidTapBackButton.send()
        } label: {
            Text("Back")
        }
        .background {
            Color.blue.ignoresSafeArea()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ThirdLevelDetailView: View {
    var body: some View {
        Text("Third level detail")
            .background {
                Color.yellow.ignoresSafeArea()
            }
    }
}






//
//enum ExamplePath: Hashable, Identifiable {
//    case firstLevelDetail
//    case secondLevelDetail
//
//    var id: String {
//        String(describing: self)
//    }
//}
//
//final class ExampleCoordinator: ObservableObject {
//    @Published var navigationPath = NavigationPath()
//    var cancellables = Set<AnyCancellable>()
//
//    func start() -> ExampleCoordinatorView {
//        ExampleCoordinatorView(coordinator: self)
//    }
//
//    func rootView() -> some View {
//        let viewModel = FirstViewModel()
//
//        viewModel.onDidTapNavigateButton
//            .sink { [weak self] in
//                self?.navigationPath.append(ExamplePath.secondLevelDetail)
//            }
//            .store(in: &cancellables)
//
//        return FirstView(viewModel: viewModel)
//            .navigationDestination(for: ExamplePath.self, destination: coordinator.navigationDestination)
//    }
//
//    @ViewBuilder
//    func navigationDestination(_ path: ExamplePath) -> some View {
//        switch path {
//        case .firstLevelDetail:
//            pushFirstLevelDetailView()
//        case .secondLevelDetail:
//            pushSecondLevelDetailView()
//        }
//    }
//
//    func pushFirstLevelDetailView() -> some View {
//        let viewModel = FirstLevelDetailViewModel()
//
//        viewModel.onDidTapNavigateButton
//            .sink { [weak self] in
//                self?.navigationPath.append(ExamplePath.secondLevelDetail)
//            }
//            .store(in: &cancellables)
//
//        return FirstLevelDetailView(viewModel: viewModel)
//    }
//
//    func pushSecondLevelDetailView() -> some View {
//        SecondLevelDetailView(viewModel: SecondLevelDetailViewModel())
//    }
//}
//
//struct ExampleCoordinatorView: View {
//    @ObservedObject var coordinator: ExampleCoordinator
//
//    var body: some View {
//        NavigationStack(path: $coordinator.navigationPath) {
//            coordinator.rootView()
//        }
//    }
//}
//
