import SwiftUI

struct TabsView: View {
    var body: some View {
        
        
        ZStack{
            AppBackground{
                
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }

                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }

                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                    LogView()
                        .tabItem {
                            Label("Log", systemImage: "arrow.2.circlepath.circle")
                        }
                }
                
            }
        }
        
    }
}




#Preview {
    TabsView()
   
}
