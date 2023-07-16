////
////  Examples2.swift
////  Noisy
////
////  Created by Davor Lakus on 14.07.2023..
////
//
//import SwiftUI
//import Combine
//

//
//final class ExampleCoordinator {
//    @Published var navigationPath = NavigationPath()
//    private lazy var navigationStack = NavigationStack(path: $navigationPath, root: rootView)
//    private var cancellables = Set<AnyCancellable>()
//    
//    func start() -> some View {
//        navigationStack
//    }
//    
//    func rootView() -> some View {
//        let viewModel = FirstViewModel()
//        
//        viewModel.onDidTapNavigateButton
//            .sink { [weak self] in
//                self?.navigationPath.append(ExamplePath.firstLevelDetail)
//            }
//            .store(in: &cancellables)
//        
//        return FirstView(viewModel: viewModel)
//            .navigationDestination(for: ExamplePath.self, destination: navigationDestination)
//    }
//    
//    @ViewBuilder
//    func navigationDestination(for path: ExamplePath) -> some View {
//        switch path {
//        case .details:
//            pushFirstLevelDetailView()
//        }
//    }
//    
//    func pushFirstLevelDetailView() -> some View {
//        FirstLevelDetailView(viewModel: FirstLevelDetailViewModel())
//    }
//}
//
