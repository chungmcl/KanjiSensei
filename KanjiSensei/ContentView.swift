//
//  ContentView.swift
//  KanjiSensei
//
//  Created by Micheal Chung on 6/11/21.
//

import SwiftUI
import URLImage

struct ContentView: View {
    @State private var defaultViewSetID: UUID = UUID()
    
    @StateObject public var wordSetList: WordSets = WordSetFileManager.appStateWordSets
    @State private var selectedSet: UUID? = nil
    @State public var hanzi: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    // Use sidebar title as a NavigationLink to default view -- janky but don't know what else to do for now
                    NavigationLink(destination: DefaultView(), tag: self.defaultViewSetID, selection: self.$selectedSet) {
                        Text("My Sets")
                            .font(Font.system(size: 25, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                    }
                    .disabled(true)
                    
                    Spacer()
                    
                    Button(action: {
                        self.addNewSet()
                    }) {
                        Text("New Set")
                            .foregroundColor(Color.gray)
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                ForEach(wordSetList.wordSets, id: \.id) { wordSet in
                    NavigationLink(
                        destination: WordSetView(wordSetList: wordSetList, wordSet: wordSet, hanzi: self.$hanzi),
                        tag: wordSet.id, selection: self.$selectedSet) {
                        Text(wordSet.name)
                    }
                    .contextMenu {
                        Button {
                            self.deleteSet(uuid: wordSet.id)
                        } label: {
                            Text("Delete")
                        }
                    }
                }
                .onMove(perform: moveWordSet)
                
            }
            .listStyle(SidebarListStyle())
            
            DefaultView()
            
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .toolbar {
            Button("Kanji/Hanzi") {
                self.hanzi.toggle()
            }
        }
    }
    
    private func moveWordSet(from source: IndexSet, to destination: Int) {
        self.wordSetList.wordSets.move(fromOffsets: source, toOffset: destination)
    }
    
    private func addNewSet() {
        self.wordSetList.wordSets.append(WordSet(name: "New Set"))
        
        // Janky but don't know how else to fix bug with sidebar title
        // getting highlighted upon first new set. Can remove without major issue
        if (self.wordSetList.wordSets.count == 1) {
            self.selectedSet = self.wordSetList.wordSets.last!.id
        }
    }
    
    private func deleteSet(uuid: UUID) {
        self.wordSetList.wordSets.removeAll { wordSet in
            return wordSet.id == uuid
        }
        if self.wordSetList.wordSets.count > 0 {
            self.selectedSet = self.wordSetList.wordSets.last!.id
        }
        else {
            self.selectedSet = self.defaultViewSetID
        }
    }
}

struct DefaultView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("勉強しましょう！")
                    .font(Font.system(size: 40, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                Spacer()
            }
            Spacer()
        }
    }
}
