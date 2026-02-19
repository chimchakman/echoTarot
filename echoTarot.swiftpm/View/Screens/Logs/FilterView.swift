import SwiftUI

struct FilterView: View {
    @ObservedObject var viewModel: LogsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("정렬") {
                    ForEach(LogsSortOption.allCases, id: \.self) { option in
                        Button(action: {
                            viewModel.setSortOption(option)
                        }) {
                            HStack {
                                Text(option.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.sortOption == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.indigo)
                                }
                            }
                        }
                        .accessibilityAddTraits(viewModel.sortOption == option ? .isSelected : [])
                    }
                }

                if !viewModel.getAllHashtags().isEmpty {
                    Section("태그 필터") {
                        Button(action: {
                            viewModel.filterByHashtag(nil)
                        }) {
                            HStack {
                                Text("전체")
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.selectedHashtag == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.indigo)
                                }
                            }
                        }

                        ForEach(viewModel.getAllHashtags(), id: \.self) { hashtag in
                            Button(action: {
                                viewModel.filterByHashtag(hashtag)
                            }) {
                                HStack {
                                    Text("#\(hashtag)")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if viewModel.selectedHashtag == hashtag {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.indigo)
                                    }
                                }
                            }
                            .accessibilityAddTraits(viewModel.selectedHashtag == hashtag ? .isSelected : [])
                        }
                    }
                }
            }
            .navigationTitle("정렬 및 필터")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}
