//
//  HomeView.swift
//  GameBoxd
//
//  Created by Hussein on 2026-02-05.
//

import Foundation
import SwiftUI

struct RegisterPageView: View {
    
    @State var  EmailField = ""
    @State var  PasswordField = ""
    
    var body: some View {
        
        ZStack {
            AppBackground{
                
               
               
                
            
                VStack{
                    Spacer()
                    Spacer()
                    
                    HStack{
                        Text("Full Name:")
                            .foregroundStyle(.white)
                            .font(.title2)
                        Spacer()
                    }
                
                    AppTextField(placeholder: "Full Name", text:$EmailField)
                    
                    HStack{
                        Text("Email")
                            .foregroundStyle(.white)
                            .font(.title2)
                        Spacer()
                    }
                
                    AppTextField(placeholder: "Email", text:$EmailField)
                    
                    
                    HStack{
                        Text("Password")
                            .foregroundStyle(.white)
                            .font(.title2)
                        Spacer()
                    }
                
                    AppTextField(placeholder: "Password", text:$PasswordField)
                        
                        
                    
                    HStack{
                        Text("Renter password")
                            .foregroundStyle(.white)
                            .font(.title2)
                        Spacer()
                    }
                
                    AppTextField(placeholder: "Password", text:$PasswordField)
                        .padding(.bottom, 30)
                    
                    
                    
                    
                    PrimaryButton(title: "Register") {}
                    
                    ButtonWithNoBackGround(title: "Already have an account ?") {
                        
                    }
                        
                    Spacer()
                    Spacer()
                    
                    
                }
                .padding()
                
                
             
              
                
            }
        }
        
        
    }
    
}

#Preview {
    RegisterPageView()
   
}
