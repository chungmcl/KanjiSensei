//
//  ContentView.swift
//  KanjiSensei
//
//  Created by Micheal Chung on 6/11/21.
//

import SwiftUI
import URLImage

struct ContentView: View {
    @State private var wordToAdd: String = ""
    @State private var word: Word? = nil
    
    @State private var selectedTokenIdx: Int = 0
    @State private var kanjiTokenIndicesIdx: Int = 0
    @State private var kanjiOffset: Int = 0
    
    var body: some View {
        Spacer()
        VStack {
            if (self.word != nil) {
                HStack {
                    
                    Button(action: {
                        self.prevKanji()
                    }) {
                        ZStack {
                            Rectangle().fill(Color.gray);
                            Text(" ← ")
                                .font(Font.system(size: 20, weight: .light, design: .default));
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 40, height: 40)
                    .cornerRadius(7)
                    
                    URLImage(self.word!.tokens[self.selectedTokenIdx].kanji[self.kanjiOffset].spectrumStrokeOrderDiagramUrl!) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    }
                    
                    Button(action: {
                        nextKanji()
                    }) {
                        ZStack {
                            Rectangle().fill(Color.gray);
                            Text(" → ")
                                .font(Font.system(size: 20, weight: .light, design: .default));
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 40, height: 40)
                    .cornerRadius(7)
                    
                    
                }
                TokensView(word: self.$word, selectedTokenIdx: self.$selectedTokenIdx, kanjiTokenIndicesIdx: self.$kanjiTokenIndicesIdx, kanjiOffset: self.$kanjiOffset)
            }
            
            TextField("Word to add...", text: self.$wordToAdd, onCommit: {
                self.getWord()
            })
            .frame(width: 500)
        }
        Spacer()
    }
    
    private func prevKanji() {
        if (self.kanjiOffset > 0) {
            self.kanjiOffset -= 1
        }
        else {
            self.kanjiTokenIndicesIdx = (self.word!.kanjiTokenIndices.count + self.kanjiTokenIndicesIdx - 1) % self.word!.kanjiTokenIndices.count
            self.selectedTokenIdx = self.word!.kanjiTokenIndices[self.kanjiTokenIndicesIdx]
            self.kanjiOffset = self.word!.tokens[self.selectedTokenIdx].kanji.count - 1
        }
    }
    
    private func nextKanji() {
        if (self.kanjiOffset < self.word!.tokens[self.selectedTokenIdx].kanji.count - 1) {
            self.kanjiOffset += 1
        }
        else {
            self.kanjiOffset = 0
            self.kanjiTokenIndicesIdx = (self.kanjiTokenIndicesIdx + 1) % self.word!.kanjiTokenIndices.count
            self.selectedTokenIdx = self.word!.kanjiTokenIndices[self.kanjiTokenIndicesIdx]
        }
    }
    
    private func getWord() {
        do {
            self.word = try Word(string: self.wordToAdd)
            self.selectedTokenIdx = self.word!.kanjiTokenIndices[self.kanjiTokenIndicesIdx]
        }
        catch {
            print("Fail")
        }
    }
}

struct TokensView: View {
    @Binding var word: Word?
    @Binding var selectedTokenIdx: Int
    @Binding var kanjiTokenIndicesIdx: Int
    @Binding var kanjiOffset: Int
    
    var body: some View {
        HStack {
            ForEach(self.word!.tokens, id: \.id) { token in
                Button(action: {
                    self.kanjiOffset = 0
                    self.selectedTokenIdx = token.parentIdx
                    self.kanjiTokenIndicesIdx = self.word!.kanjiTokenIndices.firstIndex(of: token.parentIdx)!
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
}



//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
