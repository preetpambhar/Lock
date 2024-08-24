//
//  LockView.swift
//  Lock
//
//  Created by Preet Pambhar on 2024-08-05.
//

import SwiftUI
import LocalAuthentication

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
    @State private var animateField: Bool = false
    @State private var isUnlocked: Bool = false
    @State private var noBioMetricAccess: Bool = false
    //Lock Context
    let context = LAContext()
        //Scene Phase
    @Environment(\.scenePhase) private var phase
    var body: some View {
        GeometryReader {
            let size =  $0.size
            
            content.frame(width: size.width, height: size.height)
            if isEnable && !isUnlocked{
                ZStack{
                    Rectangle()
                        .fill(.black)
                        .ignoresSafeArea()
                    if (lockType == .both && !noBioMetricAccess) || lockType == .biometric{
                        Group{
                            if noBioMetricAccess{
                                Text("Enable biometric authentication is settings to unlock the view")
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                                    .padding(50)
                            }else{
                                ///Bio metric  / pin unlock
                                VStack(spacing: 12){
                                    VStack(spacing: 6){
                                    Image(systemName: "lock")
                                            .font(.largeTitle)
                                        
                                        Text("Tap to unlock")
                                            .font(.caption2)
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
                                    .contentShape(.rect)
                                    .onTapGesture {
                                        unlockView()
                                    }
                                    
                                    if lockType == .both{
                                        Text("Enter Pin")
                                            .frame(width: 100, height: 40)
                                            .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
                                            .contentShape(.rect)
                                            .onTapGesture {
                                                noBioMetricAccess = true
                                            }
                                    }
                                }
                            }
                        }
                    } else {
                        //Custome number pad to type view lock pin
                        NumberPadPinView()
                    }
                }
                .environment(\.colorScheme, .dark)
                .transition(.offset(y: size.height + 100))
            }
        }
        .onChange(of: isEnable, initial: true) { oldValue, newValue in
            if newValue {
                unlockView()
            }
        }
        
        //Loking when apps goes in background
        .onChange(of: phase) { oldValue, newValue in
            if newValue != .active && lockWhenAppGoesBackground{
                isUnlocked = false
                pin = " "
            }
        }
    }
    
    private func unlockView(){
        //checking and unlocking
        Task{
            if isBiometricAvailable && lockType != .number{
                //Requesting biometric unlock
                if let result  = try? await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock the View"), result {
                    print("Unlocked")
                    withAnimation(.snappy,completionCriteria: .logicallyComplete) {
                        isUnlocked = true
                    } completion: {
                        pin = ""
                    }
                }
            }
            
            //No Bio metric permission || Lock type must be set as keypad
            //Update biometric status
            noBioMetricAccess = !isBiometricAvailable
        }
    }
    
    private var isBiometricAvailable: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    //Number pin view
    @ViewBuilder
    private func NumberPadPinView() -> some View {
        VStack(spacing: 15){
            Text("Enter pin")
                .font(.title.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    //Back Button only for both lock type
                    if lockType  == .both && isBiometricAvailable{
                        Button(action: {
                            pin = ""
                            noBioMetricAccess = false
                        }, label: {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .contentShape(.rect)
                        })
                        .tint(.white)
                        .padding((.leading))
                    }
                }
            ///Adding wiggling animation for wrong  password with keyframe animator
            ///
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
            .keyframeAnimator(initialValue: CGFloat.zero, trigger: animateField, content: { content, value in
                content
                    .offset(x: value)
            }, keyframes: { _ in
                CubicKeyframe(30, duration: 0.07)
                CubicKeyframe(-30, duration: 0.07)
                CubicKeyframe(20, duration: 0.07)
                CubicKeyframe(-20, duration: 0.07)
                CubicKeyframe(0, duration: 0.07)
            })
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
                        //print("Unlock")
                        withAnimation(.snappy, completionCriteria: .logicallyComplete){
                            isUnlocked = true
                        } completion: {
                            //Clearing Pin
                            pin = " "
                            noBioMetricAccess = !isBiometricAvailable
                        }
                    }else{
                        //print("Wrong Pin")
                        pin = ""
                        animateField.toggle()
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
