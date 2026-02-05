//
//  HomeView.swift
//  GameBoxd
//
//  Created by Hussein on 2026-02-05.
//

import Foundation
import SwiftUI

struct HomeView: View {
    
    @State var String: String = ""
    
    var body: some View {
        
        ZStack {
            AppBackground{
                
               
               
                
                VStack(spacing: 16) {
                   
                    PrimaryButton(title: "Get Started") { }
                    SeconderyButton(title: "Cancel") {}
                    DeleteButton(title: "Delete") { }
                    AppTextField(placeholder: "Email", text:$String)
                    
                    CardView(){
                        
                        
                          
                        
                        AppTextField(placeholder: "Email", text:$String)
                        
                        PrimaryButton(title: "Get Started") { }
                    }
                    
                    
                    
                    
                }
                .padding()
              
                
            }
        }
        
        
    }
    
}

#Preview {
    HomeView()
   
}
