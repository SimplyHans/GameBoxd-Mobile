//
//  SearchView.swift
//  GameBoxd
//
//  Created by Hussein on 2026-02-05.
//

import Foundation
import SwiftUI

struct SearchView: View {
    var body: some View {
        ZStack {
            
            AppBackground{
                
                ScrollView(.vertical, showsIndicators: false){
                    
                    VStack{
                        
                        CardView(){
                            Image("Image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 400, height: 200)
                        }
                        
                        CardView(){
                            Image("Image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 400, height: 200)
                        }
                        CardView(){
                            Image("Image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 400, height: 200)
                        }
                        CardView(){
                            Image("Image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 400, height: 200)
                        }
                        CardView(){
                            Image("Image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 400, height: 200)
                        }
                    }
                }
                
            }
        }
    }
}

#Preview {
    SearchView()
}
