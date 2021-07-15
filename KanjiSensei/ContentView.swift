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
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    // Use Title bar as a NavigationLink to default view -- janky but don't know what else to do for now
                    NavigationLink(destination: DefaultView(), tag: self.defaultViewSetID, selection: self.$selectedSet) {
                        Text("My Sets")
                            .font(Font.system(size: 25, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                    }.disabled(true)
                    
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
                        destination: WordSetView(wordSetList: wordSetList, wordSet: wordSet),
                        tag: wordSet.id, selection: self.$selectedSet) {
                        Text(wordSet.name)
                    }
                    .contextMenu {
                        Button {
                            self.deleteSet(setID: wordSet.id)
                        } label: {
                            Text("Delete")
                        }
                    }
                }
                
            }
            .listStyle(SidebarListStyle())
            
            DefaultView()
            
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        //.toolbar {
        //    Button("Button") {
        //
        //    }
        //}
    }
    
    private func addNewSet() {
        self.wordSetList.wordSets.append(WordSet(name: "New Set"))
    }
    
    private func deleteSet(setID: UUID) {
        self.wordSetList.wordSets.removeAll { wordSet in
            return wordSet.id == setID
        }
        self.selectedSet = self.defaultViewSetID
    }
}

struct DefaultView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("こんにちは")
                    .font(Font.system(size: 40, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                Spacer()
            }
            Spacer()
        }
    }
}
