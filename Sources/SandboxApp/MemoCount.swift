import Foundation

/// 一覧の上に出す件数の行
struct MemoCount: Equatable {
    /// 全部のメモの件数
    var total: Int
    /// 絞り込み・検索をして見えている件数
    var shown: Int
    /// 見えているメモのうちのピン留めの件数
    var pinned: Int
    /// 色で絞り込むか、検索をしているか
    var isNarrowed: Bool

    /// 全メモ・絞り込み・検索語から数える。見えているメモは一覧と同じ求め方にする
    static func make(memos: [Memo], filter: MemoFilter, query: String) -> MemoCount {
        let shownMemos = MemoSearch.filter(filter.apply(to: memos), query: query)
        return MemoCount(
            total: memos.count,
            shown: shownMemos.count,
            pinned: shownMemos.filter(\.isPinned).count,
            isNarrowed: filter != .all || !MemoSearch.terms(in: query).isEmpty
        )
    }

    /// メモが 1 件も無いときは件数の行を出さない
    var isHidden: Bool {
        total == 0
    }

    /// 画面に出す文。絞り込み・検索中は全部の件数と見えている件数の両方を出す
    var text: String {
        if isNarrowed {
            "\(total)件中\(shown)件（ピン留め \(pinned)件）"
        } else {
            "\(total)件（ピン留め \(pinned)件）"
        }
    }
}
