//
//  DiscoverView.swift
//  Noisy
//
//  Created by Davor Lakus on 08.06.2023..
//

import SwiftUI

enum Seed: CaseIterable, Hashable, Identifiable {
    case acousticness
    case danceability
    case duration
    case energy
    case instrumentalness
    case key
    case liveness
    case loudness
    case mode
    case popularity
    case speechiness
    case tempo
    case timeSignature
    case valence
    
    var id: Int {
        return Self.allCases.firstIndex(of: self) ?? .zero
    }
    
    var name: String {
        switch self {
        case .acousticness:
            return "Acousticness"
        case .danceability:
            return "Danceability"
        case .duration:
            return "Duration"
        case .energy:
            return "Energy"
        case .instrumentalness:
            return "Instrumentalness"
        case .key:
            return "Key"
        case .liveness:
            return  "Liveness"
        case .loudness:
            return  "Loudness"
        case .mode:
            return  "Mode"
        case .popularity:
            return "Popularity"
        case .speechiness:
            return "Speechiness"
        case .tempo:
            return  "Tempo (BPM)"
        case .timeSignature:
            return  "Time signature"
        case .valence:
            return  "Valence"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .acousticness, .danceability, .energy, .instrumentalness, .liveness, .loudness, .mode, .speechiness, .valence:
            return  1.0
        case .duration:
            return 1000.0
        case .key:
            return 11.0
        case .popularity:
            return 100.0
        case .tempo:
            return  200.0
        case .timeSignature:
            return  11.0
        }
    }
    
    var isInt: Bool {
        switch self {
        case .acousticness, .danceability, .energy, .instrumentalness, .liveness, .loudness, .mode, .speechiness, .valence:
            return  false
        case .duration, .key, .popularity, .tempo, .timeSignature:
            return  true
        }
    }
}

struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    
    var body: some View {
        bodyView()
            .toolbar(content: toolbarContent)
    }
}

// MARK: - Body view
extension DiscoverView {
    func bodyView() -> some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                LargeButton(foregroundColor: .appBackground, backgroundColor: .orange400, title: .Discover.manageSeeds, action: viewModel.changeSeedsButtonTapped)
                LargeButton(foregroundColor: .appBackground, backgroundColor: .green500, title: .Discover.discover, action: viewModel.discoverButtonTapped)
                Spacer()
            }
            .padding(Constants.margin)
        }
        .sheet(isPresented: $viewModel.isSeedsSheetPresented) {
            SeedsSheetView(viewModel: viewModel)
        }
    }
}

struct SeedsSheetView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: viewModel.discoverButtonTapped) {
                    Text(String.Discover.done)
                        .foregroundColor(.green500)
                        .font(.nunitoBold(size: 18))
                }
            }
            .padding([.horizontal, .top], Constants.margin)
            ScrollView {
                VStack(alignment: .leading) {
                    Text(String.Discover.seedsTitle)
                        .font(.nunitoBold(size: 18))
                        .foregroundColor(.gray800)
                    Text(String.Discover.seedsSubtitle)
                        .font(.nunitoSemiBold(size: 13))
                        .foregroundColor(.gray500)
                    VStack(alignment: .leading) {
                        Text(String.Discover.currentSelection)
                            .font(.nunitoBold(size: 13))
                            .foregroundColor(.green500)
                        LazyVStack(alignment: .leading) {
                            ForEach(viewModel.seedArtists, id: \.id) {
                                seedCard(title: $0.name, id: $0.id, background: .green200, action: viewModel.artistSeedCardSelected)
                            }
                        }
                        
                        LazyVStack(alignment: .leading) {
                            ForEach(viewModel.seedTracks, id: \.id) {
                                seedCard(title: $0.name, id: $0.id, background: .orange400, action: viewModel.trackSeedCardSelected)
                            }
                        }
                        
                        LazyVStack(alignment: .leading) {
                            ForEach(viewModel.seedGenres, id: \.self) {
                                seedCard(title: $0, id: $0, background: .blue400, action: viewModel.genreSeedCardSelected)
                            }
                        }
                    }
                    Picker(String.Discover.seedsTitle, selection: $viewModel.seedCategory) {
                        ForEach(SeedCategory.allCases, id: \.self) {
                            Text($0.displayName)
                                .font(.nunitoRegular(size: 14))
                        }
                    }
                    SearchBar(isActive: $viewModel.isSearchActive, query: $viewModel.query)
                }
                .padding(.horizontal, Constants.margin)
                
                if viewModel.isSearchActive {
                    LazyVStack {
                        if !viewModel.tracks.isEmpty {
                            tracksSection()
                        }
                        if !viewModel.artists.isEmpty {
                            artistsSection()
                        }
                        if !viewModel.genres.isEmpty {
                            genresSection()
                        }
                    }
                    .padding(.horizontal, Constants.margin)
                } else {
                    LazyVStack {
                        ForEach(Seed.allCases, id: \.id) { seed in
                            ThreePointSliderRow(seed: seed, infoAction: {}, minValue: 0, maxValue: 1, lowerBound: $viewModel.lowerBounds[seed.id], target: $viewModel.targets[seed.id], upperBound: $viewModel.upperBounds[seed.id])
                                .padding(.horizontal, Constants.margin)
                        }
                    }
                    .padding(.vertical, Constants.margin)
                }
            }
        }
    }
}

