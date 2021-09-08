//
//  WordSetFileManager.swift
//  KanjiSensei
//
//  Created by Micheal Chung on 7/15/21.
//

import Foundation

// Class to serialize/save & deserialize/load app state
class WordSetFileManager {
    public private(set) static var appStateWordSets: WordSets = loadWordSets()
    
    private static var encoder: JSONEncoder = { return JSONEncoder() }()
    private static var decoder: JSONDecoder = { return JSONDecoder() }()
    
    // /Users/chungmcl/Library/Containers/chungmcl.KanjiSensei/Data/wordsets/
    public static var wordSetsPath: String {
        get {
            let directoryString = NSHomeDirectory() + "/wordsets/"
            do {
                try FileManager.default.createDirectory(atPath: directoryString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
            return directoryString + "wordSets.json"
        }
    }
    
    public static func saveWordSets() {
        do {
            let encoded = try self.encoder.encode(self.appStateWordSets)
            FileManager.default.createFile(atPath: wordSetsPath,
                                           contents: encoded,
                                           attributes: nil)
        }
        catch {
            print("Failed to save word sets")
        }
    }
    
    private static func loadWordSets() -> WordSets {
        do {
            if FileManager.default.fileExists(atPath: wordSetsPath) {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: wordSetsPath))
                let wordSets = try self.decoder.decode(WordSets.self, from: jsonData)
                return wordSets
            }
            else {
                return WordSets()
            }
        } catch {
            print(error)
            return WordSets()
        }
    }
}
