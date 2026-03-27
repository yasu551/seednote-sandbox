import Foundation
import SwiftData
import Testing
@testable import Seednote

struct SeednoteTests {
    @MainActor
    @Test func SettingsViewModelはFreeプランと残回数の初期表示値を提供する() {
        let viewModel = SettingsViewModel(
            subscriptionService: SettingsTestSubscriptionService(),
            usageLimitService: UsageLimitService()
        )

        #expect(viewModel.subscriptionTier == .free)
        #expect(viewModel.analysisRemaining == 10)
        #expect(viewModel.templateRemaining == 5)
    }

    @MainActor
    @Test func SettingsViewModelは利用後に残回数を再読込できる() {
        let usageLimitService = UsageLimitService()
        let viewModel = SettingsViewModel(
            subscriptionService: SettingsTestSubscriptionService(),
            usageLimitService: usageLimitService
        )

        usageLimitService.consumeAnalysis()
        usageLimitService.consumeTemplate()
        viewModel.refreshUsageLimits()

        #expect(viewModel.analysisRemaining == 9)
        #expect(viewModel.templateRemaining == 4)
    }

    @MainActor
    @Test func FragmentEditorViewModelは編集モードを判定できる() {
        let existingFragment = Fragment(title: "既存", body: "本文")

        let newViewModel = FragmentEditorViewModel()
        let editingViewModel = FragmentEditorViewModel(fragment: existingFragment)

        #expect(newViewModel.isEditing == false)
        #expect(editingViewModel.isEditing == true)
    }

    @MainActor
    @Test func FragmentEditorViewModelは本文が空白のみなら保存できない() {
        let viewModel = FragmentEditorViewModel()
        viewModel.title = "仮タイトル"
        viewModel.body = "  \n "

        let fragment = viewModel.saveFragment()

        #expect(viewModel.canSave == false)
        #expect(fragment == nil)
    }

    @MainActor
    @Test func FragmentEditorViewModelは新規モードで入力内容を保存できる() {
        var savedFragment: Fragment?
        let viewModel = FragmentEditorViewModel { fragment in
            savedFragment = fragment
        }
        viewModel.title = "新規断片"
        viewModel.body = "\n本文です\n"
        viewModel.tagInput = "着想, 朝, UI"

        let fragment = viewModel.saveFragment()

        #expect(fragment != nil)
        #expect(fragment?.title == "新規断片")
        #expect(fragment?.body == "本文です")
        #expect(fragment?.tags == ["着想", "朝", "UI"])
        #expect(savedFragment?.id == fragment?.id)
    }

    @MainActor
    @Test func FragmentEditorViewModelは編集モードで既存断片を更新できる() {
        let fragment = Fragment(
            title: "編集前タイトル",
            body: "編集前本文",
            tags: ["旧タグ"]
        )
        var savedFragment: Fragment?
        let viewModel = FragmentEditorViewModel(fragment: fragment) { saved in
            savedFragment = saved
        }

        #expect(viewModel.screenTitle == "断片を編集")
        #expect(viewModel.title == "編集前タイトル")
        #expect(viewModel.body == "編集前本文")
        #expect(viewModel.tagInput == "旧タグ")

        viewModel.title = "編集後タイトル"
        viewModel.body = "編集後本文"
        viewModel.tagInput = "再考, メモ"

        let updatedFragment = viewModel.saveFragment()

        #expect(updatedFragment?.id == fragment.id)
        #expect(updatedFragment?.title == "編集後タイトル")
        #expect(updatedFragment?.body == "編集後本文")
        #expect(updatedFragment?.tags == ["再考", "メモ"])
        #expect(savedFragment?.id == fragment.id)
    }

