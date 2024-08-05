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
    var forgotPin:() -> () = {
        
    }
    //View Properties
    @State private var pin: String = ""
    var body: some View {
        GeometryReader {
            let size =  $0.size
            
            content.frame(width: size.width, height: size.height)
            if isEnable{
                Rectangle()
                    .ignoresSafeArea()
                ZStack{
                    if lockType == .both || lockType == .biometric{
                        
                    } else {
                        //Custome number pad to type view lock pin
                        NumberPadPinView()
                    }
                }
            }
        }
    }
    
    //Number pin view
    @ViewBuilder
    func NumberPadPinView() -> some View {
        VStack(spacing: 15){
            Text("Enter pin")
                .font(.title.bold())
                .frame(maxWidth: .infinity)
            HStack(spacing: 10){
                ForEach(0..<4, id: \.self){index in
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 50, height: 55, alignment: .center)
                    //Showing pin in each box with help of index
                        .overlay{
                            //safe check
                            if pin.count > index {
                                let index  = pin.index(pin.startIndex, offsetBy: index)
                                let string = String(pin[index])
                                Text(string)
                                    .font(.title.bold())
                                    .foregroundStyle(.black)
                                
                            }
                        }
                }
            }
            .padding(.top, 15)
            .overlay(alignment: .bottomTrailing, content: {
                Button("Forgot pin?", action: forgotPin)
                    .font(.callout)
                    .foregroundStyle(.white)
                    .offset(y: 40)
            })
            .frame(maxHeight: .infinity)
            
            //Custome Number Pad
            GeometryReader{ _ in
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3), content: {
                    ForEach(1...9, id: \.self) {number in
                        Button(action: {
                            //Adding Number to pin
                            //Max Limit 4
                            if pin.count <= 4 {
                                pin.append("\(number)")
                            }
                        }, label: {
                            Text("\(number)")
                                .font(.title)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .contentShape(.rect)
                        })
                        .tint(.white)
                    }
                    ///0  and back button
                    Button(action: {
                        if !pin.isEmpty{
                            pin.removeLast()
                        }
                    }, label: {
                        Image(systemName: "delete.backward")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .contentShape(.rect)
                    })
                    .tint(.white)
                    Button(action: {
                        if pin.count < 4 {
                            pin.append("0")
                        }
                    }, label: {
                        Text("0")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .contentShape(.rect)
                    })
                    .tint(.white)
                })
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .onChange(of: pin){oldValue, newValue in
                if newValue.count == 4 {
                    ///validate pin
                    if lockPin == pin {
                        print("Unlock")
                    }else{
                        print("Wrong Pin")
                        pin = ""
                    }
                }
            }
        }
        .padding()
        .environment(\.colorScheme, .dark)
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
