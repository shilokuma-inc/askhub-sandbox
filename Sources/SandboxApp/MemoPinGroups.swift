import Foundation

/// 一覧に出すメモを、ピン留めとその他の 2 つのまとまりに分けたもの。
/// どちらのまとまりも、渡した並べ替えで並べる
struct MemoPinGroups: Equatable {
    /// ピン留めしたメモ。一覧の先頭に出す
    var pinned: [Memo]
    /// ピン留めしていないメモ
    var others: [Memo]

    init(memos: [Memo], sort: MemoSort) {
        pinned = sort.apply(to: memos.filter(\.isPinned))
        others = sort.apply(to: memos.filter { !$0.isPinned })
    }

    /// 見出しを出すか。ピン留めが 0 件のときは見出しを出さない
    var showsHeaders: Bool {
        !pinned.isEmpty
    }
}
