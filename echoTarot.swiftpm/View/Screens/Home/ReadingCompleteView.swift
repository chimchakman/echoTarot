import SwiftUI

struct ReadingCompleteView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("리딩이 저장되었습니다")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("기록 탭에서 확인할 수 있습니다")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            // New reading button
            Button(action: {
                viewModel.reset()
            }) {
                Text("새로운 리딩 시작")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
            .accessibilityLabel("새로운 리딩 시작")
            .accessibilityHint("탭하여 처음으로 돌아가기")
        }
        .padding()
        .onAppear {
            HapticService.shared.success()
        }
    }
}
