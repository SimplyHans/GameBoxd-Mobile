//
//  HomeView.swift
//  GameBoxd
//
//  Created by Hussein on 2026-02-05.
//

import Foundation
import SwiftUI

struct LoginPageView: View {
    
    @State var  EmailField = ""
    @State var  PasswordField = ""
    
    var body: some View {
        
        ZStack {
            AppBackground{
                
               
               
                
            
                VStack{
                    Spacer()
                    Spacer()
                    
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
                        .padding(.bottom, 30)
                    
                    
                    
                    PrimaryButton(title: "Login") {}
                    
                    ButtonWithNoBackGround(title: "Create an account") {
                        
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
    LoginPageView()
   
}
