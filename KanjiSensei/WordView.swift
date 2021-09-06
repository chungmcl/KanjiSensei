//
//  WordView.swift
//  KanjiSensei
//
//  Created by Micheal Chung on 7/5/21.
//
import SwiftUI
import URLImage

struct WordView: View {
    @State private var word: Word
    @State private var selectedTokenIdx: Int
    @State private var kanjiTokenIndicesIdx: Int
    @State private var kanjiOffset: Int
    
    init(word: Word) {
        self.word = word
        if (word.kanjiTokenIndices.count > 0) {
            self.selectedTokenIdx = word.kanjiTokenIndices.first!
            self.kanjiTokenIndicesIdx = 0
            self.kanjiOffset = 0
        }
        else {
            self.selectedTokenIdx = -1
            self.kanjiTokenIndicesIdx = -1
            self.kanjiOffset = -1
        }
    }
    
    var body: some View {
        Spacer()
        HStack(alignment: .bottom, spacing: 30) {
            VStack {
                TokensView(word: self.$word, selectedTokenIdx: self.$selectedTokenIdx, kanjiTokenIndicesIdx: self.$kanjiTokenIndicesIdx, kanjiOffset: self.$kanjiOffset)
                // Only try to show stroke order diagram area if the word actually contains kanji
                if (self.word.kanjiTokenIndices.count > 0) {
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
                            
                            VLine().stroke(style: StrokeStyle(lineWidth: 1, dash: [5])).foregroundColor(Color.black)
                            HLine().stroke(style: StrokeStyle(lineWidth: 1, dash: [5])).foregroundColor(Color.black)
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
            }
            
            if (self.word.kanjiTokenIndices.count > 0) {
                KanjiInfoView(word: self.$word, selectedTokenIdx: self.$selectedTokenIdx, kanjiTokenIndicesIdx: self.$kanjiTokenIndicesIdx, kanjiOffset: self.$kanjiOffset)
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
}

struct KanjiInfoView: View {
    @Binding public var word: Word
    @Binding public var selectedTokenIdx: Int
    @Binding public var kanjiTokenIndicesIdx: Int
    @Binding public var kanjiOffset: Int
    
    private var selectedKanji: Kanji { return self.word.tokens[self.selectedTokenIdx].kanji[self.kanjiOffset] }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(self.selectedKanji.kanji).font(.system(size: 20, weight: .semibold, design: .default))
            
            Text(self.stringListToCommaString(stringList: self.selectedKanji.meanings)).font(.system(size: 20, weight: .regular, design: .default))
            HStack(alignment: .center, spacing: 30) {
                VStack(alignment: .leading) {
                    
                    Text("Kunyomi").font(.system(size: 20, weight: .bold, design: .default))
                    ForEach(self.selectedKanji.kunyomi, id: \.self) { kunyomi in
                        Text(kunyomi).font(.system(size: 20, weight: .regular, design: .default))
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    
                    Text("Onyomi").font(.system(size: 20, weight: .bold, design: .default))
                    
                    ForEach(self.selectedKanji.onyomi, id: \.self) { onyomi in
                        Text(onyomi).font(.system(size: 20, weight: .regular, design: .default))
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: 400, maxHeight: 550)
        //.padding()
        //.overlay(
        //    RoundedRectangle(cornerRadius: 7)
        //        .stroke(Color.gray, lineWidth: 1)
        //)
    }
    
    private func stringListToCommaString(stringList: [String]) -> String {
        var commaString: String = ""
        for i in 0 ..< stringList.count - 1 {
            commaString += "\(stringList[i]), "
        }
        if stringList.count > 0 {
            commaString += stringList.last!
        }
        return commaString
    }
}

struct TokensView: View {
    @Binding public var word: Word
    @Binding public var selectedTokenIdx: Int
    @Binding public var kanjiTokenIndicesIdx: Int
    @Binding public var kanjiOffset: Int
    
    var body: some View {
        HStack {
            ForEach(self.word.tokens, id: \.id) { token in
                Button(action: {
                    self.kanjiOffset = 0
                    self.selectedTokenIdx = token.parentIdx
                    self.kanjiTokenIndicesIdx = self.word.kanjiTokenIndices.firstIndex(of: token.parentIdx)!
                }) {
                    VStack {
                        if (token.kanji.count > 0) {
                            // Furigana of word token
                            Text(token.pronunciation)
                                .font((token.kanji.count > 0) ?
                                Font.system(size: 15, weight: .semibold, design: .default) :
                                Font.system(size: 15, weight: .ultraLight, design: .default)
                            )
                        }
                        else {
                            // Empty space with same size as other furigana if token doesn't contain kanji
                            Text("")
                                .font((token.kanji.count > 0) ?
                                Font.system(size: 15, weight: .semibold, design: .default) :
                                Font.system(size: 15, weight: .ultraLight, design: .default)
                            )
                        }
                        
                        // Word token
                        Text(token.string)
                            .font((token.kanji.count > 0) ?
                            Font.system(size: 45, weight: .bold, design: .default) :
                            Font.system(size: 45, weight: .ultraLight, design: .default)
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

// Credit for line code to @kazi.munshimun and @Nikaaner on StackOverflow
// Original post: https://stackoverflow.com/questions/58526632/swiftui-create-a-single-dashed-line-with-swiftui
struct VLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        }
    }
}

struct HLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}

