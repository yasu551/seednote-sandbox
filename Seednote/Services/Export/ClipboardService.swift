import Foundation
import UIKit

protocol ClipboardServiceProtocol {
    func copy(_ text: String)
}

final class ClipboardService: ClipboardServiceProtocol {
    static let shared = ClipboardService()

    private init() {}

    static func copy(_ text: String) {
        shared.copy(text)
    }

    func copy(_ text: String) {
        UIPasteboard.general.string = text
    }
}
