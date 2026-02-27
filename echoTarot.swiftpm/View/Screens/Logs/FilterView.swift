import SwiftUI

struct FilterView: View {
    @ObservedObject var viewModel: LogsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Sort") {
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
                    Section("Tag Filter") {
                        Button(action: {
                            viewModel.filterByHashtag(nil)
                        }) {
                            HStack {
                                Text("All")
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
            .navigationTitle("Sort & Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
