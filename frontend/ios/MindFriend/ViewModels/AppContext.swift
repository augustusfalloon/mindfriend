import Foundation
import SwiftUI
import Combine

class AppContext: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var user: AppUser? = nil
}