    @MainActor
    @Test func FragmentEditorViewModelは保存済み断片にAI整理結果を反映し再試行でも同じ断片を使う() async throws {
        let viewModel = FragmentEditorViewModel(
            aiService: MockAIAnalysisService()
        )
        viewModel.title = "問い"
        viewModel.body = "なぜこの違和感を毎回見逃してしまうのか？"
        viewModel.tagInput = "観察, 問い"

        let savedFragment = viewModel.saveFragment()
        try await viewModel.analyzeFragment(savedFragment!)
        let retriedFragment = viewModel.saveFragment()

        #expect(savedFragment?.aiSummary?.isEmpty == false)
        #expect(savedFragment?.aiQuestion?.isEmpty == false)
        #expect(savedFragment?.aiClaim?.isEmpty == false)
        #expect(savedFragment?.aiImage == "❓")
        #expect(savedFragment?.aiUseCases.count == 3)
        #expect(savedFragment?.type == .question)
        #expect(viewModel.isLoading == false)
        #expect(retriedFragment?.id == savedFragment?.id)
    }

    @MainActor
    @Test func FragmentEditorViewModelはAI整理残回数がなければ分析せずメッセージを出す() async throws {
        let usageLimitService = UsageLimitService()
        for _ in 0..<10 {
            usageLimitService.consumeAnalysis()
        }
        let aiService = TrackingAIAnalysisService()
        let fragment = Fragment(title: "断片", body: "本文")
        let viewModel = FragmentEditorViewModel(
            aiService: aiService,
            usageLimitService: usageLimitService
        )

        try await viewModel.analyzeFragment(fragment)

        #expect(aiService.analyzeCallCount == 0)
        #expect(viewModel.usageLimitMessage == "AI整理の無料回数を使い切りました")
        #expect(usageLimitService.analysisRemaining() == 0)
    }

    @MainActor
    @Test func FragmentDetailViewModelは編集後の断片を反映できる() {
        let fragment = Fragment(
            title: "編集前タイトル",
            body: "編集前本文"
        )
        let editedFragment = Fragment(
            id: fragment.id,
            title: "編集後タイトル",
            body: "編集後本文",
            updatedAt: Date(timeIntervalSince1970: 200),
            statusRawValue: FragmentStatus.growing.rawValue,
            typeRawValue: FragmentType.idea.rawValue,
            tags: ["再考", "メモ"]
        )
        let viewModel = FragmentDetailViewModel(
            fragment: fragment,
            repository: MockFragmentRepository(),
            aiService: MockAIAnalysisService(),
            relatedService: RelatedFragmentService(),
            allFragments: []
        )

        viewModel.applyEditedFragment(editedFragment)

        #expect(viewModel.fragment.title == "編集後タイトル")
        #expect(viewModel.fragment.body == "編集後本文")
        #expect(viewModel.fragment.status == .growing)
        #expect(viewModel.fragment.type == .idea)
        #expect(viewModel.fragment.tags == ["再考", "メモ"])
    }

    @MainActor
    @Test func FragmentDetailViewModelは更新日時を表示用文字列にできる() {
        let updatedAt = Date(timeIntervalSince1970: 1_710_090_000)
        let fragment = Fragment(
            title: "タイトル",
            body: "本文",
            updatedAt: updatedAt
        )
        let viewModel = FragmentDetailViewModel(
            fragment: fragment,
            repository: MockFragmentRepository(),
            aiService: MockAIAnalysisService(),
            relatedService: RelatedFragmentService(),
            allFragments: []
        )

        let text = viewModel.displayDateText

        #expect(text == updatedAt.formattedShort())
    }

    @MainActor
    @Test func FragmentDetailViewModelは削除成功時にtrueを返す() {
        let fragment = Fragment(
            title: "削除対象",
            body: "本文"
        )
        let repository = MockFragmentRepository()
        let viewModel = FragmentDetailViewModel(
            fragment: fragment,
            repository: repository,
            aiService: MockAIAnalysisService(),
            relatedService: RelatedFragmentService(),
            allFragments: []
        )

        let result = viewModel.deleteFragment()

        #expect(result == true)
        #expect(repository.deletedFragment?.id == fragment.id)
    }

