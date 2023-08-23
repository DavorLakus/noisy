//
//  VisualizeViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 15.08.2023..
//

import SwiftUI
import Combine
import LASwift
import Accelerate

final class VisualizeViewModel: ObservableObject {
    // MARK: Published properties
    @Published var isOptionsSheetPresented = false
    @Published var isToastPresented = false
    @Published var recommendedTracks: [Track]
    @Published var tracksFeatures: [AudioFeatures] = []
    @Published var trackPositions: [CGPoint] = []
    @Published var isTrackInfoPresented = false
    @Published var isSeedInfoAlertPresented = false
    @Published var infoSeed: Seed?

    @Published var tabBarVisibility: Visibility?
    
    // MARK: - Coordinator actions
    let onDidTapArtistButton = PassthroughSubject<Artist, Never>()
    let onDidTapAlbumButton = PassthroughSubject<Album, Never>()
    let onDidTapAddToPlaylist = PassthroughSubject<[Track], Never>()
    let onDidTapBackButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Public properties
    var options: [Option] = []
    var toastMessage: String = .empty
    var selectedTrack: EnumeratedSequence<[Track]>.Element?
    var profile: Profile? {
        guard let profile  = UserDefaults.standard.object(forKey: .Login.profile) as? Data
        else { return nil }
        return try? JSONDecoder().decode(Profile.self, from: profile)
    }
    
    // MARK: - Private properties
    private let discoverService: DiscoverService
    private let musicDetailsService: MusicDetailsService
    private let queueManager: QueueManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(tracks: [Track], discoverService: DiscoverService, musicDetailsService: MusicDetailsService, queueManager: QueueManager) {
        self.discoverService = discoverService
        self.musicDetailsService = musicDetailsService
        self.queueManager = queueManager
        
        recommendedTracks = tracks
        fetchTrackMetrics()
    }
}

// MARK: - Public extension
extension VisualizeViewModel {
    func backButtonTapped() {
        withAnimation {
            tabBarVisibility = .visible
        }
        
        Just(onDidTapBackButton)
            .delay(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink {
                $0.send()
            }
            .store(in: &cancellables)
    }
    
    func trackIconTapped(track: EnumeratedSequence<[Track]>.Element) {
        selectedTrack = track
        withAnimation {
            isTrackInfoPresented = true
        }
    }
    
    func seedInfoTapped(for seed: Seed) {
        infoSeed = seed
        withAnimation {
            isSeedInfoAlertPresented = true
        }
    }
}

// MARK: - Private extension
private extension VisualizeViewModel {
    func fetchTrackMetrics() {
        discoverService.getTrackAudioFeatures(for: recommendedTracks.map(\.id).joined(separator: ","))
            .sink { [weak self] features in
                self?.tracksFeatures = features
                self?.calculateTrackDistances()
            }
            .store(in: &cancellables)
    }
    
    func calculateTrackDistances() {
        let trackPositions = pcaProjection(tracksFeatures.map(\.normalizedValues))
        
        let minX = trackPositions.map(\.x).min() ?? 0.0
        let maxX = trackPositions.map(\.x).max() ?? 1.0
        let minY = trackPositions.map(\.y).min() ?? 0.0
        let maxY = trackPositions.map(\.y).max() ?? 1.0
        
        self.trackPositions = trackPositions.map { point in
            mapValuesToScreenSize(point: point, minX: minX, maxX: maxX, minY: minY, maxY: maxY)
        }
    }
    
    func mapValuesToScreenSize(point: CGPoint, minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) -> CGPoint {
        CGPoint(x: ((point.x - minX) * (1 - -1) / (maxX - minX)) - 1, y: ((point.y - minY) * (1 - -1) / (maxY - minY)) - 1)
    }
    
    func euclideanDistance(_ featuresA: [Double], _ featuresB: [Double]) -> Double {
        precondition(featuresA.count == featuresB.count, "Feature arrays must have the same length")
        
        var sumOfSquaredDifferences: Double = 0.0
        for i in 0..<featuresA.count {
            let difference = featuresA[i] - featuresB[i]
            sumOfSquaredDifferences += difference * difference
        }
        
        return sqrt(sumOfSquaredDifferences)
    }
    
    func pcaProjection(_ data: [[Double]]) -> [CGPoint] {
        let matrix = Matrix(data)
        let covarianceMatrix = calculateCovarianceMatrix(normalizedMatrix: data)
        let eigensystem = eig(Matrix(covarianceMatrix))
        let eigenVectorsMatrix = eigensystem.V.map { $0.map { $0 } }
        let eigenValuesDiagonal = eigensystem.D.map { $0.map { $0 } }
        
        let eigenDiagonal = eigenValuesDiagonal.map { row in
            let diagonalValue = row.filter { $0 != 0 }
            return diagonalValue.isEmpty ? 0.0 : diagonalValue[0]
        }
        let topEigenvectors = extractTopEigenvectors(eigenvectorsMatrix: eigenVectorsMatrix, eigenvaluesDiagonal: eigenDiagonal, numTopComponents: 2)
        let projectionMatrix = Matrix(topEigenvectors).T

        return (matrix * projectionMatrix).map { $0.map { $0 } }.map { CGPoint(x: $0[0], y: $0[1]).round() }
    }
    
    func calculateCovarianceMatrix(normalizedMatrix: [[Double]]) -> [[Double]] {
        let numRows = vDSP_Length(normalizedMatrix.count)
        let numCols = vDSP_Length(normalizedMatrix[0].count)
        
        // Calculate the mean vector
        var meanVector = [Double](repeating: 0.0, count: Int(numCols))
        for col in 0..<numCols {
            vDSP_meanvD(normalizedMatrix.flatMap { $0 }, vDSP_Stride(numCols), &meanVector[Int(col)], numRows)
        }
        
        // Calculate the deviation matrix
        var deviationMatrix = [[Double]]()
        for row in 0..<numRows {
            var deviationRow = [Double]()
            for col in 0..<numCols {
                let deviation = normalizedMatrix[Int(row)][Int(col)] - meanVector[Int(col)]
                deviationRow.append(deviation)
            }
            deviationMatrix.append(deviationRow)
        }
        
        // Calculate the covariance matrix
        var covarianceMatrix = [[Double]](repeating: [Double](repeating: 0.0, count: Int(numCols)), count: Int(numCols))
        for i in 0..<numCols {
            for j in 0..<numCols {
                vDSP_dotprD(deviationMatrix.flatMap { $0 }, vDSP_Stride(numCols), deviationMatrix.flatMap { $0 }, vDSP_Stride(numCols), &covarianceMatrix[Int(i)][Int(j)], numRows)
                covarianceMatrix[Int(i)][Int(j)] /= Double(numRows - 1)
            }
        }
        
        return covarianceMatrix
    }
    
    func extractTopEigenvectors(eigenvectorsMatrix: [[Double]], eigenvaluesDiagonal: [Double], numTopComponents: Int) -> [[Double]] {
        // Create an array of eigenvalue-eigenvector pairs
        let eigenPairs = zip(eigenvaluesDiagonal, eigenvectorsMatrix)
        
        // Sort eigenPairs based on eigenvalues in descending order
        let sortedEigenPairs = eigenPairs.sorted { $0.0 > $1.0 }
        
        // Select the top eigenvectors
        let topEigenvectors = sortedEigenPairs.prefix(numTopComponents).map { $0.1 }
        
        return Array(topEigenvectors)
    }
}
