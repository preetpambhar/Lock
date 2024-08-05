//
//  LockView.swift
//  Lock
//
//  Created by Preet Pambhar on 2024-08-05.
//

import SwiftUI

struct LockView<Content: View>: View {
    //Lock Properties
    var lockType: LocKType
    var lockPin: String
    var isEnable: Bool
    var lockWhenAppGoesBackground: Bool = true
    @ViewBuilder var content: Content
    var body: some View {
        GeometryReader {
            let size =  $0.size
            
            content.frame(width: size.width, height: size.height)
            if isEnable{
                ZStack{
                    if lockType == .both || lockType == .biometric{
                        Rectangle()
                    } else {
                        //Custome number pad to type view lock pin
                    }
                }
                .ignoresSafeArea()
            }
        }
    }
    
    //Number pin view
    @ViewBuilder
    func NumberPadPinView() -> some View{
        
    }
    
    //Lock Type
    enum LocKType: String{
        case biometric = "Bio Mertric Auth"
        case number = "Custom Number Lock"
        case both = "First perference will be biometric, and if it's not available, it will go for number lock"
    }
}

#Preview {
    ContentView()
}
