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
        NavigationView {
            NavigationLink(destination: WordView()) {
                Text("Test")
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}
