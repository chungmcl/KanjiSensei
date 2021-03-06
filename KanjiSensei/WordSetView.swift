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
    @Binding public var hanzi: Bool
    
    @State private var wordToAdd: String = ""
    
    @State private var selectedWord: UUID? = nil
    
    var body: some View {
        VStack {
            TextField("Change Word Set Name", text: self.$wordSet.name, onCommit: {
                // Signal main view's sidebar to update
                self.wordSetList.objectWillChange.send()
                self.unfocusTextField()
            })
            .textFieldStyle(PlainTextFieldStyle())
            .font(Font.system(size: 40, weight: .bold, design: .default))
            .foregroundColor(.primary)
            .padding()
            
            NavigationView {
                VStack {
                    HStack {
                        TextField("Add new word...", text: self.$wordToAdd, onCommit: {
                            self.addNewWord()
                        })
                        Button(action: {
                            self.addNewWord()
                        }) {
                            Text("+")
                        }
                    }
                    
                    List {
                        ForEach(wordSet.set, id: \.id) { word in
                            NavigationLink(destination: WordView(word: word, hanzi: self.$hanzi), tag: word.id, selection: self.$selectedWord) {
                                Text(word.fullString)
                            }
                            .contextMenu {
                                Button {
                                    self.deleteWord(uuid: word.id)
                                } label: {
                                    Text("Delete")
                                }
                            }
                        }
                        .onMove(perform: moveWord)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .listStyle(SidebarListStyle())
                }
                .padding(10)
            }
            
            Spacer()
        }
    }
    
    private func addNewWord() {
        self.unfocusTextField()
        self.wordToAdd = self.wordToAdd.trimmingCharacters(in: .whitespacesAndNewlines)
        if (!self.wordToAdd.isEmpty) {
            self.wordSet.set.append(Word(string: self.wordToAdd))
            WordSetFileManager.saveWordSets()
        }
        self.wordToAdd = ""
    }
    
    private func deleteWord(uuid: UUID) {
        self.wordSet.set.removeAll { word in
            return word.id == uuid
        }
    }
    
    private func moveWord(from source: IndexSet, to destination: Int) {
        self.wordSet.set.move(fromOffsets: source, toOffset: destination)
    }
    
    private func unfocusTextField() {
        DispatchQueue.main.async {
            NSApp.keyWindow?.makeFirstResponder(nil)
        }
    }
}
