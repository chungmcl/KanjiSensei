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
        Text(self.wordSet.id.uuidString)
        
        TextField("Change set name...", text: self.$wordSet.name, onCommit: {
            self.wordSetList.objectWillChange.send()
        })
        .frame(width: 500)
    }
}
