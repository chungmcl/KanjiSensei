//
//  ContentView.swift
//  KanjiSensei
//
//  Created by Micheal Chung on 6/11/21.
//

import SwiftUI
import URLImage

struct ContentView: View {
    
    var body: some View {
        // Navigation takes two "arguments" in { } -- first is sidebar, second is content view. Otherwise, just
        // declare first "argument" and use a NavigationLink for the content view
        NavigationView {
            
                List {
                    HStack {
                        Text("My Sets")
                            .font(Font.system(size: 25, weight: .bold, design: .default))
                            .foregroundColor(.primary)
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
                    
                    NavigationLink(destination: WordView()) {
                        Text("N2 List")
                    }
                }
                .listStyle(SidebarListStyle())
            
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        //.toolbar {
        //    Button("Button") {
        //
        //    }
        //}
    }
    
    private func addNewSet() {
    
    }
}
