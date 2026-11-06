import SwiftUI

/// メモの一覧と追加
struct ContentView: View {
    @Bindable var store: MemoStore
    @State private var draft = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("メモを追加", text: $draft)
                        Button("追加") {
                            store.add(draft)
                            draft = ""
                        }
                        .disabled(draft.isEmpty)
                    }
                }
                ForEach(store.memos) { memo in
                    VStack(alignment: .leading) {
                        Text(memo.text)
                        Text(memo.createdAt, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete(perform: store.remove)
            }
            .navigationTitle("メモ")
        }
    }
}
