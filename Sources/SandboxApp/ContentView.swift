import SwiftUI

/// メモの一覧と追加
struct ContentView: View {
    @Bindable var store: MemoStore
    @State private var draft = ""
    @State private var draftColor: MemoColor?
    /// 絞り込みの選択。保存しないので、開くたびに「すべて」から始まる
    @State private var filter: MemoFilter = .all
    /// 検索語。保存しないので、開くたびに空から始まる
    @State private var query = ""
    /// 並べ替えの選択。UserDefaults に保存し、次に開いたときも同じ並べ替えで出す
    @AppStorage(MemoSort.storageKey) private var sort: MemoSort = .manual

    /// 前後の空白を除いた検索語が空でない間は検索中とみなす
    private var isSearching: Bool {
        !MemoSearch.terms(in: query).isEmpty
    }

    /// 絞り込み・検索をしたあとに、ピン留めとその他に分けて並べ替えた、表示する一覧
    private var shownGroups: MemoPinGroups {
        MemoPinGroups(memos: MemoSearch.filter(filter.apply(to: store.memos), query: query), sort: sort)
    }

    var body: some View {
        NavigationStack {
            List {
                // 検索中は追加欄を隠す
                if !isSearching {
                    addSection
                }
                Section {
                    filterBar
                }
                // 一覧の行として出し、上の絞り込みの丸は押せるままにする
                emptyStateRow
                    .listRowBackground(Color.clear)
                let groups = shownGroups
                if groups.showsHeaders {
                    Section("ピン留め") {
                        memoRows(groups.pinned, pinned: true)
                    }
                    if !groups.others.isEmpty {
                        Section("その他") {
                            memoRows(groups.others, pinned: false)
                        }
                    }
                } else {
                    // ピン留めが 0 件のときは見出しを出さず、今までどおりの一覧にする
                    memoRows(groups.others, pinned: false)
                }
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "メモを検索")
            .navigationTitle("メモ一覧")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    sortMenu
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    /// メモの追加欄
    private var addSection: some View {
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
    }

    /// 並べ替えを選ぶメニュー。いま選んでいるものにはチェックが付く
    private var sortMenu: some View {
        Menu {
            Picker("並べ替え", selection: $sort) {
                ForEach(MemoSort.allCases) { item in
                    Text(item.name).tag(item)
                }
            }
        } label: {
            Label("並べ替え: \(sort.name)", systemImage: "arrow.up.arrow.down")
        }
    }

    /// 出すメモが 0 件のときの案内。出すメモがあるときは何も出さない
    @ViewBuilder
    private var emptyStateRow: some View {
        switch MemoEmptyState.make(memos: store.memos, filter: filter, query: query) {
        case .none:
            EmptyView()
        case .noMemos:
            ContentUnavailableView(
                "まだメモがありません",
                systemImage: "note.text",
                description: Text("上の欄から追加できます")
            )
        case .noMemosInFilter:
            ContentUnavailableView("この色のメモはありません", systemImage: "circle.dashed")
        case .noSearchResults:
            ContentUnavailableView.search(text: query)
        }
    }

    /// 一覧の上に並べる絞り込みの丸。選んでいる丸には外側に枠を付ける
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MemoFilter.allCases, id: \.self) { item in
                    Button {
                        filter = item
                    } label: {
                        filterCircle(for: item)
                            .padding(3)
                            .overlay {
                                if filter == item {
                                    Circle().stroke(Color.primary, lineWidth: 2)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(item.name)
                    .accessibilityAddTraits(filter == item ? .isSelected : [])
                }
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func filterCircle(for item: MemoFilter) -> some View {
        switch item {
        case .all:
            Circle()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 28, height: 28)
                .overlay {
                    Text("全")
                        .font(.caption)
                }
        case .noColor:
            Circle()
                .strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.5, dash: [3]))
                .frame(width: 28, height: 28)
        case .color(let color):
            Circle()
                .fill(color.swatch)
                .frame(width: 28, height: 28)
        }
    }

    /// 1 つのまとまりのメモの行。消す・動かすはこのまとまりの中の位置で受け取る
    private func memoRows(_ memos: [Memo], pinned: Bool) -> some View {
        // 絞り込み・検索・新しい順・古い順のときは表示の位置が保存順とずれるので、
        // ドラッグでの並べ替えは手動で「すべて」で検索していないときだけにする。
        // 動かせるのはまとまりの中だけで、もう一方のまとまりのメモの位置は変えない
        let move: ((IndexSet, Int) -> Void)? = sort.allowsMove(filter: filter, isSearching: isSearching)
            ? { source, destination in
                store.move(fromOffsets: source, toOffset: destination, pinned: pinned)
            }
            : nil
        return ForEach(memos) { memo in
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
                if memo.isPinned {
                    Spacer()
                    Image(systemName: "pin.fill")
                        .foregroundStyle(.orange)
                        .accessibilityLabel("ピン留め")
                }
            }
            .contextMenu {
                pinButton(for: memo)
                Divider()
                colorMenu(for: memo)
            }
            .swipeActions(edge: .leading) {
                pinButton(for: memo)
                    .tint(.orange)
            }
        }
        .onDelete { offsets in
            // 受け取る位置は絞り込み・並べ替えをしたまとまりの中の位置なので、id に変えて消す
            store.remove(ids: offsets.map { memos[$0].id })
        }
        .onMove(perform: move)
    }

    /// ピン留めを付け外しするボタン
    private func pinButton(for memo: Memo) -> some View {
        Button {
            store.setPinned(!memo.isPinned, for: memo.id)
        } label: {
            Label(memo.pinActionName, systemImage: memo.isPinned ? "pin.slash" : "pin")
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

extension Memo {
    /// ピン留めを付け外しするボタンの名前。いまの状態の逆にする操作の名前を出す
    var pinActionName: String {
        isPinned ? "ピン留めを外す" : "ピン留め"
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
