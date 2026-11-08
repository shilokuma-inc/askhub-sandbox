import Foundation
import Testing
@testable import SandboxApp

/// MemoStore の追加・削除・並べ替え・保存
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

    @Test func movesMemos() {
        let store = MemoStore(defaults: defaults())
        store.add("c")
        store.add("b")
        store.add("a")
        store.move(fromOffsets: IndexSet(integer: 0), toOffset: 3)
        #expect(store.memos.map(\.text) == ["b", "c", "a"])
        store.move(fromOffsets: IndexSet(integer: 2), toOffset: 1)
        #expect(store.memos.map(\.text) == ["b", "a", "c"])
    }

    @Test func keepsMovedOrderAfterReopening() {
        let defaults = defaults()
        let store = MemoStore(defaults: defaults)
        store.add("c")
        store.add("b")
        store.add("a")
        store.move(fromOffsets: IndexSet([0, 1]), toOffset: 3)
        #expect(MemoStore(defaults: defaults).memos.map(\.text) == ["c", "a", "b"])
    }

    @Test func addsNewMemoFirstAfterMoving() {
        let store = MemoStore(defaults: defaults())
        store.add("c")
        store.add("b")
        store.add("a")
        store.move(fromOffsets: IndexSet(integer: 2), toOffset: 0)
        store.add("new")
        #expect(store.memos.map(\.text) == ["new", "c", "a", "b"])
    }

    @Test func addsMemoWithColor() {
        let store = MemoStore(defaults: defaults())
        store.add("色なし")
        store.add("赤", color: .red)
        #expect(store.memos.map(\.color) == [.red, nil])
    }

    @Test func changesAndClearsColorAfterReopening() {
        let defaults = defaults()
        let store = MemoStore(defaults: defaults)
        store.add("b")
        store.add("a", color: .blue)
        let a = store.memos[0].id
        let b = store.memos[1].id
        store.setColor(.purple, for: b)
        store.setColor(nil, for: a)
        #expect(store.memos.map(\.color) == [nil, .purple])
        #expect(MemoStore(defaults: defaults).memos.map(\.color) == [nil, .purple])
    }

    @Test func loadsOldMemosWithoutColor() throws {
        let defaults = defaults()
        let json = """
        [{"id":"\(UUID().uuidString)","text":"古い","createdAt":0}]
        """
        defaults.set(Data(json.utf8), forKey: "memos")
        let store = MemoStore(defaults: defaults)
        #expect(store.memos.map(\.text) == ["古い"])
        #expect(store.memos.map(\.color) == [nil])
    }

    @Test func removesMemosByID() {
        let defaults = defaults()
        let store = MemoStore(defaults: defaults)
        store.add("c", color: .red)
        store.add("b")
        store.add("a", color: .red)
        let filtered = store.memos.filter { $0.color == .red }
        store.remove(ids: [filtered[1].id])
        #expect(store.memos.map(\.text) == ["a", "b"])
        #expect(MemoStore(defaults: defaults).memos.map(\.text) == ["a", "b"])
    }

    @Test func colorsAreFive() {
        #expect(MemoColor.allCases == [.red, .blue, .green, .yellow, .purple])
    }

    @Test func colorNamesAreJapanese() {
        #expect(MemoColor.allCases.map(\.name) == ["赤", "青", "緑", "黄", "紫"])
        #expect(MemoColor.noneName == "色なし")
    }
}