    @MainActor
    @Test func FragmentDetailViewModelはAI整理結果を断片へ保存できる() async {
        let fragment = Fragment(
            title: "断片",
            body: "なぜこの違和感を毎回見逃してしまうのか？"
        )
        let repository = MockFragmentRepository()
        let viewModel = FragmentDetailViewModel(
            fragment: fragment,
            repository: repository,
            aiService: MockAIAnalysisService(),
            relatedService: RelatedFragmentService(),
            allFragments: []
        )

        await viewModel.reanalyzeFragment()

        #expect(viewModel.fragment.aiSummary?.isEmpty == false)
        #expect(viewModel.fragment.aiQuestion?.isEmpty == false)
        #expect(viewModel.fragment.aiClaim?.isEmpty == false)
        #expect(viewModel.fragment.aiImage == "❓")
        #expect(viewModel.fragment.aiUseCases.count == 3)
        #expect(viewModel.fragment.type == .question)
        #expect(repository.updatedFragment?.id == fragment.id)
        #expect(viewModel.isLoading == false)
    }

    @MainActor
    @Test func FragmentDetailViewModelはAI整理残回数がなければ再整理しない() async {
        let fragment = Fragment(
            title: "断片",
            body: "本文"
        )
        let usageLimitService = UsageLimitService()
        for _ in 0..<10 {
            usageLimitService.consumeAnalysis()
        }
        let repository = MockFragmentRepository()
        let aiService = TrackingAIAnalysisService()
        let viewModel = FragmentDetailViewModel(
            fragment: fragment,
            repository: repository,
            aiService: aiService,
            relatedService: RelatedFragmentService(),
            allFragments: [],
            usageLimitService: usageLimitService
        )

        await viewModel.reanalyzeFragment()

        #expect(aiService.analyzeCallCount == 0)
        #expect(repository.updatedFragment == nil)
        #expect(viewModel.usageLimitMessage == "AI整理の無料回数を使い切りました")
    }

    @MainActor
    @Test func FragmentDetailViewModelは候補断片から関連断片を読み込める() {
        let fragment = Fragment(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
            title: "対象",
            body: "思考整理と画面設計を進めたい",
            typeRawValue: FragmentType.idea.rawValue,
            tags: ["UI", "設計"]
        )
        let candidate = Fragment(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
            title: "候補",
            body: "画面設計の方向性を整理したい",
            updatedAt: Date(timeIntervalSince1970: 200),
            typeRawValue: FragmentType.idea.rawValue,
            tags: ["UI"]
        )
        let repository = MockFragmentRepository()
        repository.fetchAllResult = [fragment, candidate]

        let viewModel = FragmentDetailViewModel(
            fragment: fragment,
            repository: repository,
            aiService: MockAIAnalysisService(),
            relatedService: RelatedFragmentService(),
            allFragments: []
        )

        #expect(viewModel.relatedFragments.map(\.fragment.id) == [candidate.id])
    }

    @MainActor
    @Test func FragmentDetailViewModelは再利用テンプレートを表示順で返せる() {
        let fragment = Fragment(
            title: "断片",
            body: "本文"
        )
        let viewModel = FragmentDetailViewModel(
            fragment: fragment,
            repository: MockFragmentRepository(),
            aiService: MockAIAnalysisService(),
            relatedService: RelatedFragmentService(),
            allFragments: []
        )

        #expect(viewModel.reuseTemplates == [.essayOutline, .shortStoryCore, .appIdea])
        #expect(viewModel.reuseTemplates.map(\.displayName) == ["エッセイの骨子", "短編の核", "アプリ案"])
    }

    @MainActor
    @Test func GeneratedDraftViewModelはドラフト生成結果を編集用本文へ反映する() async {
        let fragment = Fragment(
            title: "種",
            body: "朝の光で気分が少し変わった"
        )
        let viewModel = GeneratedDraftViewModel(
            fragment: fragment,
            template: .essayOutline,
            aiService: MockAIAnalysisService(),
            repository: MockFragmentRepository(),
            usageLimit: UsageLimitService()
        )

        await viewModel.generateDraft()

        #expect(viewModel.draft.content.isEmpty == false)
        #expect(viewModel.draftContent == viewModel.draft.content)
        #expect(viewModel.draftContent.contains("エッセイ骨子"))
        #expect(viewModel.isLoading == false)
    }

