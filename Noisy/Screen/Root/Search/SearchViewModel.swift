//
//  SearchViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 08.06.2023..
//

import SwiftUI
import Combine

enum EmployeeSort: CaseIterable {
    case name
    case surname
    case department
    case lead
    
    var title: String {
        switch self {
        case .name:
            return "Name"
        case .surname:
            return "Surname"
        case .department:
            return "Department"
        case .lead:
            return "Lead"
        }
    }
}

final class SearchViewModel: ObservableObject {
    
    // MARK: - Coordinator actions
    let onDidTapProfileButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Published properties
    @Published var searchIsActive = false
    @Published var presentedTracks: [Track] = []
    @Published var query = String.empty
    @Published var tabBarVisibility: Visibility = .visible
    @Published var isFilterPresented: Bool = false
    @Published var isSortPresented: Bool = false
    @Published var state: AppState = .loaded
    var profile: Profile? {
        guard let profile  = UserDefaults.standard.object(forKey: .Login.profile) as? Data
        else { return nil }
        return try? JSONDecoder().decode(Profile.self, from: profile)
    }
    
    // MARK: - Public properties
//    var departments: [Department] = []
    var filteringOptions: [String] = []
    var sortingOption: EmployeeSort = .name
    var tracks: [Track] = []
    var noData: Bool {
        searchIsActive && presentedTracks.isEmpty && !query.isEmpty
    }

    // MARK: - Private properties
    private let searchService: SearchService
    private let filteringOptionsSelected = PassthroughSubject<Void, Never>()
    private let sortingOptionSelected = PassthroughSubject<Void, Never>()

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class llifecycle
    init(searchService: SearchService) {
        self.searchService = searchService
        
        bindState()
        bindSearch()
        bindFiltering()
        fetchEmployees()
        getDepartments()
    }
}

// MARK: - Private extension
private extension SearchViewModel {
    func bindState() {
        NetworkingManager.state
            .assign(to: &_state.projectedValue)
    }
    
    func fetchEmployees() {
//        trac.getEmployees()
//            .sink { [weak self] employees in
//                self?.employees = employees
//                self?.reloadEmployees()
//            }
//            .store(in: &cancellables)
    }
    
    func getDepartments() {
//        employeesService.getDepartments()
//            .sink { [weak self] departments in
//                self?.departments = departments
//            }
//            .store(in: &cancellables)
    }
    
    func bindSearch() {
        $searchIsActive
            .dropFirst()
            .sink { [weak self] isActive in
                if isActive {
                    self?.reloadEmployees(searchActivated: true)
                } else {
                    self?.state = .loaded
                    self?.query = String.empty
                }
            }
            .store(in: &cancellables)
        
        $query
            .dropFirst()
            .flatMap { [weak self] in
                self?.state = .loading
                return Just($0)
            }
            .debounce(for: .seconds(0.4), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                withAnimation {
                    self?.reloadEmployees()
                }
            }
            .store(in: &cancellables)
    }
    
    func bindFiltering() {
        filteringOptionsSelected
            .sink { [weak self]  in
                withAnimation {
                    self?.reloadEmployees()
                }
            }
            .store(in: &cancellables)
        
        sortingOptionSelected
            .sink { [weak self] _ in
                withAnimation {
                    self?.reloadEmployees()
                }
            }
            .store(in: &cancellables)
    }
    
    func reloadEmployees(searchActivated: Bool = false) {
//        if searchIsActive || searchActivated || !query.isEmpty {
//            presentedEmployees = employees
//                .sorted(by: { $0.surname < $1.surname })
//                .filter { employee in
//                    employee.name.lowercased().contains(query.lowercased()) || employee.surname.lowercased().contains(query.lowercased())
//                }
//        } else {
//            presentedEmployees = employees.sorted(by: sortEmployees).filter(filterEmployees)
//        }
//        withAnimation {
//            state = noData ? .empty : .loaded
//        }
    }
    
    func filterEmployees(_ track: Track) -> Bool {
        true
//        filteringOptions.isEmpty ? true : filteringOptions.contains(employee.departmentName)
    }
    
    func sortEmployees(_ first: Track, _ second: Track) -> Bool {
            first.name < second.name
        
    }
}

// MARK: - Public extensions
extension SearchViewModel {
    @Sendable
    func pullToRefresh() {
        fetchEmployees()
    }
    
    func accountButtonTapped() {
        onDidTapProfileButton.send()
    }
    
    func filterButtonTapped() {
        isFilterPresented.toggle()
    }
    
    func sortingButtonTapped() {
        isSortPresented.toggle()
    }
    
    func filteringOptionSelected(_ option: String) {
        if filteringOptions.contains(option) {
            filteringOptions.removeAll(where: { $0 == option })
        } else {
            filteringOptions.append(option)
        }
        filteringOptionsSelected.send()
    }
    
    func sortingOptionSelected(_ option: EmployeeSort) {
        if sortingOption != option {
            sortingOption = option
        }
        sortingOptionSelected.send()
    }
    
    func trackRowSelected(_ employee: Track) {
//        onDidTapEmployee.send(employee)
    }
}
