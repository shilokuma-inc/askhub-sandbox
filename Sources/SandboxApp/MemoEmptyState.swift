import Foundation

/// 一覧に出すメモが 0 件のときに、どの案内を出すか
enum MemoEmptyState: Equatable {
    /// 出すメモが 1 件以上あるので、案内は出さない
    case none
    /// メモが 1 件も無い（色の絞り込みに関係なく）
    case noMemos
    /// メモはあるが、選んだ色（「色なし」も含む）に当たるメモが無い
    case noMemosInFilter
    /// 検索して 0 件になった
    case noSearchResults

    /// 全メモ・絞り込み・検索語から決める。上から順に当てはまったものにする
    static func make(memos: [Memo], filter: MemoFilter, query: String) -> MemoEmptyState {
        // (1) 出すメモがあれば案内は要らない
        if !MemoSearch.filter(filter.apply(to: memos), query: query).isEmpty {
            return .none
        }
        // (2) 検索中なら、メモが 0 件でも色を選んでいても検索の案内にする
        if !MemoSearch.terms(in: query).isEmpty {
            return .noSearchResults
        }
        // (3) メモが 1 件も無ければ、色を選んでいても「まだメモがありません」にする
        if memos.isEmpty {
            return .noMemos
        }
        // (4) .noColor と .color のときはここに来る。
        // .all で検索していないときは全メモがそのまま出るので (1) か (3) で返り、ここには来ない。
        // もし来たときも、空の一覧のままにせず同じ案内を出す
        return .noMemosInFilter
    }
}
