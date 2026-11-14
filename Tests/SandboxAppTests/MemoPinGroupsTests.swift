import Foundation
import Testing
@testable import SandboxApp

/// ピン留めとその他に分けて、それぞれを並べ替える
@MainActor
struct MemoPinGroupsTests {
    // 保存順（手動の順）は pb, ob, pc, oa, pa, oc。
    // ピン留めは pa が一番古く pc が一番新しい。その他は oa が一番古く oc が一番新しい
    private let memos = [
        Memo(text: "pb", createdAt: Date(timeIntervalSince1970: 200), isPinned: true),
        Memo(text: "ob", createdAt: Date(timeIntervalSince1970: 250)),
        Memo(text: "pc", createdAt: Date(timeIntervalSince1970: 300), isPinned: true),
        Memo(text: "oa", createdAt: Date(timeIntervalSince1970: 50)),
        Memo(text: "pa", createdAt: Date(timeIntervalSince1970: 100), isPinned: true),
        Memo(text: "oc", createdAt: Date(timeIntervalSince1970: 400)),
    ]

    @Test func manualKeepsStoredOrderInEachGroup() {
        let groups = MemoPinGroups(memos: memos, sort: .manual)
        #expect(groups.pinned.map(\.text) == ["pb", "pc", "pa"])
        #expect(groups.others.map(\.text) == ["ob", "oa", "oc"])
    }

    @Test func newestFirstInEachGroup() {
        let groups = MemoPinGroups(memos: memos, sort: .newestFirst)
        #expect(groups.pinned.map(\.text) == ["pc", "pb", "pa"])
        #expect(groups.others.map(\.text) == ["oc", "ob", "oa"])
    }

    @Test func oldestFirstInEachGroup() {
        let groups = MemoPinGroups(memos: memos, sort: .oldestFirst)
        #expect(groups.pinned.map(\.text) == ["pa", "pb", "pc"])
        #expect(groups.others.map(\.text) == ["oa", "ob", "oc"])
    }

    @Test func everyMemoGoesToExactlyOneGroup() {
        for sort in MemoSort.allCases {
            let groups = MemoPinGroups(memos: memos, sort: sort)
            #expect(groups.pinned.map(\.isPinned) == Array(repeating: true, count: groups.pinned.count))
            #expect(groups.others.map(\.isPinned) == Array(repeating: false, count: groups.others.count))
            #expect(Set((groups.pinned + groups.others).map(\.id)) == Set(memos.map(\.id)))
            #expect(groups.pinned.count + groups.others.count == memos.count)
        }
    }

    @Test func showsHeadersOnlyWhenSomethingIsPinned() {
        #expect(MemoPinGroups(memos: memos, sort: .manual).showsHeaders)
        let unpinned = memos.filter { !$0.isPinned }
        let groups = MemoPinGroups(memos: unpinned, sort: .manual)
        #expect(!groups.showsHeaders)
        #expect(groups.pinned.isEmpty)
        #expect(groups.others.map(\.text) == ["ob", "oa", "oc"])
        #expect(!MemoPinGroups(memos: [], sort: .manual).showsHeaders)
    }

    @Test func pinActionNameIsTheOppositeOfCurrentState() {
        #expect(Memo(text: "a").pinActionName == "ピン留め")
        #expect(Memo(text: "a", isPinned: true).pinActionName == "ピン留めを外す")
    }

    @Test func groupsFilteredAndSearchedMemos() {
        let memos = [
            Memo(text: "買い物 b", createdAt: Date(timeIntervalSince1970: 200), color: .red, isPinned: true),
            Memo(text: "買い物 c", createdAt: Date(timeIntervalSince1970: 300), color: .red),
            Memo(text: "買い物 a", createdAt: Date(timeIntervalSince1970: 100), color: .red, isPinned: true),
            Memo(text: "買い物 d", createdAt: Date(timeIntervalSince1970: 400), color: .blue, isPinned: true),
            Memo(text: "宿題 e", createdAt: Date(timeIntervalSince1970: 500), color: .red),
        ]
        let shown = MemoSearch.filter(MemoFilter.color(.red).apply(to: memos), query: "買い物")
        let groups = MemoPinGroups(memos: shown, sort: .oldestFirst)
        #expect(groups.pinned.map(\.text) == ["買い物 a", "買い物 b"])
        #expect(groups.others.map(\.text) == ["買い物 c"])
    }
}
