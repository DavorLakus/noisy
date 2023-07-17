//
//  SearchBar.swift
//  Noisy
//
//  Created by Davor Lakus on 17.07.2023..
//

import SwiftUI

struct SearchBar: View {
    var isActive: Binding<Bool>
    var query: Binding<String>
    
    var body: some View {
        HStack {
            HStack {
                Image.Shared.magnifyingGlass
                
                FirstResponderTextView(text: query, isFirstResponder: isActive)
                    .onTapGesture {
                        withAnimation {
                            isActive.wrappedValue = true
                        }
                    }

                if !query.wrappedValue.isEmpty {
                    Button {
                        withAnimation {
                            query.wrappedValue = String.empty
                        }
                    } label: {
                        Image.Shared.close
                    }
                    .frame(height: 20)
                    .foregroundColor(.gray400)
                }
            }
            .padding(8)
            .background(Color.gray50)
            .cornerRadius(Constants.cornerRadius)
            
            if isActive.wrappedValue {
                Button {
                    withAnimation {
                        isActive.wrappedValue = false
                    }
                } label: {
                    Text(String.cancel)
                }
                .foregroundColor(Color.green300)
            }
        }
    }
}