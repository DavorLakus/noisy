//
//  View+Extension.swift
//  Noisy
//
//  Created by Davor Lakus on 31.05.2023..
//

import SwiftUI
import Combine

extension View {
    func tab(name: String, icon: Image) -> some View {
        Label { Text(name) } icon: { icon }
    }
    
    func loadingIndicator(isPresented: Binding<Bool>) -> some View {
        ZStack {
            self
            SpinnerView()
                .zIndex(isPresented.wrappedValue ? 1 : -1)
        }
    }
    
    @ViewBuilder
    func refreshGesture(offset: GestureState<CGFloat>, action: @escaping () -> Void) -> some View {
        ZStack {
            self
                .offset(y: offset.wrappedValue)
                .gesture(
                    DragGesture()
                        .updating(offset) { value, state, _ in
                            withAnimation {
                                state = min(value.translation.height, 100)
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 50 {
                                withAnimation {
                                    action()
                                }
                            }
                        }
                )
                .animation(.easeInOut, value: offset.wrappedValue > 0)
            
            VStack {
                ProgressView()
                    .padding()
                    .scaleEffect(x: 0.5 + offset.wrappedValue / 100, y: 0.5 + offset.wrappedValue / 100)
                    .opacity(offset.wrappedValue / 100)
                Spacer()
            }
        }
    }
    
    func alert<AlertContent: View>(isPresented: Binding<Bool>, alert: @escaping (Binding<Bool>) -> AlertContent) -> some View {
        self
            .modifier(AlertModifier(isPresented: isPresented, alertContent: alert))
    }
    
    func tabBarHidden(_ visibility: Binding<Visibility?>) -> some View {
        self
            .modifier(TabBarHidden(visibility: visibility))
    }
    
    func zStackTransition(_ transition: AnyTransition) -> some View {
        self
            .modifier(ZStackTransition(transition: transition))
    }
    
    @ViewBuilder
    func mintBadge(isPresented: Bool) -> some View {
        ZStack {
            if isPresented {
                ZStack(alignment: .topTrailing) {
                    self
                    Group {
                        Rectangle()
                            .fill(Color.appBackground)
                            .frame(width: 10, height: 10)
                        Circle()
                            .fill(Color.green200)
                            .frame(width: 8, height: 8)
                    }
                    .offset(x: 1.5, y: -1.5)
                }
                .transition(.opacity)
            } else {
                self
                    .transition(.opacity)
            }
        }
    }
    
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    func readEdgeInsets(onChange: @escaping (EdgeInsets) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: EdgeInsetsPreferenceKey.self, value: geometry.safeAreaInsets)
            }
        )
        .onPreferenceChange(EdgeInsetsPreferenceKey.self, perform: onChange)
    }
    
    @ViewBuilder
    func cardBackground(backgroundColor: Color = .cardBackground, borderColor: Color = .gray50, cornerRadius: CGFloat = Constants.cornerRadius, hasShadow: Bool = true, isHidden: Bool = false) -> some View {
        if isHidden {
            self
        } else {
            self
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: 1)
                )
                .shadow(color: hasShadow ? .gray300 : .clear,
                        radius: 6, x: 1, y: 4)
        }
    }
    
    @ViewBuilder
    func cardBackground(gradient: LinearGradient, borderColor: Color = .gray50, cornerRadius: CGFloat = Constants.cornerRadius, hasBorder: Bool = false, hasShadow: Bool = true, isHidden: Bool = false) -> some View {
        if isHidden {
            self
        } else {
            self
                .background(gradient)
                .cornerRadius(cornerRadius)
                .overlay {
                    if hasBorder {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: 1)
                    }
                }
                .shadow(color: hasShadow ? .gray300 : .clear,
                        radius: 6, x: 1, y: 4)
        }
    }
    
    func bottomBorder() -> some View {
        overlay {
            VStack(spacing: .zero) {
                Spacer()
                Color.gray100
                    .frame(height: 1)
            }
        }
    }
    
    func navigationBarBottomBorder() -> some View {
        Color.gray300
            .padding(.top, 3.5)
            .frame(height: 4)
            .frame(maxWidth: .infinity)
            .background(Color.appBackground)
            .zIndex(5)
    }
    
    @ViewBuilder
    func dynamicSheet<SheetContent: View>(isPresented: Binding<Bool>, content: @escaping () -> SheetContent) -> some View {
        self.modifier(ModalSheetModifier(isPresented: isPresented, sheetContent: content))
    }
    
    func dynamicModalSheet<SheetContent: View>(isPresented: Binding<Bool>, content: @escaping () -> SheetContent) -> some View {
        self.modifier(SheetModifier(isPresented: isPresented, sheetContent: content))
    }
    
    func highlightedText(_ text: String, query: String) -> some View {
        guard !text.isEmpty && !query.isEmpty else { return Text(text) }
        
        var result: Text?
        let components = text.lowercased().components(separatedBy: query.lowercased())
        let indicesOfQuery = text.lowercased().ranges(of: query.lowercased())
        
        components.indices.forEach { index in
            if let range = text.lowercased().range(of: components[index].lowercased()) {
                let currentSubstring = String(text[range])
                
                if let currentResult = result {
                    result = currentResult + Text(currentSubstring)
                } else {
                    result = Text(currentSubstring)
                }
            } else if result == nil {
                result = Text(String.empty)
            }
            
            if index != components.count - 1,
               let currentResult = result {
                result = currentResult + Text(text[indicesOfQuery[index]])
                    .foregroundColor(.mint)
                    .font(.nunitoSemiBold(size: 14))
            }
        }
        return result ?? Text(text)
    }
}