extension SeedsSheetView {
    @ViewBuilder
    func seedCard(title: String, id: String, background: Color, action: @escaping (String) -> Void) -> some View {
        HStack {
            Text(title)
                .font(.nunitoBold(size: 14))
                .foregroundColor(.gray700)
            Image.Shared.close
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .cardBackground(backgroundColor: background, borderColor: .gray700)
        .onTapGesture {
            action(id)
        }
    }
    
    @ViewBuilder
    func tracksSection() -> some View {
        VStack(alignment: .leading) {
            Text(String.Search.tracks)
                .font(.nunitoBold(size: 14))
                .foregroundColor(.gray600)
            ForEach(Array(viewModel.tracks.enumerated()), id: \.offset) { enumeratedTrack in
                TrackRow(track: enumeratedTrack, isEnumerated: false)
                    .background(.white)
                    .onTapGesture { viewModel.trackRowSelected(enumeratedTrack.element) }
            }
        }
    }
    
    func artistsSection() -> some View {
        VStack(alignment: .leading) {
            Text(String.Search.artists)
                .font(.nunitoBold(size: 14))
                .foregroundColor(.gray600)
            ForEach(Array(viewModel.artists.enumerated()), id: \.offset) { enumeratedArtist in
                ArtistRow(artist: enumeratedArtist, isEnumerated: false)
                    .background(.white)
                    .onTapGesture { viewModel.artistRowSelected(enumeratedArtist.element) }
            }
        }
    }
    
    func genresSection() -> some View {
        VStack(alignment: .leading) {
            Text(String.Search.albums)
                .font(.nunitoBold(size: 14))
                .foregroundColor(.gray600)
            
            ForEach(Array(viewModel.genres), id: \.self) { genre in
                Text(genre)
                    .foregroundColor(.gray700)
                    .font(.nunitoBold(size: 16))
                    .padding(Constants.margin)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .onTapGesture { viewModel.genreRowSelected(genre) }
            }
        }
    }
}

struct LargeButton: View {
    let foregroundColor: Color
    let backgroundColor: Color
    let title: String
    let action: () -> Void
    
    init(foregroundColor: Color, backgroundColor: Color, title: String, action: @escaping () -> Void) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(foregroundColor)
                .font(.nunitoSemiBold(size: 16))
                .frame(maxWidth: .infinity)
        }
        .padding(12)
        .cardBackground(backgroundColor: backgroundColor)
    }
}

struct ThreePointSliderRow: View {
    let seed: Seed
    let infoAction: () -> Void
    var numberFormat: String {
        seed.isInt ? "%d" : "%.2f"
    }
    
    let minValue: Double
    let maxValue: Double
    @Binding var lowerBound: Double
    @Binding var target: Double
    @Binding var upperBound: Double
    
    var lowerBoundString: String { valueToString(lowerBound) }
    var targetString: String { valueToString(target) }
    var upperBoundString: String { valueToString(upperBound) }
    
    @State var isExpanded: Bool = false
    let markRadius: CGFloat = 20
    
