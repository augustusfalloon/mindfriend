import SwiftUI

struct JustificationView: View {
    let appName: String
    let onJustificationSubmitted: (String) -> Void
    let onWaitSelected: () -> Void
    
    @State private var justification = ""
    @State private var showingTimer = false
    @State private var remainingTime = 60
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if showingTimer {
                    TimerView(remainingTime: $remainingTime) {
                        dismiss()
                    }
                } else {
                    VStack(spacing: 16) {
                        Text("Accessing \(appName)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Please provide a reason for accessing this app or wait 60 seconds.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                        
                        TextEditor(text: $justification)
                            .frame(height: 100)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2))
                            )
                        
                        Button(action: {
                            showingTimer = true
                            startTimer()
                        }) {
                            Text("Wait 60s")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            onJustificationSubmitted(justification)
                            dismiss()
                        }) {
                            Text("Submit")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(justification.isEmpty ? Color.gray : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(justification.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            })
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer.invalidate()
                dismiss()
            }
        }
    }
}

struct TimerView: View {
    @Binding var remainingTime: Int
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Please wait")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("\(remainingTime)")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.blue)
            
            Text("seconds remaining")
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    JustificationView(
        appName: "Instagram",
        onJustificationSubmitted: { _ in },
        onWaitSelected: {}
    )
} 