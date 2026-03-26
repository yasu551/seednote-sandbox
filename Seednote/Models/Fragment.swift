import Foundation
import SwiftData

@Model
final class Fragment {
    @Attribute(.unique) var id: UUID
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date
    var statusRawValue: String
    var typeRawValue: String?
    var tags: [String]
    var aiSummary: String?
    var aiQuestion: String?
    var aiClaim: String?
    var aiImage: String?
    var aiUseCases: [String]
    
    init(
        id: UUID = UUID(),
        title: String = "",
        body: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        statusRawValue: String = FragmentStatus.unprocessed.rawValue,
        typeRawValue: String? = nil,
        tags: [String] = [],
        aiSummary: String? = nil,
        aiQuestion: String? = nil,
        aiClaim: String? = nil,
        aiImage: String? = nil,
        aiUseCases: [String] = []
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.statusRawValue = statusRawValue
        self.typeRawValue = typeRawValue
        self.tags = tags
        self.aiSummary = aiSummary
        self.aiQuestion = aiQuestion
        self.aiClaim = aiClaim
        self.aiImage = aiImage
        self.aiUseCases = aiUseCases
    }
    
    var status: FragmentStatus {
        FragmentStatus(rawValue: statusRawValue) ?? .unprocessed
    }
    
    var type: FragmentType? {
        guard let raw = typeRawValue else { return nil }
        return FragmentType(rawValue: raw)
    }
}