    @MainActor
    @Test func GeneratedDraftViewModelは再利用残回数がなければ生成しない() async {
        let fragment = Fragment(
            title: "種",
            body: "朝の光で気分が少し変わった"
        )
        let usageLimitService = UsageLimitService()
        for _ in 0..<5 {
            usageLimitService.consumeTemplate()
        }
        let aiService = TrackingAIAnalysisService()
        let viewModel = GeneratedDraftViewModel(
            fragment: fragment,
            template: .essayOutline,
            aiService: aiService,
            repository: MockFragmentRepository(),
            usageLimit: usageLimitService
        )

        await viewModel.generateDraft()

        #expect(aiService.generateDraftCallCount == 0)
        #expect(viewModel.draftContent.isEmpty)
        #expect(viewModel.usageLimitMessage == "再利用生成の無料回数を使い切りました")
    }

    @MainActor
    @Test func GeneratedDraftViewModelは生成結果を新規Fragmentとして保存できる() {
        let fragment = Fragment(
            title: "種",
            body: "朝の光で気分が少し変わった"
        )
        let repository = MockFragmentRepository()
        let viewModel = GeneratedDraftViewModel(
            fragment: fragment,
            template: .essayOutline,
            aiService: MockAIAnalysisService(),
            repository: repository,
            usageLimit: UsageLimitService()
        )
        viewModel.draftContent = "エッセイ骨子の下書き"

        let result = viewModel.saveAsNewFragment()

        #expect(result == true)
        #expect(repository.savedFragment?.title == "[エッセイの骨子] 種")
        #expect(repository.savedFragment?.body == "エッセイ骨子の下書き")
        #expect(repository.savedFragment?.statusRawValue == FragmentStatus.unprocessed.rawValue)
    }

    @MainActor
    @Test func GeneratedDraftViewModelは生成結果をクリップボードへコピーできる() {
        let fragment = Fragment(
            title: "種",
            body: "朝の光で気分が少し変わった"
        )
        let clipboardService = MockClipboardService()
        let viewModel = GeneratedDraftViewModel(
            fragment: fragment,
            template: .essayOutline,
            aiService: MockAIAnalysisService(),
            repository: MockFragmentRepository(),
            usageLimit: UsageLimitService(),
            clipboardService: clipboardService
        )
        viewModel.draftContent = "エッセイ骨子の下書き"

        viewModel.copyToClipboard()

        #expect(clipboardService.copiedText == "エッセイ骨子の下書き")
    }

    @Test func RelatedFragmentServiceは自身を除外して関連度順の上位3件を返す() {
        let target = Fragment(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            title: "対象",
            body: "思考整理と画面設計を進めたい",
            updatedAt: Date(timeIntervalSince1970: 100),
            typeRawValue: FragmentType.idea.rawValue,
            tags: ["UI", "設計"]
        )
        let topByTagAndType = Fragment(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            title: "最上位候補",
            body: "画面設計と導線整理を見直したい",
            updatedAt: Date(timeIntervalSince1970: 400),
            typeRawValue: FragmentType.idea.rawValue,
            tags: ["UI", "導線"]
        )
        let topByBody = Fragment(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            title: "本文一致候補",
            body: "思考整理を丁寧に進めたい",
            updatedAt: Date(timeIntervalSince1970: 300),
            tags: ["内省"]
        )
        let thirdByType = Fragment(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            title: "型一致候補",
            body: "別の観点から考える",
            updatedAt: Date(timeIntervalSince1970: 200),
            typeRawValue: FragmentType.idea.rawValue,
            tags: ["メモ"]
        )
        let lowScore = Fragment(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            title: "低関連候補",
            body: "UIの印象を確認する",
            updatedAt: Date(timeIntervalSince1970: 500),
            tags: ["UI"]
        )
        let unrelated = Fragment(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
            title: "無関係候補",
            body: "海辺を散歩した記録",
            updatedAt: Date(timeIntervalSince1970: 600),
            typeRawValue: FragmentType.world.rawValue,
            tags: ["散歩"]
        )
        let service = RelatedFragmentService()

        let related = service.relatedFragments(
            for: target,
            from: [target, lowScore, thirdByType, topByBody, topByTagAndType, unrelated]
        )

        #expect(related.count == 3)
        #expect(related.contains { $0.fragment.id == target.id } == false)
        #expect(related.map(\.fragment.id) == [topByTagAndType.id, topByBody.id, thirdByType.id])
    }

