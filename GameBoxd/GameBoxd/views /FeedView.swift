//
//  FeedView.swift
//  GameBoxd
//
//  Created by Hussein on 2026-02-05.
//

import Foundation
import SwiftUI

struct FeedView: View {
    var body: some View {
        ZStack {
            AppBackground{
                
                
              
                    
                ScrollView(.horizontal, showsIndicators: false){
                    
                    HStack{
                        
                        CardView(){
                            Image("Image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                        
                        CardView(){
                            Image("Image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                        CardView(){
                            Image("Image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                        CardView(){
                            Image("Image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                        CardView(){
                            Image("Image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                    }
                }
                
                
                
            }
        }
    }
}

#Preview {
    FeedView()
}
