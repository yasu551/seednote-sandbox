import SwiftUI

struct RelatedFragmentsSectionView: View {
    let relatedFragments: [RelatedFragment]

    var body: some View {
        if !relatedFragments.isEmpty {
            SectionCardView(title: "関連する断片") {
                VStack(spacing: Spacing.md) {
                    ForEach(relatedFragments, id: \.id) { relatedFragment in
                        NavigationLink(destination: FragmentDetailView(fragment: relatedFragment.fragment)) {
                            FragmentCardView(fragment: relatedFragment.fragment)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    let relatedFragments = RelatedFragmentService().relatedFragments(
        for: PreviewData.processedFragment,
        from: PreviewData.sampleFragments
    )

    NavigationStack {
        ScrollView {
            RelatedFragmentsSectionView(relatedFragments: relatedFragments)
                .padding()
        }
    }
}
