import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            RestrictedAppsView()
                .tabItem {
                    Label("Apps", systemImage: "app.badge")
                }
            
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
            
            AccountSettingsView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
        }
    }
}

struct RestrictedAppsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Restricted Apps")) {
                    AppRow(appName: "Instagram", icon: "camera.fill")
                    AppRow(appName: "YouTube", icon: "play.rectangle.fill")
                    AppRow(appName: "TikTok", icon: "video.fill")
                }
            }
            .navigationTitle("Restricted Apps")
        }
    }
}

struct AppRow: View {
    let appName: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(appName)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
    }
}

struct FriendsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Friends")) {
                    FriendRow(name: "John Doe", status: "Active")
                    FriendRow(name: "Jane Smith", status: "Active")
                    FriendRow(name: "Mike Johnson", status: "Inactive")
                }
            }
            .navigationTitle("Friends")
        }
    }
}

struct FriendRow: View {
    let name: String
    let status: String
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(name)
            Spacer()
            Text(status)
                .foregroundColor(status == "Active" ? .green : .gray)
        }
    }
}

struct AccountSettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account Settings")) {
                    NavigationLink(destination: Text("Profile Settings")) {
                        Label("Profile", systemImage: "person.fill")
                    }
                    NavigationLink(destination: Text("Notification Settings")) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    NavigationLink(destination: Text("Privacy Settings")) {
                        Label("Privacy", systemImage: "lock.fill")
                    }
                }
                
                Section {
                    Button(action: {
                        // Logout action
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                            Text("Logout")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Account")
        }
    }
}

#Preview {
    MainTabView()
} 