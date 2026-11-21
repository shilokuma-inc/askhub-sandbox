import Testing
@testable import SandboxApp

/// 一覧の上に出す件数の行
struct MemoCountTests {
    private let memos = [
        Memo(text: "買い物", color: .red, isPinned: true),
        Memo(text: "掃除", color: .red),
        Memo(text: "買い物リスト", color: .blue, isPinned: true),
        Memo(text: "洗濯"),
    ]

    @Test func all() {
        let count = MemoCount.make(memos: memos, filter: .all, query: "")
        #expect(count == MemoCount(total: 4, shown: 4, pinned: 2, isNarrowed: false))
        #expect(count.text == "4件（ピン留め 2件）")
        #expect(!count.isHidden)
    }

    @Test func filteredByColor() {
        let count = MemoCount.make(memos: memos, filter: .color(.red), query: "")
        #expect(count == MemoCount(total: 4, shown: 2, pinned: 1, isNarrowed: true))
        #expect(count.text == "4件中2件（ピン留め 1件）")
        #expect(!count.isHidden)
    }

    @Test func filteredByNoColor() {
        let count = MemoCount.make(memos: memos, filter: .noColor, query: "")
        #expect(count.text == "4件中1件（ピン留め 0件）")
    }

    @Test func searching() {
        let count = MemoCount.make(memos: memos, filter: .all, query: "買い物")
        #expect(count == MemoCount(total: 4, shown: 2, pinned: 2, isNarrowed: true))
        #expect(count.text == "4件中2件（ピン留め 2件）")
    }

    @Test func searchingWithColor() {
        let count = MemoCount.make(memos: memos, filter: .color(.red), query: "買い物")
        #expect(count.text == "4件中1件（ピン留め 1件）")
    }

    @Test func searchMatchingAllStillShowsBothCounts() {
        // 全部が見えていても、検索中なら両方を出す
        let searching = MemoCount.make(memos: [memos[0], memos[2]], filter: .all, query: "買い物")
        #expect(searching.text == "2件中2件（ピン留め 2件）")
    }

    @Test func blankQueryIsNotSearching() {
        let count = MemoCount.make(memos: memos, filter: .all, query: " 　")
        #expect(!count.isNarrowed)
        #expect(count.text == "4件（ピン留め 2件）")
    }

    @Test func noResults() {
        let searched = MemoCount.make(memos: memos, filter: .all, query: "料理")
        #expect(searched.text == "4件中0件（ピン留め 0件）")
        #expect(!searched.isHidden)

        let filtered = MemoCount.make(memos: memos, filter: .color(.green), query: "")
        #expect(filtered.text == "4件中0件（ピン留め 0件）")
        #expect(!filtered.isHidden)
    }

    @Test func noMemos() {
        #expect(MemoCount.make(memos: [], filter: .all, query: "").isHidden)
        #expect(MemoCount.make(memos: [], filter: .color(.red), query: "").isHidden)
        #expect(MemoCount.make(memos: [], filter: .all, query: "買い物").isHidden)
    }

    @Test func noPinnedMemos() {
        let unpinned = [Memo(text: "掃除"), Memo(text: "洗濯", color: .blue)]
        #expect(MemoCount.make(memos: unpinned, filter: .all, query: "").text == "2件（ピン留め 0件）")
        #expect(MemoCount.make(memos: unpinned, filter: .color(.blue), query: "").text == "2件中1件（ピン留め 0件）")
    }

    @Test func pinnedCountsOnlyShownMemos() {
        // ピン留めは全部で 2 件あるが、見えているのは 1 件だけ
        let count = MemoCount.make(memos: memos, filter: .color(.blue), query: "")
        #expect(count.pinned == 1)
    }
}
