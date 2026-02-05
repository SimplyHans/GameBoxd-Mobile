//
//  ContentView.swift
//  GameBoxd
//
//  Created by Hussein on 2026-02-05.
//

import SwiftUI

struct ContentView: View {
    @State private var text = "Hello, World!"
    
    var body: some View {
        
        
        ZStack {
            AppBackground{
                
                VStack {
                    Text("Hello, World!")
                    
                    CardView{
                        Text("Hello, World!")
                            .foregroundStyle(Color.white)
                        Image(systemName: "house")
                            .foregroundStyle(Color.white)
                        
                        
                        
                    }
                    PrimaryButton(title:"Hello"){}
                    AppTextField(placeholder: "Email", text: $text)
                        
                        
                    
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
    
}

