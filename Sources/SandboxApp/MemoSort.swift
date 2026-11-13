import Foundation

/// 一覧の並べ替え。表示だけに使い、保存されたメモの順は変えない
/// rawValue は String なので、@AppStorage(MemoSort.storageKey) でもそのまま使える
enum MemoSort: String, CaseIterable, Identifiable {
    /// 保存順（ドラッグで動かした順）
    case manual
    /// createdAt が新しいものが上
    case newestFirst
    /// createdAt が古いものが上
    case oldestFirst

    /// 選んだ並べ替えを保存する UserDefaults のキー
    static let storageKey = "memoSort"

    var id: Self { self }

    /// 画面に出す名前
    var name: String {
        switch self {
        case .manual: "手動"
        case .newestFirst: "新しい順"
        case .oldestFirst: "古い順"
        }
    }

    /// メモを並べて返す。manual は元の順のまま。createdAt が同じときは元の順を保つ
    func apply(to memos: [Memo]) -> [Memo] {
        switch self {
        case .manual:
            return memos
        case .newestFirst:
            return stableSorted(memos) { $0.createdAt > $1.createdAt }
        case .oldestFirst:
            return stableSorted(memos) { $0.createdAt < $1.createdAt }
        }
    }

    /// ドラッグで並べ替えてよいか。表示の位置が保存順と同じになる、手動で「すべて」で検索していないときだけ
    func allowsMove(filter: MemoFilter, isSearching: Bool) -> Bool {
        self == .manual && filter == .all && !isSearching
    }

    /// 保存された並べ替えを読み込む。保存が無いときや読めない値のときは manual
    init(storedIn defaults: UserDefaults) {
        self = defaults.string(forKey: Self.storageKey).flatMap(Self.init(rawValue:)) ?? .manual
    }

    /// 選んだ並べ替えを保存する
    func save(to defaults: UserDefaults) {
        defaults.set(rawValue, forKey: Self.storageKey)
    }

    /// sorted(by:) は安定と決まっていないので、元の位置で順を決める
    private func stableSorted(_ memos: [Memo], by areInIncreasingOrder: (Memo, Memo) -> Bool) -> [Memo] {
        memos.enumerated()
            .sorted { lhs, rhs in
                if areInIncreasingOrder(lhs.element, rhs.element) { return true }
                if areInIncreasingOrder(rhs.element, lhs.element) { return false }
                return lhs.offset < rhs.offset
            }
            .map(\.element)
    }
}
