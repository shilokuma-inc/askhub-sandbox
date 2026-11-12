import Testing
@testable import SandboxApp

/// 一覧が 0 件のときに出す案内の判定
struct MemoEmptyStateTests {
    private let memos = [
        Memo(text: "買い物", color: .red),
        Memo(text: "掃除", color: .red),
    ]

    @Test func noMemosWithAll() {
        #expect(MemoEmptyState.make(memos: [], filter: .all, query: "") == .noMemos)
    }

    @Test func noMemosWithColor() {
        #expect(MemoEmptyState.make(memos: [], filter: .color(.blue), query: "") == .noMemos)
    }

    @Test func noMemosWithNoColor() {
        #expect(MemoEmptyState.make(memos: [], filter: .noColor, query: "") == .noMemos)
    }

    @Test func noMemosWhileSearching() {
        #expect(MemoEmptyState.make(memos: [], filter: .all, query: "買い物") == .noSearchResults)
        #expect(MemoEmptyState.make(memos: [], filter: .color(.red), query: "買い物") == .noSearchResults)
    }

    @Test func noMemosInColor() {
        #expect(MemoEmptyState.make(memos: memos, filter: .color(.blue), query: "") == .noMemosInFilter)
    }

    @Test func noMemosWithoutColor() {
        #expect(MemoEmptyState.make(memos: memos, filter: .noColor, query: "") == .noMemosInFilter)
    }

    @Test func noSearchResults() {
        #expect(MemoEmptyState.make(memos: memos, filter: .all, query: "洗濯") == .noSearchResults)
    }

    @Test func noSearchResultsWithColor() {
        // 色だけでも 0 件になるが、検索中なので検索の案内にする
        #expect(MemoEmptyState.make(memos: memos, filter: .color(.blue), query: "買い物") == .noSearchResults)
        // 色では出るが、検索で 0 件になる
        #expect(MemoEmptyState.make(memos: memos, filter: .color(.red), query: "洗濯") == .noSearchResults)
    }

    @Test func blankQueryIsNotSearching() {
        #expect(MemoEmptyState.make(memos: [], filter: .all, query: " 　") == .noMemos)
        #expect(MemoEmptyState.make(memos: memos, filter: .noColor, query: " ") == .noMemosInFilter)
    }

    @Test func noneWhenSomeMemosShown() {
        #expect(MemoEmptyState.make(memos: memos, filter: .all, query: "") == .none)
        #expect(MemoEmptyState.make(memos: memos, filter: .color(.red), query: "") == .none)
        #expect(MemoEmptyState.make(memos: memos, filter: .all, query: "掃除") == .none)
        #expect(MemoEmptyState.make(memos: memos, filter: .color(.red), query: "買い物") == .none)
    }
}
