import Foundation
import UIKit

class ClipboardService {
    static func copy(_ text: String) {
        UIPasteboard.general.string = text
    }
}
