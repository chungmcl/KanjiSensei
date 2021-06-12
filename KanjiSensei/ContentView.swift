//
//  ContentView.swift
//  KanjiSensei
//
//  Created by Micheal Chung on 6/11/21.
//

import SwiftUI

struct ContentView: View {
    @State private var wordToAdd: String = ""
    @State private var word: Word? = nil
    
    var body: some View {
        Spacer()
        VStack {
            if (self.word != nil) {
                HStack{
                    ForEach(word!.tokens, id: \.id) { token in
                        Button(action: {
                            // Jump to kanji of token
                        }) {
                            VStack {
                                // Furigana of word token
                                Text(token.pronunciation)
                                    .font(
                                        (token.kanji.count > 0) ?
                                            Font.system(size: 10, weight: .heavy, design: .default) :
                                            Font.system(size: 10, weight: .ultraLight, design: .default)
                                )
                                // Word token
                                Text(token.string)
                                    .font(
                                        (token.kanji.count > 0) ?
                                        Font.system(size: 30, weight: .heavy, design: .default) :
                                        Font.system(size: 30, weight: .ultraLight, design: .default)
                                )
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        // Disabled if does not contain a kanji
                        .disabled(token.kanji.count <= 0);
                    }
                }
            }
            TextField("Word to add...", text: self.$wordToAdd, onCommit: {
                getWord()
            })
            .frame(width: 500)
        }
    }
    
    private func getWord() {
        do {
            self.word = try Word(string: self.wordToAdd)
        }
        catch {
            print("Fail")
        }
    }
}



//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