    @Test func AIAnalysisServiceは質問断片を質問向けの分析結果として返す() async throws {
        let service: AIAnalysisServiceProtocol = AIAnalysisService()
        let fragmentText = "なぜこの違和感を毎回見逃してしまうのか？"

        let response = try await service.analyze(fragmentText: fragmentText)

        #expect(response.type == .question)
        #expect(response.summary.isEmpty == false)
        #expect(response.question.isEmpty == false)
        #expect(response.claim.isEmpty == false)
        #expect(response.image == "❓")
        #expect(response.useCases.count == 3)
    }

    @Test func RemoteAIAnalysisServiceは分析レスポンスをドメインモデルへ変換する() async throws {
        let configuration = APIConfiguration(
            baseURL: URL(string: "https://example.com")!,
            apiToken: "token",
            useMockAI: false
        )
        let client = StubAIAPIClient(
            data: """
            {
              "summary": "要約",
              "type": "idea",
              "question": "問い",
              "claim": "主張",
              "image": "📝",
              "useCases": ["用途1", "用途2"]
            }
            """.data(using: .utf8)!,
            response: HTTPURLResponse(
                url: URL(string: "https://example.com/v1/analyze")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
        )
        let service = RemoteAIAnalysisService(configuration: configuration, client: client)

        let response = try await service.analyze(fragmentText: "断片")

        #expect(response.summary == "要約")
        #expect(response.type == .idea)
        #expect(response.question == "問い")
        #expect(response.claim == "主張")
        #expect(response.image == "📝")
        #expect(response.useCases == ["用途1", "用途2"])
    }

    @Test func RemoteAIAnalysisServiceはAPIエラーをUI向けエラーへ変換する() async {
        let configuration = APIConfiguration(
            baseURL: URL(string: "https://example.com")!,
            apiToken: nil,
            useMockAI: false
        )
        let client = StubAIAPIClient(
            data: """
            {
              "error": {
                "message": "rate limited"
              }
            }
            """.data(using: .utf8)!,
            response: HTTPURLResponse(
                url: URL(string: "https://example.com/v1/analyze")!,
                statusCode: 429,
                httpVersion: nil,
                headerFields: nil
            )!
        )
        let service = RemoteAIAnalysisService(configuration: configuration, client: client)

        do {
            _ = try await service.analyze(fragmentText: "断片")
            Issue.record("AIServiceError.httpError が投げられるべき")
        } catch let error as AIServiceError {
            guard case let .httpError(statusCode, message) = error else {
                Issue.record("期待したエラー種別ではない: \(error)")
                return
            }

            #expect(statusCode == 429)
            #expect(message == "rate limited")
            #expect(error.errorDescription == "AI APIエラー(429): rate limited")
        } catch {
            Issue.record("想定外のエラー: \(error)")
        }
    }

    @MainActor
    @Test func AppRouterは設定に応じてMockとRemoteを切り替える() {
        let mockRouter = AppRouter(
            configuration: APIConfiguration(baseURL: nil, apiToken: nil, useMockAI: true)
        )
        let remoteRouter = AppRouter(
            configuration: APIConfiguration(
                baseURL: URL(string: "https://example.com")!,
                apiToken: nil,
                useMockAI: false
            )
        )
        let mockService = mockRouter.aiService as? AIAnalysisService
        let remoteService = remoteRouter.aiService as? AIAnalysisService

        #expect(mockService?.mode == .mock)
        #expect(remoteService?.mode == .remote)
    }

    @MainActor
    @Test func SwiftDataFragmentRepositoryは更新日時の降順で断片を取得できる() throws {
        let container = try makeInMemoryModelContainer()
        let repository = SwiftDataFragmentRepository(modelContext: container.mainContext)
        let olderFragment = Fragment(
            title: "古い更新",
            body: "本文",
            createdAt: Date(timeIntervalSince1970: 100),
            updatedAt: Date(timeIntervalSince1970: 100)
        )
        let newerFragment = Fragment(
            title: "新しい更新",
            body: "本文",
            createdAt: Date(timeIntervalSince1970: 50),
            updatedAt: Date(timeIntervalSince1970: 200)
        )

        try repository.save(olderFragment)
        try repository.save(newerFragment)

        let fragments = try repository.fetchAll()

        #expect(fragments.map(\.id) == [newerFragment.id, olderFragment.id])
    }

    @MainActor
    @Test func HomeViewModelは初期状態でPreviewDataの断片一覧を保持する() {
        let viewModel = HomeViewModel()
        let fragments = viewModel.filteredFragments(from: PreviewData.sampleFragments)

        #expect(fragments.count == PreviewData.sampleFragments.count)
        #expect(fragments.map(\.id) == PreviewData.sampleFragments.map(\.id))
    }

    @MainActor
    @Test func HomeViewModelはステータスで断片を絞り込める() {
        let viewModel = HomeViewModel()

        viewModel.selectedFilter = .growing
        let fragments = viewModel.filteredFragments(from: PreviewData.sampleFragments)

        #expect(fragments.count == 1)
        #expect(fragments.first?.id == PreviewData.processedFragment.id)
    }

    @MainActor
    @Test func HomeViewModelはタイトルと本文とタグを検索対象にする() {
        let viewModel = HomeViewModel()

        viewModel.searchText = "ナビゲーション"
        let titleMatchedIDs = viewModel.filteredFragments(from: PreviewData.sampleFragments).map(\.id)

        viewModel.searchText = "選び直したつながり"
        let bodyMatchedIDs = viewModel.filteredFragments(from: PreviewData.sampleFragments).map(\.id)

        viewModel.searchText = "アプリ開発"
        let tagMatchedIDs = viewModel.filteredFragments(from: PreviewData.sampleFragments).map(\.id)

        #expect(titleMatchedIDs == [PreviewData.processedFragment.id])
        #expect(bodyMatchedIDs == [PreviewData.usedFragment.id])
        #expect(tagMatchedIDs == [PreviewData.processedFragment.id])
    }

    @MainActor
    @Test func HomeViewModelはステータス絞り込みと検索を併用できる() {
        let viewModel = HomeViewModel()

        viewModel.selectedFilter = .used
        viewModel.searchText = "家族"
        let fragments = viewModel.filteredFragments(from: PreviewData.sampleFragments)

        #expect(fragments.map(\.id) == [PreviewData.usedFragment.id])
    }

    @MainActor
    @Test func HomeViewModelは一致する断片がなければ空配列になる() {
        let viewModel = HomeViewModel()

        viewModel.selectedFilter = .growing
        viewModel.searchText = "存在しない検索語"
        let fragments = viewModel.filteredFragments(from: PreviewData.sampleFragments)

        #expect(fragments.isEmpty)
    }

    @MainActor
    @Test func HomeViewModelは渡された断片一覧の順序を維持する() {
        let olderFragment = Fragment(
            title: "古い更新",
            body: "本文",
            updatedAt: Date(timeIntervalSince1970: 100)
        )
        let newerFragment = Fragment(
            title: "新しい更新",
            body: "本文",
            updatedAt: Date(timeIntervalSince1970: 200)
        )
        let viewModel = HomeViewModel()

        let fragments = viewModel.filteredFragments(from: [newerFragment, olderFragment])

        #expect(fragments.map(\.id) == [newerFragment.id, olderFragment.id])
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
        #expect(TemplateType.essayOutline.displayName == "エッセイの骨子")
    }
}

@MainActor
private func makeInMemoryModelContainer() throws -> ModelContainer {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(
        for: Fragment.self,
        GeneratedDraft.self,
        configurations: configuration
    )
}

private final class MockFragmentRepository: FragmentRepositoryProtocol {
    var fetchAllResult: [Fragment] = []
    private(set) var deletedFragment: Fragment?
    private(set) var updatedFragment: Fragment?
    private(set) var savedFragment: Fragment?

