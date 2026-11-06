import Foundation
import Observation

struct Memo: Codable, Identifiable, Equatable {
    var id = UUID()
    var text: String
    var createdAt = Date()
}

/// メモを UserDefaults に保存する
@Observable
final class MemoStore {
    private(set) var memos: [Memo] = []
    private let defaults: UserDefaults
    private let key = "memos"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key), let saved = try? JSONDecoder().decode([Memo].self, from: data) {
            memos = saved
        }
    }

    func add(_ text: String) {
        memos.insert(Memo(text: text), at: 0)
        save()
    }

    func remove(at offsets: IndexSet) {
        memos.remove(atOffsets: offsets)
        save()
    }

    private func save() {
        defaults.set(try? JSONEncoder().encode(memos), forKey: key)
    }
}
