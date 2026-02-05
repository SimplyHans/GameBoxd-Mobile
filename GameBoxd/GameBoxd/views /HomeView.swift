//
//  HomeView.swift
//  GameBoxd
//
//  Created by Hussein on 2026-02-05.
//

import Foundation
import SwiftUI

struct HomeView: View {
    
    var body: some View {
        
        ZStack {
            AppBackground{
                
                VStack{
                    Text("Home")
                        .foregroundStyle(Color(.white))
                    
                }
               
                
                VStack(spacing: 16) {
                   
                    PrimaryButton(title: "Get Started") { }
                    PrimaryButton(title: "Longer Title to Test Layout") { }
                }
                .padding()
              
                
            }
        }
        
        
    }
    
}