    let lowerBoundColor: Color = .red300
    let targetColor: Color = .yellow200
    let upperBoundColor: Color = .orange400
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack {
                Text(seed.name)
                    .foregroundColor(.gray700)
                    .font(.nunitoBold(size: 20))
                
                Button(action: infoAction) {
                    Image.Shared.info.foregroundColor(.green500)
                }
                Spacer()
                
                Image.Shared.chevronDown
                    .rotationEffect(Angle(degrees: isExpanded ? 0 : -90))
            }
            .padding(.bottom, isExpanded ? 12 : .zero)
            .background(.white)
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                HStack {
                    HStack(spacing: .zero) {
                        Text(String.Discover.lowerBound)
                            .foregroundColor(.appBackground)
                            .font(.nunitoBold(size: 12))
                        Text(lowerBoundString)
                            .foregroundColor(lowerBoundColor)
                            .font(.nunitoBold(size: 14))
                    }
                    Spacer()
                    HStack(spacing: .zero) {
                        Text(String.Discover.target)
                            .foregroundColor(.appBackground)
                            .font(.nunitoBold(size: 12))
                        Text(targetString)
                            .foregroundColor(targetColor)
                            .font(.nunitoBold(size: 14))
                    }
                    Spacer()
                    HStack(spacing: .zero) {
                        Text(String.Discover.upperBound)
                            .foregroundColor(.appBackground)
                            .font(.nunitoBold(size: 12))
                        Text(upperBoundString)
                            .foregroundColor(upperBoundColor)
                            .font(.nunitoBold(size: 14))
                    }
                }
                .animation(.none, value: lowerBound)
                .animation(.none, value: target)
                .animation(.none, value: upperBound)
                .padding(markRadius)
                .cardBackground(backgroundColor: .green500, cornerRadius: markRadius * 2)
                .padding(.bottom, 40)
                
                ThreePointSlider(minValue: minValue, maxValue: maxValue, lowerBound: $lowerBound, target: $target, upperBound: $upperBound, minColor: lowerBoundColor, targetColor: targetColor, maxColor: upperBoundColor)
            }
        }
        .padding(Constants.margin)
        .cardBackground()
    }
    
    func valueToString(_ value: Double) -> String {
        if case .duration = seed {
            return TimeInterval(value * seed.multiplier).positionalTime
        } else {
            return String(format: numberFormat, seed.isInt ? Int(value * seed.multiplier) : value)
        }
    }
}

struct ThreePointSlider: View {
    let minValue: Double
    let maxValue: Double
    @Binding var lowerBound: Double
    @Binding var target: Double
    @Binding var upperBound: Double
    
    let fontSize: CGFloat = 12
    var radius: CGFloat { width / 15 }
    var tolerance: CGFloat = 0.09
    let toleranceOffset: CGFloat = 0.01
    
    @State var width: CGFloat = 0
    @State var textWidth: CGFloat = 0
    @State var textHeight: CGFloat = 0
    
