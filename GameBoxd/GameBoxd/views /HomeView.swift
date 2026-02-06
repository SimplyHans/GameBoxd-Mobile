//
//  HomeView.swift
//  GameBoxd
//
//  Created by Hussein on 2026-02-05.
//

import Foundation
import SwiftUI

struct HomeView: View {
    
   @State private var userName:String = "Hanson"
    @State private var gameName:String = "Fortnit"
    
    
    var body: some View {
        
        ZStack {
            AppBackground{
                
               
                
                ScrollView(.vertical){
                    
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("Welcom Back, " + userName)
                            .foregroundStyle(Color(.white))
                            .font(Font.title.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)

                        Text("Featured Game")
                            .foregroundStyle(Color(.white))
                            .font(Font.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                        
                        
                        GeometryReader { proxy in
                            ZStack {
                                CardView() {
                                    Image("Image")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .clipped()
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            lineWidth: 3
                                        )
                                )
                                
                            }
                                
                        }
                        .frame(height: 220)
                        .padding(.horizontal)
                        
                        
                        
                                
                        
                        Text("Treding")
                            .foregroundStyle(Color(.white))
                            .font(Font.title2.bold())
                            .padding(.top, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            
                            
                            HStack(spacing: 16) {
                                ZStack {
                                    CardView() {
                                        Image("Image")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .clipped()
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 3
                                            )
                                    )

                                    Text(gameName)
                                        .font(.headline.bold())
                                        .foregroundStyle(.white)
                                        .shadow(radius: 3)
                                }
                                .frame(width: 180, height: 140)
                                .padding(.horizontal, 20)
                                
                                ZStack {
                                    CardView {
                                        Image("Image")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .clipped()
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 3
                                            )
                                    )

                                    Text(gameName)
                                        .font(.headline.bold())
                                        .foregroundStyle(.white)
                                        .shadow(radius: 3)
                                }
                                .frame(width: 180, height: 140)
                                .padding(.horizontal, 20)
                                
                                ZStack {
                                    CardView() {
                                        Image("Image")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .clipped()
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 3
                                            )
                                    )
                                        
                                    Text(gameName)
                                        .font(.headline.bold())
                                        .foregroundStyle(.white)
                                        .shadow(radius: 3)
                                }
                                .frame(width: 180, height: 140)
                                .padding(.horizontal, 20)
                                
                            }
                            .frame( height:140)
                            .padding(.horizontal)
                            
                            
                            
                            
                        }
                        
                        
                        Text("Recommended")
                            .foregroundStyle(Color(.white))
                            .font(Font.title2.bold())
                            .padding(.top, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            
                            
                            HStack(spacing: 16) {
                                ZStack {
                                    CardView() {
                                        Image("Image")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .clipped()
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 3
                                            )
                                    )

                                    Text(gameName)
                                        .font(.headline.bold())
                                        .foregroundStyle(.white)
                                        .shadow(radius: 3)
                                }
                                .frame(width: 180, height: 140)
                                .padding(.horizontal, 20)
                                
                                ZStack {
                                    CardView {
                                        Image("Image")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .clipped()
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 3
                                            )
                                    )

                                    Text(gameName)
                                        .font(.headline.bold())
                                        .foregroundStyle(.white)
                                        .shadow(radius: 3)
                                }
                                .frame(width: 180, height: 140)
                                .padding(.horizontal, 20)
                                
                                ZStack {
                                    CardView() {
                                        Image("Image")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .clipped()
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 3
                                            )
                                    )
                                        
                                    Text(gameName)
                                        .font(.headline.bold())
                                        .foregroundStyle(.white)
                                        .shadow(radius: 3)
                                }
                                .frame(width: 180, height: 140)
                                .padding(.horizontal, 20)
                                
                            }
                            .frame( height:140)
                            .padding(.horizontal)
                            
                            
                            
                            
                        }
                        
                        
                        Text("Recently played")
                            .foregroundStyle(Color(.white))
                            .font(Font.title2.bold())
                            .padding(.top, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            
                            
                            HStack(spacing: 16) {
                                ZStack {
                                    CardView() {
                                        Image("Image")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .clipped()
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 3
                                            )
                                    )

                                    Text(gameName)
                                        .font(.headline.bold())
                                        .foregroundStyle(.white)
                                        .shadow(radius: 3)
                                }
                                .frame(width: 180, height: 140)
                                .padding(.horizontal, 20)
                                
                                ZStack {
                                    CardView {
                                        Image("Image")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .clipped()
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 3
                                            )
                                    )

                                    Text(gameName)
                                        .font(.headline.bold())
                                        .foregroundStyle(.white)
                                        .shadow(radius: 3)
                                }
                                .frame(width: 180, height: 140)
                                .padding(.horizontal, 20)
                                
                                ZStack {
                                    CardView() {
                                        Image("Image")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .clipped()
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 3
                                            )
                                    )
                                        
                                    Text(gameName)
                                        .font(.headline.bold())
                                        .foregroundStyle(.white)
                                        .shadow(radius: 3)
                                }
                                .frame(width: 180, height: 140)
                                .padding(.horizontal, 20)
                                
                            }
                            .frame( height:140)
                            .padding(.horizontal)
                            
                            
                            
                            
                        }
                            
                        
                        
                    }
                    
                    
                }
               
                
                
                }
            
                
                
             
              
                
            }
        
        
        
    }
    
}

#Preview {
    HomeView()
   
}

