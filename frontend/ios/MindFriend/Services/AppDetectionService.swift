import Foundation
import UIKit

class AppDetectionService {
    static let shared = AppDetectionService()
    
    // Common social media and productivity apps with their URL schemes
    private let commonApps: [(name: String, bundleId: String, icon: String, isSystemApp: Bool)] = [
        ("Contacts", "com.apple.MobileAddressBook", "person.crop.circle.fill", true),
        ("Instagram", "com.instagram.exclusivegram", "camera.fill", false),
        ("Facebook", "com.facebook.Facebook", "person.2.fill", false),
        ("Twitter", "com.twitter.Twitter", "bubble.left.fill", false),
        ("TikTok", "com.zhiliaoapp.musically", "video.fill", false),
        ("YouTube", "com.google.ios.youtube", "play.rectangle.fill", false),
        ("Snapchat", "com.toyopagroup.picaboo", "camera.viewfinder", false),
        ("WhatsApp", "net.whatsapp.WhatsApp", "message.fill", false),
        ("Reddit", "com.reddit.Reddit", "globe", false),
        ("Pinterest", "com.pinterest.Pinterest", "pin.fill", false),
        ("LinkedIn", "com.linkedin.LinkedIn", "briefcase.fill", false),
        ("Spotify", "com.spotify.client", "music.note", false),
        ("Netflix", "com.netflix.Netflix", "play.tv.fill", false),
        ("Discord", "com.hammerandchisel.discord", "bubble.left.and.bubble.right.fill", false),
        ("Telegram", "ph.telegra.Telegraph", "paperplane.fill", false),
        ("Tumblr", "com.tumblr.Tumblr", "text.bubble.fill", false)
    ]
    
    func getInstalledApps() -> [InstalledApp] {
        var installedApps: [InstalledApp] = []
        
        for app in commonApps {
            if app.isSystemApp || canOpenApp(bundleId: app.bundleId) {
                installedApps.append(InstalledApp(
                    name: app.name,
                    bundleId: app.bundleId,
                    icon: app.icon
                ))
            }
        }
        
        return installedApps
    }
    
    private func canOpenApp(bundleId: String) -> Bool {
        guard let url = URL(string: "\(bundleId)://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}

struct InstalledApp: Identifiable {
    let id = UUID()
    let name: String
    let bundleId: String
    let icon: String
} 