struct LoadImage: View {
    let url: URL?
    let placeholder: Image?
    
    init(url: URL?, placeholder: Image? = nil) {
        self.url = url
        self.placeholder = placeholder
    }
    
    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable()
        } placeholder: {
            if let placeholder {
                placeholder.resizable()
            } else {
                Image.Home.profile.resizable()
            }
        }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

private struct EdgeInsetsPreferenceKey: PreferenceKey {
    static var defaultValue = EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: .zero)
    static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {}
}

extension View {
    func swipeAction(title: String, gradient: [Color], height: CGFloat, offset: Binding<CGFloat>, action: @escaping () -> Void) -> some View {
        ZStack {
            HStack {
                Spacer()
                
                Text(title)
                    .font(.nunitoBold(size: 14))
                    .foregroundColor(.appBackground)
                    .padding(10)
                    .frame(height: height)
            }
            .cardBackground(gradient: LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing), hasShadow: false)
            
            self
                .offset(x: offset.wrappedValue)
                .simultaneousGesture(dragGesture(offset: offset, action: action))
        }
    }
    
    func toast(isPresented: Binding<Bool>, message: String, alignment: Alignment = .bottom, duration: TimeInterval = 2.5) -> some View {
        ZStack(alignment: alignment) {
            self
            if isPresented.wrappedValue {
                Text(message)
                    .font(.nunitoBold(size: 18))
                    .foregroundColor(.white)
                    .padding(12)
                    .cardBackground(backgroundColor: .green200)
                    .zStackTransition(.slide)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
                    }
            }
        }
    }
    
    func dragGesture(offset: Binding<CGFloat>, action: @escaping () -> Void) -> some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .local)
            .onChanged { dragValue in
                if dragValue.translation.width < 0 {
                    withAnimation {
                        offset.wrappedValue = dragValue.translation.width
                    }
                }
            }
            .onEnded { dragValue in
                if dragValue.translation.width < -100 {
                    withAnimation {
                        offset.wrappedValue = -300
                    }
                    action()
                } else {
                    withAnimation {
                        offset.wrappedValue = .zero
                    }
                }
            }
    }
}

struct ModalSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @State var isShadowPresented = false
    @State var height: CGFloat = .zero
    let sheetContent: () -> SheetContent
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
                .onChange(of: isPresented) { isSheetPresented in
                    if isSheetPresented {
                        withAnimation {
                            isShadowPresented = true
                        }
                    } else {
                        isShadowPresented = false
                    }
                }
            
            if isShadowPresented {
                Color.alertShadow
                    .opacity(0.7)
                    .ignoresSafeArea()
                    .zStackTransition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            isPresented = false
                        }
                    }
            }
            
            if isPresented {
                sheetContent()
                    .offset(y: isPresented ? height : .zero)
                    .zStackTransition(.asymmetric(insertion: .move(edge: .bottom), removal: .offset(y: 500)))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                withAnimation(.easeInOut) {
                                    height = min(150, max(-150, value.translation.height))
                                }
                            }
                            .onEnded {
                                if $0.translation.height > 100 {
                                    withAnimation(.easeInOut) {
                                        isPresented = false
                                    }
                                } else {
                                    withAnimation(.easeInOut) {
                                        height = .zero
                                    }
                                }
                            }
                    )
                    .padding(.top, Constants.cornerRadius)
                    .background {
                        Color.appBackground.cornerRadius(Constants.cornerRadius)
                            .offset(y: height > 0 ? height : .zero)
                    }
                    .padding(.top, -Constants.cornerRadius)
                    .cornerRadius(Constants.cornerRadius)
                    .padding(.top, Constants.cornerRadius)
                    .onDisappear { height = .zero }
            }
        }
//        .adaptsToKeyboard()
        .ignoresSafeArea(edges: .bottom)
    }
}

struct AlertModifier<AlertContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @State var isShadowPresented = false
    let alertContent: (Binding<Bool>) -> AlertContent
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            content
                .onChange(of: isPresented) { isAlertPresented in
                    if isAlertPresented {
                        withAnimation {
                            isShadowPresented = true
                        }
                    } else {
                        isShadowPresented = false
                    }
                }
            
            if isShadowPresented {
                Color.alertShadow
                    .opacity(0.7)
                    .ignoresSafeArea()
                    .zStackTransition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            isPresented = false
                        }
                    }
            }
            
            if isPresented {
                alertContent($isPresented)
                    .zStackTransition(.slide)
            }
        }
        .ignoresSafeArea(edges: .all)
    }
}

struct SheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @State var detents = Set<PresentationDetent>()
    let sheetContent: () -> SheetContent
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                sheetContent()
                    .readSize { detents = [.height($0.height)] }
                    .presentationDetents(detents)
            }
    }
}

struct AdaptsToKeyboard: ViewModifier {
    @State var currentHeight: CGFloat = 0
    @State var edgeInsets: EdgeInsets = .init()
    
    func body(content: Content) -> some View {
        content
            .readEdgeInsets { edgeInsets = $0 }
            .padding(.bottom, self.currentHeight)
            .onAppear(perform: {
                NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillShowNotification)
                    .merge(with: NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillChangeFrameNotification))
                    .compactMap { notification in
                        withAnimation(.easeOut(duration: 0.16)) {
                            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                        }
                    }
                    .map { rect in
                        print(rect.height)
                        return rect.height - 200
                    }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
                
                NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillHideNotification)
                    .compactMap { _ in
                        CGFloat.zero
                    }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
            })
    }
}

extension View {
    func adaptsToKeyboard() -> some View {
        return modifier(AdaptsToKeyboard())
    }
}
