//
//  WordSetView.swift
//  KanjiSensei
//
//  Created by Micheal Chung on 7/15/21.
//

import SwiftUI

struct WordSetView: View {
    @ObservedObject public var wordSetList: WordSets
    @ObservedObject public var wordSet: WordSet
    
    var body: some View {
        VStack {
            TextField("Change Word Set Name", text: self.$wordSet.name, onCommit: {
                // Signal main view's sidebar to update
                self.wordSetList.objectWillChange.send()
                // Unfocus from textbox
                DispatchQueue.main.async {
                    NSApp.keyWindow?.makeFirstResponder(nil)
                }
            })
            .textFieldStyle(PlainTextFieldStyle())
            .font(Font.system(size: 40, weight: .bold, design: .default))
            .foregroundColor(.primary)
            .padding()
            
            HStack {
                ScrollView(.vertical) {
                    VStack(spacing: 10) {
                        ForEach(0..<100) {
                            Text("Item \($0)")
                                .font(.title)
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .frame(maxWidth: .infinity)
                
                WordView(word: Word(string: "君の中"))
            }
            
            Spacer()
        }
    }
}
