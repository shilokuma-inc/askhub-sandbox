import Foundation
import Testing
@testable import SandboxApp

/// 一覧の絞り込みと、絞り込んだ並びからの削除
@MainActor
struct MemoFilterTests {
    private func defaults() -> UserDefaults {
        let name = "MemoFilterTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private let memos = [
        Memo(text: "a", color: .red),
        Memo(text: "b"),
        Memo(text: "c", color: .blue),
        Memo(text: "d", color: .red),
    ]

    @Test func filtersOrderAndNames() {
        #expect(MemoFilter.allCases == [.all, .noColor, .color(.red), .color(.blue), .color(.green), .color(.yellow), .color(.purple)])
        #expect(MemoFilter.allCases.map(\.name) == ["すべて", "色なし", "赤", "青", "緑", "黄", "紫"])
    }

    @Test func allShowsEveryMemo() {
        #expect(MemoFilter.all.apply(to: memos).map(\.text) == ["a", "b", "c", "d"])
    }

    @Test func noColorShowsOnlyMemosWithoutColor() {
        #expect(MemoFilter.noColor.apply(to: memos).map(\.text) == ["b"])
    }

    @Test func colorShowsOnlyThatColorInOrder() {
        #expect(MemoFilter.color(.red).apply(to: memos).map(\.text) == ["a", "d"])
        #expect(MemoFilter.color(.blue).apply(to: memos).map(\.text) == ["c"])
        #expect(MemoFilter.color(.green).apply(to: memos).isEmpty)
    }

    @Test func removesShownMemoFromFilteredList() {
        let defaults = defaults()
        let store = MemoStore(defaults: defaults)
        store.add("c", color: .red)
        store.add("b")
        store.add("a", color: .red)
        // 赤で絞り込んだ並び（a, c）の 2 つめを消すと、c が消える
        let shown = MemoFilter.color(.red).apply(to: store.memos)
        store.remove(ids: IndexSet(integer: 1).map { shown[$0].id })
        #expect(store.memos.map(\.text) == ["a", "b"])
        #expect(MemoStore(defaults: defaults).memos.map(\.text) == ["a", "b"])
    }
}
