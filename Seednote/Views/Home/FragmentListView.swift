import SwiftUI

struct FragmentListView: View {
    let fragments: [Fragment]
    let onTapAdd: () -> Void

    var body: some View {
        if fragments.isEmpty {
            EmptyStateView(
                title: "断片がありません",
                message: "右上の追加ボタンから最初の断片を作成できます。",
                actionTitle: "断片を追加",
                action: onTapAdd
            )
        } else {
            LazyVStack(spacing: Spacing.md) {
                ForEach(fragments, id: \.id) { fragment in
                    NavigationLink(value: fragment) {
                        FragmentCardView(fragment: fragment)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview("一覧あり") {
    NavigationStack {
        ScrollView {
            FragmentListView(
                fragments: PreviewData.sampleFragments,
                onTapAdd: {}
            )
            .padding()
        }
    }
}

#Preview("空状態") {
    FragmentListView(
        fragments: [],
        onTapAdd: {}
    )
    .padding()
}
