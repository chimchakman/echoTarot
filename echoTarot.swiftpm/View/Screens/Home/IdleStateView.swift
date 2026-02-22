import SwiftUI

struct IdleStateView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // Title
                Image("homeText")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .accessibilityLabel("에코 타로")
                    .padding(.horizontal, 30)
                    
                
                Spacer()
            }
            
            VStack {
                
                Spacer()
                
                // Table image
                Image("table")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .frame(maxHeight: 800)
                    .accessibilityHidden(true)
                    .padding(.horizontal, 20)
                    .padding(.top, 100)
                
                Spacer()

                
            }
            
            VStack {
                
                Spacer()
                
                // Spread selector
//                Button(action: {
//                    viewModel.changeSpread()
//                }) {
//                    HStack {
//                        Image(systemName: viewModel.selectedSpread == .oneCard ? "1.circle.fill" : "3.circle.fill")
//                        Text(viewModel.selectedSpread.koreanName)
//                    }
//                    .font(.title3)
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 24)
//                    .padding(.vertical, 12)
//                    .background(Color.indigo.opacity(0.6))
//                    .cornerRadius(20)
//                }
//                .accessibilityLabel("스프레드: \(viewModel.selectedSpread.koreanName)")
//                .accessibilityHint("탭하여 변경")
//                .padding(.vertical, 20)
                
                Spacer()
                
                // Start button
                Text("화면을 탭하여 시작")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 90)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.startReading()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("에코 타로. \(viewModel.selectedSpread.koreanName) 스프레드")
            .accessibilityHint("탭하여 타로 리딩 시작")
        }
    }
}
