import Foundation
import Testing
@testable import SandboxApp

/// 一覧の並べ替えと、選んだ並べ替えの保存
@MainActor
struct MemoSortTests {
    private func defaults() -> UserDefaults {
        let name = "MemoSortTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    // 保存順（手動の順）は b, c, a。作った日時は a が一番古く、c が一番新しい
    private let memos = [
        Memo(text: "b", createdAt: Date(timeIntervalSince1970: 200)),
        Memo(text: "c", createdAt: Date(timeIntervalSince1970: 300)),
        Memo(text: "a", createdAt: Date(timeIntervalSince1970: 100)),
    ]

    @Test func sortsOrderAndNames() {
        #expect(MemoSort.allCases == [.manual, .newestFirst, .oldestFirst])
        #expect(MemoSort.allCases.map(\.name) == ["手動", "新しい順", "古い順"])
    }

    @Test func manualKeepsOriginalOrder() {
        #expect(MemoSort.manual.apply(to: memos).map(\.text) == ["b", "c", "a"])
    }

    @Test func newestFirstPutsNewestOnTop() {
        #expect(MemoSort.newestFirst.apply(to: memos).map(\.text) == ["c", "b", "a"])
    }

    @Test func oldestFirstPutsOldestOnTop() {
        #expect(MemoSort.oldestFirst.apply(to: memos).map(\.text) == ["a", "b", "c"])
    }

    @Test func keepsOriginalOrderForSameDate() {
        let same = Date(timeIntervalSince1970: 500)
        let memos = [
            Memo(text: "x", createdAt: same),
            Memo(text: "old", createdAt: Date(timeIntervalSince1970: 100)),
            Memo(text: "y", createdAt: same),
            Memo(text: "z", createdAt: same),
        ]
        #expect(MemoSort.newestFirst.apply(to: memos).map(\.text) == ["x", "y", "z", "old"])
        #expect(MemoSort.oldestFirst.apply(to: memos).map(\.text) == ["old", "x", "y", "z"])
    }

    @Test func doesNotChangeOriginalArray() {
        let original = memos
        _ = MemoSort.newestFirst.apply(to: memos)
        _ = MemoSort.oldestFirst.apply(to: memos)
        #expect(memos == original)
    }

    @Test func allowsMoveOnlyWhenManualAllAndNotSearching() {
        #expect(MemoSort.manual.allowsMove(filter: .all, isSearching: false))
        #expect(!MemoSort.manual.allowsMove(filter: .all, isSearching: true))
        #expect(!MemoSort.manual.allowsMove(filter: .noColor, isSearching: false))
        #expect(!MemoSort.manual.allowsMove(filter: .color(.red), isSearching: false))
        #expect(!MemoSort.newestFirst.allowsMove(filter: .all, isSearching: false))
        #expect(!MemoSort.oldestFirst.allowsMove(filter: .all, isSearching: false))
    }

    @Test func sortsFilteredAndSearchedMemos() {
        let memos = [
            Memo(text: "買い物 b", createdAt: Date(timeIntervalSince1970: 200), color: .red),
            Memo(text: "買い物 c", createdAt: Date(timeIntervalSince1970: 300), color: .blue),
            Memo(text: "買い物 a", createdAt: Date(timeIntervalSince1970: 100), color: .red),
            Memo(text: "宿題 d", createdAt: Date(timeIntervalSince1970: 400), color: .red),
        ]
        let shown = MemoSearch.filter(MemoFilter.color(.red).apply(to: memos), query: "買い物")
        #expect(MemoSort.newestFirst.apply(to: shown).map(\.text) == ["買い物 b", "買い物 a"])
        #expect(MemoSort.oldestFirst.apply(to: shown).map(\.text) == ["買い物 a", "買い物 b"])
    }

    @Test func removesRightMemoFromSortedListWithoutChangingStoredOrder() {
        let store = MemoStore(defaults: defaults())
        store.add("a")
        store.add("b")
        store.add("c")
        let stored = store.memos
        let shown = MemoSort.oldestFirst.apply(to: stored)
        #expect(store.memos == stored)
        // 表示の先頭（一番古いもの）を消す
        let target = shown[0]
        store.remove(ids: [target.id])
        #expect(!store.memos.contains { $0.id == target.id })
        #expect(store.memos == stored.filter { $0.id != target.id })
    }

    @Test func defaultsToManualWhenNothingSaved() {
        #expect(MemoSort(storedIn: defaults()) == .manual)
    }

    @Test func defaultsToManualForUnreadableValue() {
        let defaults = defaults()
        defaults.set("byColor", forKey: MemoSort.storageKey)
        #expect(MemoSort(storedIn: defaults) == .manual)
    }

    @Test func savesAndLoadsEverySort() {
        for sort in MemoSort.allCases {
            let defaults = defaults()
            sort.save(to: defaults)
            #expect(MemoSort(storedIn: defaults) == sort)
        }
    }

    @Test func savesLastChosenSort() {
        let defaults = defaults()
        MemoSort.oldestFirst.save(to: defaults)
        MemoSort.newestFirst.save(to: defaults)
        #expect(MemoSort(storedIn: defaults) == .newestFirst)
        #expect(defaults.string(forKey: MemoSort.storageKey) == "newestFirst")
    }
}
