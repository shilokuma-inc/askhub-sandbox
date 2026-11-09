import Foundation

/// 一覧の検索。検索語を空白で分けたすべての言葉を含むメモだけを出す
enum MemoSearch {
    /// 検索語を空白（半角・全角の空白と改行）で分け、空の言葉を捨てる
    static func terms(in query: String) -> [String] {
        query.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
    }

    /// すべての言葉を、大文字小文字を区別せずに含むか。ひらがなとカタカナ、全角と半角、アクセント記号は区別する
    static func matches(_ memo: Memo, terms: [String]) -> Bool {
        terms.allSatisfy { memo.text.range(of: $0, options: .caseInsensitive) != nil }
    }

    /// 一致するメモだけを、元の並びのまま返す。言葉が 1 つも無ければすべてを返す
    static func filter(_ memos: [Memo], query: String) -> [Memo] {
        let words = terms(in: query)
        guard !words.isEmpty else { return memos }
        return memos.filter { matches($0, terms: words) }
    }
}