    let minColor: Color
    let targetColor: Color
    let maxColor: Color
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            VStack(spacing: 4) {
                HStack(spacing: .zero) {
                    Text(String.Discover.min)
                        .offset(x: lowerBoundOffset() + textWidth / 3, y: -textHeight * 1.5)
                        .gesture(lowerBoundDragGesture())
                        .foregroundColor(.gray500)
                        .font(.nunitoBold(size: fontSize))
                        .readSize {
                            textWidth = $0.width
                            textHeight = $0.height
                        }
                    Text(String.Discover.targetShort)
                        .offset(x: targetOffset(), y: -textHeight * 0.75)
                        .gesture(targetDragGesture())
                        .foregroundColor(.gray500)
                        .font(.nunitoBold(size: fontSize))
                    Text(String.Discover.max)
                        .offset(x: upperBoundOffset() - textWidth / 3)
                        .gesture(upperBoundDragGesture())
                        .foregroundColor(.gray500)
                        .font(.nunitoBold(size: fontSize))
                    Spacer()
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.appBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: 4)
                        .readSize { width = $0.width }
                    
                    HStack(spacing: .zero) {
                        lowerBoundDot()
                            .offset(x: lowerBoundOffset())
                            .gesture(lowerBoundDragGesture())
                        targetDot()
                            .offset(x: targetOffset())
                            .gesture(targetDragGesture())
                        upperBoundDot()
                            .offset(x: upperBoundOffset())
                            .gesture(upperBoundDragGesture())
                        Spacer()
                    }
                }
                .padding(radius / 2)
                .background {
                    RoundedRectangle(cornerRadius: radius)
                        .fill(Color.altGray)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    func lowerBoundOffset() -> CGFloat {
        lowerBound * width
    }
    
    func targetOffset() -> CGFloat {
        target * width - radius  * 1.45
    }
    
    func upperBoundOffset() -> CGFloat {
        upperBound * width - radius * 2.9
    }
    
    func lowerBoundDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    if lowerBound < target - tolerance {
                        lowerBound = (value.location.x - 0.5 * radius) / width
                    } else {
                        lowerBound = target - tolerance
                    }
                    if lowerBound < 0 {
                        lowerBound = 0
                    }
                }
            }
            .onEnded { _ in
                withAnimation {
                    if lowerBound > target - tolerance - toleranceOffset {
                        lowerBound = target - tolerance - toleranceOffset
                    }
                }
            }
    }
    
    func targetDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    if lowerBound < target - tolerance && target + tolerance < upperBound {
                        target = (value.location.x + 1 * radius) / width
                    } else if lowerBound > target - tolerance {
                        target = lowerBound + tolerance
                    } else if upperBound < target + tolerance {
                        target = upperBound - tolerance
                    }
                }
            }
            .onEnded { _ in
                withAnimation {
                    if target < lowerBound + tolerance + toleranceOffset {
                        target = lowerBound + tolerance + toleranceOffset
                    }
                    if target > upperBound - tolerance - toleranceOffset {
                        target = upperBound - tolerance - toleranceOffset
                    }
                    
                }
            }
    }
    
    func upperBoundDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    if upperBound > target + tolerance {
                        upperBound = (value.location.x + 2.5 * radius) / width
                    } else {
                        upperBound = target + tolerance
                    }
                    if upperBound > 1 {
                        upperBound = 1
                    }
                }
            }
            .onEnded { _ in
                withAnimation {
                    if upperBound < target + tolerance + toleranceOffset {
                        upperBound = target + tolerance + toleranceOffset
                    }
                }
            }
    }
    
    func lowerBoundDot() -> some View {
        Dot(fillColor: minColor, radius: radius)
    }
    
    func targetDot() -> some View {
        Dot(fillColor: targetColor, radius: radius)
    }
    
    func upperBoundDot() -> some View {
        Dot(fillColor: maxColor, radius: radius)
    }
}

struct Dot: View {
    let fillColor: Color
    //    let strokeColor: Color
    let radius: CGFloat
    let strokeWidth: CGFloat = 0
    
    init(fillColor: Color, radius: CGFloat = 20) {
        self.fillColor = fillColor
        //        self.strokeColor = strokeColor
        self.radius = radius
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(fillColor)
                .frame(width: radius - strokeWidth, height: radius - strokeWidth)
            
            //            Circle()
            //                .stroke(strokeColor, lineWidth: strokeWidth)
            //                .frame(width: radius, height: radius)
        }
    }
}






















// MARK: - Toolbar
extension DiscoverView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                viewModel.profileButtonTapped()
            } label: {
                AsyncImage(url: URL(string: viewModel.profile?.images.first?.url ?? .empty)) { image in
                    image.resizable()
                } placeholder: {
                    Image.Home.profile.resizable()
                }
                .scaledToFit()
                .cornerRadius(18)
                .frame(width: 36, height: 36)
            }
        }
    }
}

struct DiscoverRequest {
    let limit: Int
    let seedArtists: String
    let seedGenres: String
    let seedTracks: String
    let minAcousticness: Double
    let maxAcousticness: Double
    let targetAcousticness: Double
    let minDanceability: Double
    let maxDanceability: Double
    let targetDanceability: Double
    let minDurationMs: Int
    let maxDurationMs: Int
    let targetDurationMs: Int
    let minEnergy: Double
    let maxEnergy: Double
    let targetEnergy: Double
    let minInstrumentalness: Double
    let maxInstrumentalness: Double
    let targetInstrumentalness: Double
    let minKey: Double
    let maxKey: Double
    let targetKey: Double
    let minLiveness: Double
    let maxLiveness: Double
    let targetLiveness: Double
    let minLoudness: Double
    let maxLoudness: Double
    let targetLoudness: Double
    let minMode: Double
    let maxMode: Double
    let targetMode: Double
    let minPopularity: Double
    let maxPopularity: Double
    let targetPopularity: Double
    let minSpeechiness: Double
    let maxSpeechiness: Double
    let targetSpeechiness: Double
    let minTempo: Double
    let maxTempo: Double
    let targetTempo: Double
    let minTimeSignature: Double
    let maxTimeSignature: Double
    let targetTimeSignature: Double
    let minValence: Double
    let maxValence: Double
    let targetValence: Double
}
