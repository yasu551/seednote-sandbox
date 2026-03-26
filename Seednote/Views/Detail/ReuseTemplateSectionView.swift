import SwiftUI

struct ReuseTemplateSectionView: View {
    let templates: [TemplateType]
    let onSelect: (TemplateType) -> Void

    var body: some View {
        SectionCardView(title: "再利用テンプレート") {
            VStack(spacing: Spacing.sm) {
                ForEach(templates, id: \.self) { template in
                    Button {
                        onSelect(template)
                    } label: {
                        HStack(spacing: Spacing.sm) {
                            Text(template.displayName)
                                .font(Typography.body)
                                .foregroundColor(Colors.text)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Colors.textTertiary)
                        }
                        .padding(.horizontal, Spacing.md)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Colors.background)
                        .overlay {
                            RoundedRectangle(cornerRadius: Spacing.cornerRadius, style: .continuous)
                                .stroke(Colors.divider, lineWidth: 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: Spacing.cornerRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            ReuseTemplateSectionView(
                templates: [.essayOutline, .shortStoryCore, .appIdea],
                onSelect: { _ in }
            )
            .padding()
        }
    }
}
