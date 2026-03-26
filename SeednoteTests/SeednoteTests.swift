import Foundation
import Testing
@testable import Seednote

struct SeednoteTests {
    @Test func Fragmentの初期ステータスは未整理である() {
        let fragment = Fragment()

        #expect(fragment.status == .unprocessed)
    }

    @Test func FragmentのtypeRawValueがnilならtypeもnilである() {
        let fragment = Fragment(typeRawValue: nil)

        #expect(fragment.type == nil)
    }

    @Test func FragmentのrawValueからstatusとtypeを復元できる() {
        let fragment = Fragment(
            statusRawValue: FragmentStatus.growing.rawValue,
            typeRawValue: FragmentType.idea.rawValue
        )

        #expect(fragment.status == .growing)
        #expect(fragment.type == .idea)
    }

    @Test func GeneratedDraftのtemplateRawValueからtemplateを復元できる() {
        let draft = GeneratedDraft(
            fragmentID: UUID(),
            templateRawValue: TemplateType.appIdea.rawValue
        )

        #expect(draft.template == TemplateType.appIdea)
    }

    @Test func enumのdisplayNameは日本語を返す() {
        #expect(FragmentStatus.unprocessed.displayName == "未整理")
        #expect(FragmentType.question.displayName == "質問")
        #expect(TemplateType.essayOutline.displayName == "エッセイ骨子")
    }
}
