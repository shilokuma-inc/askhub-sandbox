import Foundation
import Observation
import SwiftUI

/// メモに付ける色のラベル
enum MemoColor: String, Codable, CaseIterable {
    case red, blue, green, yellow, purple
}

struct Memo: Codable, Identifiable, Equatable {
    var id = UUID()
    var text: String
    var createdAt = Date()
    /// nil は色なし。古いデータで color のキーが無いときも nil として読み込む
    var color: MemoColor?
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

    func add(_ text: String, color: MemoColor? = nil) {
        memos.insert(Memo(text: text, color: color), at: 0)
        save()
    }

    func setColor(_ color: MemoColor?, for id: Memo.ID) {
        guard let index = memos.firstIndex(where: { $0.id == id }) else { return }
        memos[index].color = color
        save()
    }

    func remove(at offsets: IndexSet) {
        memos.remove(atOffsets: offsets)
        save()
    }

    /// 絞り込んだ表示からでも正しいメモを消せるよう、id で削除する
    func remove(ids: [Memo.ID]) {
        let ids = Set(ids)
        memos.removeAll { ids.contains($0.id) }
        save()
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        memos.move(fromOffsets: source, toOffset: destination)
        save()
    }

    private func save() {
        defaults.set(try? JSONEncoder().encode(memos), forKey: key)
    }
}