    func fetchAll() throws -> [Fragment] { fetchAllResult }
    func save(_ fragment: Fragment) throws {
        savedFragment = fragment
    }
    func delete(_ fragment: Fragment) throws {
        deletedFragment = fragment
    }
    func update(_ fragment: Fragment) throws {
        updatedFragment = fragment
    }
}

private final class MockClipboardService: ClipboardServiceProtocol {
    private(set) var copiedText: String?

    func copy(_ text: String) {
        copiedText = text
    }
}

private final class TrackingAIAnalysisService: AIAnalysisServiceProtocol {
    private(set) var analyzeCallCount = 0
    private(set) var generateDraftCallCount = 0

    func analyze(fragmentText: String) async throws -> AIAnalysisResponse {
        analyzeCallCount += 1
        return AIAnalysisResponse(
            summary: "summary",
            type: .idea,
            question: "question",
            claim: "claim",
            image: "image",
            useCases: []
        )
    }

    func generateDraft(fragmentText: String, template: TemplateType) async throws -> DraftGenerationResponse {
        generateDraftCallCount += 1
        return DraftGenerationResponse(content: "draft")
    }
}

private struct StubAIAPIClient: AIAPIClient {
    let data: Data
    let response: HTTPURLResponse

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        (data, response)
    }
}

