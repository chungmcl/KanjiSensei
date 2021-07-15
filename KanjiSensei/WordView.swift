//
//  WordView.swift
//  KanjiSensei
//
//  Created by Micheal Chung on 7/5/21.
//
import SwiftUI
import URLImage

struct WordView: View {
    @State public var word: Word
    
    @State private var selectedTokenIdx: Int = 0
    @State private var kanjiTokenIndicesIdx: Int = 0
    @State private var kanjiOffset: Int = 0
    
    var body: some View {
        Spacer()
        VStack {
            TokensView(word: self.$word, selectedTokenIdx: self.$selectedTokenIdx, kanjiTokenIndicesIdx: self.$kanjiTokenIndicesIdx, kanjiOffset: self.$kanjiOffset)
            
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
                
                
                
                ZStack {
                    
                    Rectangle().fill(Color.white)
                        .cornerRadius(40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                //.stroke(Color.gray, lineWidth: 4)
                        )
                    
                    URLImage(self.word.tokens[self.selectedTokenIdx].kanji[self.kanjiOffset].spectrumStrokeOrderDiagramUrl!) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    }
                    .frame(width: 500.0, height: 500.0)
                
                }
                .frame(width: 500.0, height: 500.0)
                .cornerRadius(40)
                
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
        }
        Spacer()
    }
    
    private func prevKanji() {
        if (self.kanjiOffset > 0) {
            self.kanjiOffset -= 1
        }
        else {
            self.kanjiTokenIndicesIdx = (self.word.kanjiTokenIndices.count + self.kanjiTokenIndicesIdx - 1) % self.word.kanjiTokenIndices.count
            self.selectedTokenIdx = self.word.kanjiTokenIndices[self.kanjiTokenIndicesIdx]
            self.kanjiOffset = self.word.tokens[self.selectedTokenIdx].kanji.count - 1
        }
    }
    
    private func nextKanji() {
        if (self.kanjiOffset < self.word.tokens[self.selectedTokenIdx].kanji.count - 1) {
            self.kanjiOffset += 1
        }
        else {
            self.kanjiOffset = 0
            self.kanjiTokenIndicesIdx = (self.kanjiTokenIndicesIdx + 1) % self.word.kanjiTokenIndices.count
            self.selectedTokenIdx = self.word.kanjiTokenIndices[self.kanjiTokenIndicesIdx]
        }
    }
    
    //private func getWord() {
    //    do {
    //        self.word = try Word(string: self.wordToAdd)
    //        self.kanjiTokenIndicesIdx = self.word.kanjiTokenIndices[0]
    //        self.selectedTokenIdx = self.word.kanjiTokenIndices[self.kanjiTokenIndicesIdx]
    //    }
    //    catch {
    //        print("Fail")
    //    }
    //}
}

struct TokensView: View {
    @Binding var word: Word
    @Binding var selectedTokenIdx: Int
    @Binding var kanjiTokenIndicesIdx: Int
    @Binding var kanjiOffset: Int
    
    var body: some View {
        HStack {
            ForEach(self.word.tokens, id: \.id) { token in
                Button(action: {
                    self.kanjiOffset = 0
                    self.selectedTokenIdx = token.parentIdx
                    self.kanjiTokenIndicesIdx = self.word.kanjiTokenIndices.firstIndex(of: token.parentIdx)!
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
