//
//  ContentView.swift
//  Lock
//
//  Created by Preet Pambhar on 2024-08-05.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LockView(lockType: .biometric, lockPin: "0320", isEnable: true) {
            VStack(spacing: 15){
                Image(systemName: "globe")
                    .imageScale(.large)
                Text("Hello World")
            }
        }
    }
}

#Preview {
    ContentView()
}
