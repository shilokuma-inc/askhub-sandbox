import Foundation

/// 一覧の絞り込み。「すべて」「色なし」「各色」のどれか1つ
enum MemoFilter: Hashable {
    case all
    case noColor
    case color(MemoColor)

    /// 一覧の上に並べる順（すべて・色なし・赤・青・緑・黄・紫）
    static let allCases: [MemoFilter] = [.all, .noColor] + MemoColor.allCases.map { .color($0) }

    func matches(_ memo: Memo) -> Bool {
        switch self {
        case .all: true
        case .noColor: memo.color == nil
        case .color(let color): memo.color == color
        }
    }

    /// 条件に合うメモだけを、元の並びのまま返す
    func apply(to memos: [Memo]) -> [Memo] {
        memos.filter(matches)
    }

    /// 画面に出す名前
    var name: String {
        switch self {
        case .all: "すべて"
        case .noColor: MemoColor.noneName
        case .color(let color): color.name
        }
    }
}
