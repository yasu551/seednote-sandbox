import Foundation
import Testing
@testable import Seednote

struct SeednoteTests {
    @MainActor
    @Test func HomeViewModelは初期状態でPreviewDataの断片一覧を保持する() {
        let viewModel = HomeViewModel()

        #expect(viewModel.filteredFragments.count == PreviewData.sampleFragments.count)
        #expect(viewModel.filteredFragments.map(\.id) == PreviewData.sampleFragments.map(\.id))
    }

    @MainActor
    @Test func HomeViewModelはステータスで断片を絞り込める() {
        let viewModel = HomeViewModel()

        viewModel.selectedFilter = .growing
        viewModel.applyFilters()

        #expect(viewModel.filteredFragments.count == 1)
        #expect(viewModel.filteredFragments.first?.id == PreviewData.processedFragment.id)
    }

    @MainActor
    @Test func HomeViewModelはタイトルと本文とタグを検索対象にする() {
        let viewModel = HomeViewModel()

        viewModel.searchText = "ナビゲーション"
        viewModel.applyFilters()
        let titleMatchedIDs = viewModel.filteredFragments.map(\.id)

        viewModel.searchText = "選び直したつながり"
        viewModel.applyFilters()
        let bodyMatchedIDs = viewModel.filteredFragments.map(\.id)

        viewModel.searchText = "アプリ開発"
        viewModel.applyFilters()
        let tagMatchedIDs = viewModel.filteredFragments.map(\.id)

        #expect(titleMatchedIDs == [PreviewData.processedFragment.id])
        #expect(bodyMatchedIDs == [PreviewData.usedFragment.id])
        #expect(tagMatchedIDs == [PreviewData.processedFragment.id])
    }

    @MainActor
    @Test func HomeViewModelはステータス絞り込みと検索を併用できる() {
        let viewModel = HomeViewModel()

        viewModel.selectedFilter = .used
        viewModel.searchText = "家族"
        viewModel.applyFilters()

        #expect(viewModel.filteredFragments.map(\.id) == [PreviewData.usedFragment.id])
    }

    @MainActor
    @Test func HomeViewModelは一致する断片がなければ空配列になる() {
        let viewModel = HomeViewModel()

        viewModel.selectedFilter = .growing
        viewModel.searchText = "存在しない検索語"
        viewModel.applyFilters()

        #expect(viewModel.filteredFragments.isEmpty)
    }

    @Test func FragmentCardViewはタイトルを優先しsummaryは空なら表示しない() {
        let titledView = FragmentCardView(fragment: PreviewData.processedFragment)
        let untitledFragment = Fragment(
            title: "",
            body: "本文の冒頭を表示したい",
            updatedAt: Date(timeIntervalSince1970: 1_710_000_000),
            aiSummary: nil
        )
        let untitledView = FragmentCardView(fragment: untitledFragment)

        #expect(titledView.displayTitle == PreviewData.processedFragment.title)
        #expect(titledView.displaySummary == PreviewData.processedFragment.aiSummary)
        #expect(untitledView.displayTitle == untitledFragment.body)
        #expect(untitledView.displaySummary == nil)
    }

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

    @Test func PreviewDataのsampleFragmentsには未整理のFragmentが含まれる() {
        #expect(PreviewData.sampleFragments.contains { $0.id == PreviewData.unprocessedFragment.id })
        #expect(PreviewData.unprocessedFragment.status == .unprocessed)
        #expect(PreviewData.unprocessedFragment.aiSummary == nil)
    }

    @Test func PreviewDataのsampleFragmentsにはAI整理済みのFragmentが含まれる() {
        #expect(PreviewData.sampleFragments.contains { $0.id == PreviewData.processedFragment.id })
        #expect(PreviewData.processedFragment.status != .unprocessed)
        #expect(PreviewData.processedFragment.aiSummary?.isEmpty == false)
        #expect(PreviewData.processedFragment.type != nil)
    }

    @Test func PreviewDataのsampleDraftはPreview用Fragmentに紐づく() {
        #expect(PreviewData.sampleDraft.fragmentID == PreviewData.processedFragment.id)
        #expect(PreviewData.sampleFragments.contains { $0.id == PreviewData.sampleDraft.fragmentID })
    }

    @Test func PreviewDataのsampleDraftはtemplateを復元できる() {
        #expect(PreviewData.sampleDraft.template == .essayOutline)
        #expect(PreviewData.sampleDraft.content.isEmpty == false)
    }

    @Test func enumのdisplayNameは日本語を返す() {
        #expect(FragmentStatus.unprocessed.displayName == "未整理")
        #expect(FragmentType.question.displayName == "質問")
        #expect(TemplateType.essayOutline.displayName == "エッセイ骨子")
    }
}
