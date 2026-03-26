import Foundation
import SwiftData

@Model
final class GeneratedDraft {
    @Attribute(.unique) var id: UUID
    var fragmentID: UUID
    var templateRawValue: String
    var content: String
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        fragmentID: UUID,
        templateRawValue: String,
        content: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.fragmentID = fragmentID
        self.templateRawValue = templateRawValue
        self.content = content
        self.createdAt = createdAt
    }
    
    var template: TemplateType? {
        TemplateType(rawValue: templateRawValue)
    }
}
