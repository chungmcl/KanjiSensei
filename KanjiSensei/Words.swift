//
//  WordDefinitions.swift
//  KanjiLearner
//
//  Created by Micheal Chung on 7/28/20.
//  Copyright © 2020 chungmcl. All rights reserved.
//

import SwiftUI
import Foundation

// Extension of CFRange that defines the max position of the range.
fileprivate extension CFRange {
    var max: CFIndex { return location + length }
}

class Token: Codable, Identifiable, Equatable {
    // START: Stuff for Identifiable
    // Define what it means for two Tokens to be the same
    static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.id == rhs.id
    }
    public private(set) var id = UUID()
    // END: Stuff for Identifiable
    
    let parentIdx: Int
    let string: String
    let range: Range<Int>
    let pronunciation: String
    let kanji: [Kanji]
    
    init(parentIdx: Int, string: String, range: Range<Int>, pronunciation: String, kanji: [Kanji]) {
        self.parentIdx = parentIdx
        self.string = string
        self.range = range
        self.pronunciation = pronunciation
        self.kanji = kanji
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.parentIdx = try container.decode(Int.self, forKey: .parentIdx)
        self.string = try container.decode(String.self, forKey: .string)
        self.range = try container.decode(Range<Int>.self, forKey: .range)
        self.pronunciation = try container.decode(String.self, forKey: .pronunciation)
        self.kanji = try container.decode([Kanji].self, forKey: .kanji)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(parentIdx, forKey: .parentIdx)
        try container.encode(string, forKey: .string)
        try container.encode(range, forKey: .range)
        try container.encode(pronunciation, forKey: .pronunciation)
        try container.encode(kanji, forKey: .kanji)
    }
    
    private enum CodingKeys: CodingKey {
        case parentIdx, string, range, pronunciation, kanji
    }
}

class Word: Codable, Identifiable {
    // START: Stuff for Identifiable
    // Define what it means for two Words to be the same
    static func == (lhs: Word, rhs: Word) -> Bool {
        return lhs.id == rhs.id
    }
    public private(set) var id = UUID()
    // END: Stuff for Identifiable
    
    public let fullString: String
    public private(set) var tokens: [Token] = [Token]()
    public private(set) var kanjiTokenIndices: [Int] = [Int]()
    
    init(string: String) throws {
        self.fullString = string
        self.loadTokenData()
    }
    
    private func loadTokenData() -> Void {
        let text = self.fullString as NSString
        let fullRange: CFRange = CFRangeMake(0, text.length)
        let tokenizer: CFStringTokenizer = CFStringTokenizerCreate(kCFAllocatorDefault,
                                                self.fullString as CFString,
                                                fullRange,
                                                kCFStringTokenizerUnitWord,
                                                Locale(identifier: "ja") as CFLocale)
        
        
        // Scan through the string tokens, appending to result Hiragana transcription and ranges that can't be transcribed.
        var lastPosition: CFIndex = 0
        var i: Int = 0
        while CFStringTokenizerAdvanceToNextToken(tokenizer) != [] {
            let currentRange: CFRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            
            // If currentRange of the text was skipped (unable to tokenize)
            if currentRange.location > lastPosition {
                do {
                    try self.loadMissingRange(i: i, lastPosition: lastPosition, currentRange: currentRange)
                }
                catch {
                    
                }
            }
            
            // Add currentRange to ranges
            self.loadRangeAndPronunciation(i: i, currentRange: currentRange, tokenizer: tokenizer)
            lastPosition = currentRange.max
            i += 1
        }
    }
    
    public func loadRangeAndPronunciation(i: Int, currentRange: CFRange, tokenizer: CFStringTokenizer) {
        let tokenRange: Range<Int> = currentRange.location ..< currentRange.max
        let substringStartIndex = self.fullString.index(self.fullString.startIndex, offsetBy: currentRange.location)
        let substringEndIndex = self.fullString.index(self.fullString.startIndex, offsetBy: currentRange.max)
        let substring = self.fullString[substringStartIndex ..< substringEndIndex]
        
        var pronunciation: String = "???"
        // If pronunciation is generated
        if let latin = CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription) as? String {
            // Convert generated pronunciation (currently in Latin characters) to Hiragana
            pronunciation = latin.applyingTransform(.latinToHiragana, reverse: false) ?? "???"
        }
        let kanji: [Kanji] = Kanji.getKanjiFromPhrase(kanjiPhrase: String(substring))
        self.tokens.append(Token(parentIdx: i, string: String(substring), range: tokenRange, pronunciation: pronunciation, kanji: kanji))
        
        // Load 
        if (kanji.count > 0) {
            self.kanjiTokenIndices.append(self.tokens.count - 1)
        }
    }
    
    private func loadMissingRange(i: Int, lastPosition: Int, currentRange: CFRange) throws {
        let missingRange = CFRange(location: lastPosition, length: currentRange.location - lastPosition)
        let tokenRange: Range<Int> = missingRange.location ..< missingRange.max
        
        guard let substring = CFStringCreateWithSubstring(kCFAllocatorDefault, self.fullString as CFString, missingRange) else {
            throw WordError.pronunciationGenerationError("Pronunciation Generation failed")
        }
        
        // Use question marks in pronunciationResults for untokenizable parts of wordText
        self.tokens.append(Token(parentIdx: i, string: String(substring as Substring), range: tokenRange, pronunciation: "???", kanji: [Kanji]()))
    }
    
    enum WordError: Error {
        case pronunciationGenerationError(String)
    }
}

class WordSet: Identifiable, Equatable, ObservableObject, Codable {
    static func == (lhs: WordSet, rhs: WordSet) -> Bool {
        return lhs.id == rhs.id
    }
    
    public private(set) var id = UUID()
    @Published public var name: String = ""
    @Published public var set: [Word] = [Word]()
    
    init(name: String) {
        self.name = name
        // Test?
        //do { self.set.append(try Word(wordText: "")) }
        //catch {}
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.set = try container.decode([Word].self, forKey: .set)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(set, forKey: .set)
    }
    
    private enum CodingKeys: CodingKey {
        case id, name, set
    }
}

class WordSets: ObservableObject, Codable {
    @Published var wordSets: [WordSet] = [WordSet]()
    
    init() { }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wordSets = try container.decode([WordSet].self, forKey: .wordSets)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(wordSets, forKey: .wordSets)
    }
    
    private enum CodingKeys: CodingKey {
        case wordSets
    }
}

