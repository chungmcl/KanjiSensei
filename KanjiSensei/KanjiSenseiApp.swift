//
//  KanjiSenseiApp.swift
//  KanjiSensei
//
//  Created by Micheal Chung on 6/11/21.
//

import SwiftUI

@main
struct KanjiSenseiApp: App {
    
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            SidebarCommands()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        print("app will terminate")
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        print("app should terminate")
        WordSetFileManager.saveWordSets()
        return NSApplication.TerminateReply.terminateNow
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    //    var window: NSWindow!
    //
    //    func applicationDidFinishLaunching(_ aNotification: Notification) {
    //        // Create the SwiftUI view that provides the window contents.
    //        let contentView = ContentView()
    //
    //        // Create the window and set the content view.
    //        window = NSWindow(
    //            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
    //            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
    //            backing: .buffered, defer: false)
    //        window.center()
    //        window.setFrameAutosaveName("Main Window")
    //        window.contentView = NSHostingView(rootView: contentView)
    //        window.makeKeyAndOrderFront(nil)
    //    }
        
    //    func debugPrint(debug : [Kanji]) {
    //        for kanji in debug {
    //            print(kanji.kanji)
    //            print("Radical: " + kanji.radical)
    //            print("Parts: " + kanji.parts.description)
    //            print("Meanings: " + kanji.meanings.description)
    //            print("Kunyomi: " + kanji.kunyomi.description)
    //            print("Onyomi: " + kanji.onyomi.description)
    //            print("KRC: " + kanji.kunyomiReadingCompounds.description)
    //            print("ORC: " + kanji.onyomiReadingCompounds.description)
    //            print()
    //        }
    //    }
}

