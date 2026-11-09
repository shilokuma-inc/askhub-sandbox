import Foundation
import Testing
@testable import SandboxApp

/// 一覧の検索と、検索で絞り込んだ並びからの削除
@MainActor
struct MemoSearchTests {
    private func defaults() -> UserDefaults {
        let name = "MemoSearchTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private let memos = [
        Memo(text: "SwiftUI のメモ"),
        Memo(text: "Swift だけ"),
        Memo(text: "買い物 りんご"),
        Memo(text: "カイモノ リスト"),
    ]

    private func search(_ query: String) -> [String] {
        MemoSearch.filter(memos, query: query).map(\.text)
    }

    @Test func ignoresCase() {
        #expect(search("swiftui") == ["SwiftUI のメモ"])
        #expect(search("SWIFT") == ["SwiftUI のメモ", "Swift だけ"])
    }

    @Test func requiresEveryTerm() {
        #expect(search("Swift ui") == ["SwiftUI のメモ"])
        #expect(search("Swift りんご").isEmpty)
    }

    @Test func splitsByFullWidthSpaceAndNewline() {
        #expect(search("Swift\u{3000}ui") == ["SwiftUI のメモ"])
        #expect(search("買い物\nりんご") == ["買い物 りんご"])
        #expect(search("\u{3000}swift \u{3000} メモ\u{3000}") == ["SwiftUI のメモ"])
    }

    @Test func emptyOrBlankQueryShowsEveryMemo() {
        let all = memos.map(\.text)
        #expect(search("") == all)
        #expect(search("   ") == all)
        #expect(search("\u{3000} \n\t") == all)
    }

    @Test func distinguishesHiraganaAndKatakana() {
        #expect(search("かいもの").isEmpty)
        #expect(search("カイモノ") == ["カイモノ リスト"])
        #expect(search("買い物") == ["買い物 りんご"])
    }

    @Test func distinguishesWidthAndAccents() {
        #expect(search("ＳＷＩＦＴ").isEmpty)
        #expect(MemoSearch.filter([Memo(text: "café")], query: "cafe").isEmpty)
        #expect(MemoSearch.filter([Memo(text: "Café")], query: "CAFÉ").count == 1)
    }

    @Test func noMatchReturnsEmpty() {
        #expect(search("存在しない").isEmpty)
    }

    @Test func combinesWithColorFilter() {
        let colored = [
            Memo(text: "Swift 赤", color: .red),
            Memo(text: "Swift 青", color: .blue),
            Memo(text: "メモ 赤", color: .red),
        ]
        // 一覧と同じく、色で絞り込んでから検索する
        let shown = MemoSearch.filter(MemoFilter.color(.red).apply(to: colored), query: "swift")
        #expect(shown.map(\.text) == ["Swift 赤"])
    }

    @Test func removesShownMemoFromColorFilteredAndSearchedList() {
        let defaults = defaults()
        let store = MemoStore(defaults: defaults)
        store.add("swift 青", color: .blue)
        store.add("swift 赤 2", color: .red)
        store.add("b", color: .red)
        store.add("Swift 赤 1", color: .red)
        // 赤で絞り込んで「swift」で検索した並び（Swift 赤 1, swift 赤 2）の 2 つめを消す
        let shown = MemoSearch.filter(MemoFilter.color(.red).apply(to: store.memos), query: "swift")
        store.remove(ids: IndexSet(integer: 1).map { shown[$0].id })
        #expect(store.memos.map(\.text) == ["Swift 赤 1", "b", "swift 青"])
        #expect(MemoStore(defaults: defaults).memos.map(\.text) == ["Swift 赤 1", "b", "swift 青"])
    }

    @Test func removesShownMemoFromSearchedList() {
        let defaults = defaults()
        let store = MemoStore(defaults: defaults)
        store.add("swift c")
        store.add("b")
        store.add("Swift a")
        // 「swift」で絞り込んだ並び（Swift a, swift c）の 2 つめを消すと、swift c が消える
        let shown = MemoSearch.filter(store.memos, query: "swift")
        store.remove(ids: IndexSet(integer: 1).map { shown[$0].id })
        #expect(store.memos.map(\.text) == ["Swift a", "b"])
        #expect(MemoStore(defaults: defaults).memos.map(\.text) == ["Swift a", "b"])
    }
}
