import Foundation
import Testing
@testable import SandboxApp

/// MemoStore の追加・削除・保存
@MainActor
struct MemoStoreTests {
    private func defaults() -> UserDefaults {
        let name = "MemoStoreTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @Test func addsNewMemoFirst() {
        let store = MemoStore(defaults: defaults())
        store.add("1 つめ")
        store.add("2 つめ")
        #expect(store.memos.map(\.text) == ["2 つめ", "1 つめ"])
    }

    @Test func removesMemos() {
        let store = MemoStore(defaults: defaults())
        store.add("a")
        store.add("b")
        store.remove(at: IndexSet(integer: 0))
        #expect(store.memos.map(\.text) == ["a"])
    }

    @Test func keepsMemosAfterReopening() {
        let defaults = defaults()
        MemoStore(defaults: defaults).add("残る")
        #expect(MemoStore(defaults: defaults).memos.map(\.text) == ["残る"])
    }
}
