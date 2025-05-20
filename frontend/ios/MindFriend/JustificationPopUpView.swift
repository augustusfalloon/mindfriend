// import SwiftUI

// struct JustificationPopupView: View {
//     let appName: String
//     let onJustificationSubmitted: (String) -> Void
//     let onWaitSelected: () -> Void
    
//     @State private var justification = ""
//     @State private var showingTimer = false
//     @State private var remainingTime = 60
//     @Environment(\.dismiss) private var dismiss
    
//     var body: some View {
//         NavigationView {
//             VStack(spacing: 20) {
//                 if showingTimer {
//                     TimerView(remainingTime: $remainingTime) {
//                         dismiss()
//                     }
//                 } else {
//                     VStack(spacing: 16) {
//                         Text("Accessing \(appName)")
//                             .font(.title2)
//                             .fontWeight(.bold)
                        
//                         Text("Please provide a reason for accessing this app or wait 60 seconds.")
//                             .multilineTextAlignment(.center)
//                             .foregroundColor(.gray)
                        
//                         TextEditor(text: $justification)
//                             .frame(height: 100)
//                             .padding(4)
//                             .overlay(
//                                 RoundedRectangle(cornerRadius: 8)
//                                     .stroke(Color.gray.opacity(0.2))
//                             )
                        
//                         HStack(spacing: 20) {
//                             Button(action: {
//                                 showingTimer = true
//                             }) {
//                                 Text("Wait 60s")
//                                     .foregroundColor(.white)
//                                     .frame(maxWidth: .infinity)
//                                     .padding()
//                                     .background(Color.blue)
//                                     .cornerRadius(10)
//                             }
                            
//                             Button(action: {
//                                 onJustificationSubmitted(justification)
//                                 dismiss()
//                             }) {
//                                 Text("Submit")
//                                     .foregroundColor(.white)
//                                     .frame(maxWidth: .infinity)
//                                     .padding()
//                                     .background(Color.green)
//                                     .cornerRadius(10)
//                             }
//                         }
//                     }
//                     .padding()
//                 }
//             }
//             .navigationBarItems(trailing: Button("Cancel") {
//                 dismiss()
//             })
//         }
//     }
// }

// struct TimerView: View {
//     @Binding var remainingTime: Int
//     let onComplete: () -> Void
    
//     var body: some View {
//         VStack(spacing: 20) {
//             Text("Please wait")
//                 .font(.title2)
//                 .fontWeight(.bold)
            
//             Text("\(remainingTime)")
//                 .font(.system(size: 60, weight: .bold))
//                 .foregroundColor(.blue)
            
//             Text("seconds remaining")
//                 .foregroundColor(.gray)
//         }
//     }
// }