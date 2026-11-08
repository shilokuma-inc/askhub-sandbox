import SwiftUI

/// メモの一覧と追加
struct ContentView: View {
    @Bindable var store: MemoStore
    @State private var draft = ""
    @State private var draftColor: MemoColor?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("メモを追加", text: $draft)
                        Button("追加") {
                            store.add(draft, color: draftColor)
                            draft = ""
                            draftColor = nil
                        }
                        .disabled(draft.isEmpty)
                    }
                    Picker("色", selection: $draftColor) {
                        Text(MemoColor.noneName).tag(MemoColor?.none)
                        ForEach(MemoColor.allCases, id: \.self) { color in
                            Label {
                                Text(color.name)
                            } icon: {
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(color.swatch)
                            }
                            .tag(Optional(color))
                        }
                    }
                    .pickerStyle(.menu)
                }
                ForEach(store.memos) { memo in
                    HStack {
                        if let color = memo.color {
                            Circle()
                                .fill(color.swatch)
                                .frame(width: 12, height: 12)
                                .accessibilityLabel(color.name)
                        }
                        VStack(alignment: .leading) {
                            Text(memo.text)
                            Text(memo.createdAt, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .contextMenu {
                        colorMenu(for: memo)
                    }
                }
                .onDelete(perform: store.remove)
                .onMove(perform: store.move)
            }
            .navigationTitle("メモ")
            .toolbar {
                EditButton()
            }
        }
    }

    /// メモの色を変える・外すボタン。いま付いている色にはチェックを付ける
    @ViewBuilder
    private func colorMenu(for memo: Memo) -> some View {
        Button {
            store.setColor(nil, for: memo.id)
        } label: {
            if memo.color == nil {
                Label(MemoColor.noneName, systemImage: "checkmark")
            } else {
                Text(MemoColor.noneName)
            }
        }
        ForEach(MemoColor.allCases, id: \.self) { color in
            Button {
                store.setColor(color, for: memo.id)
            } label: {
                if memo.color == color {
                    Label(color.name, systemImage: "checkmark")
                } else {
                    Text(color.name)
                }
            }
        }
    }
}

extension MemoColor {
    /// 色なしを表す名前
    static let noneName = "色なし"

    /// 画面に出す名前
    var name: String {
        switch self {
        case .red: "赤"
        case .blue: "青"
        case .green: "緑"
        case .yellow: "黄"
        case .purple: "紫"
        }
    }

    /// 画面に出す色
    var swatch: Color {
        switch self {
        case .red: .red
        case .blue: .blue
        case .green: .green
        case .yellow: .yellow
        case .purple: .purple
        }
    }
}