private struct SettingsTestSubscriptionService: SubscriptionServiceProtocol {
    let currentTier: SubscriptionTier = .free

    func restorePurchases() async {}

    func purchasePro() async {}
}

// MARK: - Utils Tests

struct StringExtTests {
    @Test func summarizedは指定文字数を超える文字列を省略記号付きで切り詰める() {
        let long = "あいうえおかきくけこさしすせそ"
        #expect(long.summarized(maxLength: 5) == "あいうえお…")
    }

    @Test func summarizedは指定文字数以下の文字列をそのまま返す() {
        let short = "短い"
        #expect(short.summarized(maxLength: 10) == "短い")
    }

    @Test func summarizedはちょうど指定文字数の文字列をそのまま返す() {
        let exact = "12345"
        #expect(exact.summarized(maxLength: 5) == "12345")
    }

    @Test func summarizedは空文字列をそのまま返す() {
        #expect("".summarized(maxLength: 5) == "")
    }
}

struct DateExtTests {
    @Test func relativeFormattedは今日の日付に対して相対表現を返す() {
        let now = Date()
        let result = now.relativeFormatted()
        // RelativeDateTimeFormatter は "0秒前" や "たった今" 等を返す
        #expect(!result.isEmpty)
    }

    @Test func relativeFormattedは過去の日付に対して空でない文字列を返す() {
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let result = threeDaysAgo.relativeFormatted()
        #expect(!result.isEmpty)
    }
}

// MARK: - DesignSystem Tests

struct SpacingTests {
    @Test func Spacingにカード用のdividerWidthが定義されている() {
        #expect(Spacing.dividerWidth == 0.5)
    }

    @Test func SpacingにborderWidthが定義されている() {
        #expect(Spacing.borderWidth == 1.0)
    }

    @Test func SpacingにバッジのpaddinHが定義されている() {
        #expect(Spacing.badgePaddingH == 10.0)
    }

    @Test func SpacingにバッジのpaddingVが定義されている() {
        #expect(Spacing.badgePaddingV == 6.0)
    }

    @Test func SpacingにボタンのbuttonHeightが定義されている() {
        #expect(Spacing.buttonHeight == 48.0)
    }
}
