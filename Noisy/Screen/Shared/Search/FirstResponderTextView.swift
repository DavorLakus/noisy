//
//  FirstResponderTextView.swift
//  Noisy
//
//  Created by Davor Lakus on 17.07.2023..
//

import SwiftUI

struct FirstResponderTextView: UIViewRepresentable {

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var didBecomeFirstResponder = false

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? .empty
            }
        }
    }

    @Binding var text: String
    var isFirstResponder: Binding<Bool>
    var placeholder = String.Dictionary.searchBarPlaceholder
    
    func makeUIView(context: UIViewRepresentableContext<FirstResponderTextView>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.font = UIFont(name: "Poppins-Regular", size: 16)
        textField.textColor = UIColor(Color.gray700)
        textField.placeholder = placeholder
        textField.backgroundColor = .clear
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }

    func makeCoordinator() -> FirstResponderTextView.Coordinator {
        return Coordinator(text: $text)
    }

    func updateUIView(_ textField: UITextField, context: UIViewRepresentableContext<FirstResponderTextView>) {
        textField.text = text
        textField.placeholder = placeholder
        
        if isFirstResponder.wrappedValue {
            DispatchQueue.main.async {
                textField.becomeFirstResponder()
            }
            context.coordinator.didBecomeFirstResponder = true
        } else {
            DispatchQueue.main.async {
                textField.resignFirstResponder()
            }
        }
    }
}
