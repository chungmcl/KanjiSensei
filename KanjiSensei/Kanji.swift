//
//  KanjiScraper.swift
//  KanjiLearner
//
//  Created by Micheal Chung on 7/30/20.
//  Copyright © 2020 chungmcl. All rights reserved.
//
import Foundation
import SwiftSoup

fileprivate let serverDomainName: String = "50.35.91.65:6969"

class Kanji: Codable {
    public private(set) var kanji: String
    public private(set) var radical: String = "None"
    public private(set) var parts: [String] = [String]()
    public private(set) var variants: [String] = [String]()
    public private(set) var meanings: [String] = [String]()
    public private(set) var kunyomi: [String] = [String]()
    public private(set) var onyomi: [String] = [String]()
    public private(set) var kunyomiReadingCompounds: [String] = [String]()
    public private(set) var onyomiReadingCompounds: [String] = [String]()
    public private(set) var indexInParentWord: Int? = nil
    public var plainStrokeOrderDiagramUrl: URL? {
        get {
            return URL(string:
                        "http://\(serverDomainName)/kanjiPlain/\(self.kanji).png"
                        .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        }
    }
    public var contrastStrokeOrderDiagramUrl: URL? {
        get {
            return URL(string:
                    "http://\(serverDomainName)/kanjiContrast/\(self.kanji).png"
                        .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        }
    }
    public var spectrumStrokeOrderDiagramUrl: URL? {
        get {
            return URL(string:
                    "http://\(serverDomainName)/kanjiSpectrum/\(self.kanji).png"
                        .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        }
    }
    
    private init(kanji: Character) {
        self.kanji = String(kanji)
    }
    
    // Get Kanji objects representing all Kanji in kanjiPhrase
    public static func getKanjiFromPhrase(kanjiPhrase: String) -> [Kanji] {
        var getFromJisho: [Kanji] = [Kanji]()
        
        var idx: Int = 0
        for char in kanjiPhrase {
            if Kanji.charIsKanji(char: char) {
                let kanjiToAdd = Kanji(kanji: char)
                kanjiToAdd.indexInParentWord = idx
                getFromJisho.append(kanjiToAdd)
            }
            idx += 1
        }
        
        var kanjiToReturn: [Kanji] = [Kanji]()
        
        JishoScraper.scrapeAndLoadKanjiData(kanjiToLoad: getFromJisho)
        kanjiToReturn.append(contentsOf: getFromJisho)
        
        return kanjiToReturn
    }
    
    public static func charIsKanji(char: Character) -> Bool {
        return (String(char).range(of: "\\p{Han}", options: .regularExpression) != nil)
    }
    
    public static func stringHasKanji(string: String) -> Bool {
        for char in string {
            if (Kanji.charIsKanji(char: char)) {
                return true
            }
        }
        return false
    }
    
    // For Kanji object serialization
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.kanji = try container.decode(String.self, forKey: .kanji)
        self.radical = try container.decode(String.self, forKey: .radical)
        self.parts = try container.decode([String].self, forKey: .parts)
        self.variants = try container.decode([String].self, forKey: .variants)
        self.meanings = try container.decode([String].self, forKey: .meanings)
        self.kunyomi = try container.decode([String].self, forKey: .kunyomi)
        self.onyomi = try container.decode([String].self, forKey: .onyomi)
        self.kunyomiReadingCompounds = try container.decode([String].self,
                                                            forKey: .kunyomiReadingCompounds)
        self.onyomiReadingCompounds = try container.decode([String].self,
                                                           forKey: .onyomiReadingCompounds)
        self.indexInParentWord = try container.decode(Int?.self, forKey: .indexInParentWord)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(kanji, forKey: .kanji)
        try container.encode(radical, forKey: .radical)
        try container.encode(parts, forKey: .parts)
        try container.encode(variants, forKey: .variants)
        try container.encode(meanings, forKey: .meanings)
        try container.encode(kunyomi, forKey: .kunyomi)
        try container.encode(onyomi, forKey: .onyomi)
        try container.encode(kunyomiReadingCompounds, forKey: .kunyomiReadingCompounds)
        try container.encode(onyomiReadingCompounds, forKey: .onyomiReadingCompounds)
        try container.encode(indexInParentWord, forKey: .indexInParentWord)
    }
    // END: For Kanji object serialization
    
    private enum CodingKeys: CodingKey {
        case kanji
        case radical
        case parts
        case variants
        case meanings
        case kunyomi
        case onyomi
        case kunyomiReadingCompounds
        case onyomiReadingCompounds
        case strokeOrderDiagramUrl
        case indexInParentWord
    }
    
    // Jisho.org webscraper that fills in data for given Kanji from Jisho.org
    private class JishoScraper {
        
        public static func scrapeAndLoadKanjiData(kanjiToLoad: [Kanji]) -> Void {
            var urlParameterString: String = ""
            for kanji in kanjiToLoad {
                urlParameterString += String(kanji.kanji)
            }
            
            let html = self.getHtml(url: "https://jisho.org/search/\(urlParameterString)#kanji")
            do {
                
                let pageHtml: Document = try SwiftSoup.parse(html)
                
                // Obtain all kanjis that were successfully searched and returned from jisho.org
                var foundKanji = [Character]()
                let kanjiElements = try pageHtml.getElementsByClass("character")
                for kanji in kanjiElements {
                    try foundKanji.append(contentsOf: kanji.text())
                }
                
                // If successfully got all the kanji searched for
                if (kanjiToLoad.count == foundKanji.count) {
                    // Get each section of data for each individual kanji
                    let kanjiDetailElements: Elements = try pageHtml.getElementsByClass("kanji details")
                    
                    for (idx, detailElement) in kanjiDetailElements.enumerated() {
                        let currentKanjiReference: Kanji = kanjiToLoad[idx]
                        
                        self.getRadicalPartsVariants(kanjiDetailElement: detailElement, kanjiToLoad: currentKanjiReference)
                        self.getMeanings(kanjiDetailElement: detailElement, kanjiToLoad: currentKanjiReference)
                        self.getKunAndOnYomi(kanjiDetailElement: detailElement, kanjiToLoad: currentKanjiReference)
                    }
                }
            }
            catch {
                print("KanjiScraper.getKanjiData -- Error: HTML does not seem to be valid, or SwiftSoup error")
            }
        }
        
        private static func getRadicalPartsVariants(kanjiDetailElement: Element, kanjiToLoad: Kanji) -> Void {
            do {
                let radicalAndPartDataElements: Elements = try kanjiDetailElement.getElementsByClass("radicals")
                let radicalAndPartDataString: String = try radicalAndPartDataElements.text()
                
                let radical: String = String (
                    radicalAndPartDataString [
                        radicalAndPartDataString.range(of: "Radical:")!.upperBound ..< radicalAndPartDataString.range(of: "Parts:")!.lowerBound
                    ]
                ).trimmingCharacters(in: .whitespacesAndNewlines)
                
                let parts: [String] = String (
                    radicalAndPartDataString [
                        radicalAndPartDataString.range(of: "Parts:")!.upperBound ..< radicalAndPartDataString.endIndex
                    ]
                ).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
                
                let variantsDataElements: Elements = try kanjiDetailElement.getElementsByClass("dictionary_entry variants")
                
                // Not all kanji have variants
                if (variantsDataElements.count > 0) {
                    let variantsDataString: String = try variantsDataElements.text()
                    let variants: [String] = String (
                        variantsDataString [
                            variantsDataString.range(of: "Variants:")!.upperBound ..< variantsDataString.endIndex
                        ]
                    ).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
                    // Some kanji are incorrectly given the "Variants" section while not actually containing
                    // any variants -- e.g. 上 and 下
                    if (variants[0] != "") {
                        kanjiToLoad.variants = variants
                    }
                }
                
                kanjiToLoad.radical = radical
                kanjiToLoad.parts = parts
                // Leave kanjiToLoad.variants as empty list if kanji doesn't contain variants
            }
            catch {
                print("Error in getRadicalAndParts")
            }
        }
        
        private static func getMeanings(kanjiDetailElement: Element, kanjiToLoad: Kanji) -> Void {
            do {
                let mainMeaningsElement: Elements = try kanjiDetailElement.getElementsByClass("kanji-details__main-meanings")
                let mainMeanings: [String] = try mainMeaningsElement.text().components(separatedBy: ", ")
                kanjiToLoad.meanings = mainMeanings
            }
            catch {
                print("Error in getMeanings")
            }
        }
        
        private static func getKunAndOnYomi(kanjiDetailElement: Element, kanjiToLoad: Kanji) -> Void {
            do {
                let mainReadingsElement: Element = try kanjiDetailElement.getElementsByClass("kanji-details__main-readings").first()!
                let subElements: Elements = try mainReadingsElement.getAllElements()
                
                if (subElements.hasClass("dictionary_entry kun_yomi")) {
                    getYomi(kanjiDetailElement: kanjiDetailElement, mainReadingsElement: mainReadingsElement,
                            yomiToParse: Yomi.kunyomi, kanjiToLoad: kanjiToLoad)
                }
                
                if (subElements.hasClass("dictionary_entry on_yomi")) {
                    getYomi(kanjiDetailElement: kanjiDetailElement, mainReadingsElement: mainReadingsElement,
                    yomiToParse: Yomi.onyomi, kanjiToLoad: kanjiToLoad)
                }
            }
            catch {
                print("Error in getKunAndOnYomi")
            }
        }
        
        private static func getYomi(kanjiDetailElement: Element, mainReadingsElement: Element, yomiToParse: Yomi, kanjiToLoad: Kanji) {
            do {
                var mainReadingsClass: String
                var occurencesToReplace: String
                var elementMatchingText: String
                if (yomiToParse == Yomi.kunyomi) {
                    mainReadingsClass = "dictionary_entry kun_yomi"
                    occurencesToReplace = "Kun: "
                    elementMatchingText = "Kun reading compounds"
                }
                else {
                    mainReadingsClass = "dictionary_entry on_yomi"
                    occurencesToReplace = "On: "
                    elementMatchingText = "On reading compounds"
                }
                
                // Get yomis
                let yomiData: Elements = try mainReadingsElement.getElementsByClass(mainReadingsClass)
                let yomi: [String] = try yomiData.text().replacingOccurrences(of: occurencesToReplace, with: "").components(separatedBy: "、 ")
                
                // Get yomi readings
                let yomiReadingsElement: Elements = try kanjiDetailElement.getElementsMatchingOwnText(elementMatchingText)
                var readingCompounds: [String] = [String]() // Default to no reading compounds
                if (yomiReadingsElement.count > 0) { // If there are reading compounds
                    let readingCompoundsElement: Element = try yomiReadingsElement.first()!.nextElementSibling()!
                    readingCompounds = try readingCompoundsElement.html().components(separatedBy: "\n")
                    for i in readingCompounds.indices {
                        readingCompounds[i] = readingCompounds[i]
                            .replacingOccurrences(of: "<li>", with: "")
                            .replacingOccurrences(of: "</li>", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
                
                // Load yomis and their readings into Kanji
                if (yomiToParse == Yomi.kunyomi) {
                    kanjiToLoad.kunyomi.append(contentsOf: yomi)
                    kanjiToLoad.kunyomiReadingCompounds = readingCompounds
                }
                else {
                    kanjiToLoad.onyomi.append(contentsOf: yomi)
                    kanjiToLoad.onyomiReadingCompounds = readingCompounds
                }
            }
            catch {
                print("Error in getYomi")
            }
        }
        
        private enum Yomi {
            case kunyomi
            case onyomi
        }

        // TO DO: Write async to avoid blocking
        private static func getHtml(url: String) -> String {
            guard let myURL = URL(string: url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!) else {
                print("KanjiScraper.getHtml -- Error: \(url) doesn't seem to be a valid URL")
                return ""
            }

            do {
                let html = try String(contentsOf: myURL, encoding: .utf8)
                return html
            } catch let error {
                print("KanjiScraper.getHtml -- Error: \(error)")
                return ""
            }
        }
    }
}

