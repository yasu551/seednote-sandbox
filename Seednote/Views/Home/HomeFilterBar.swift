import SwiftUI

struct HomeFilterBar: View {
    @Binding var selectedStatus: FragmentStatus?

    var body: some View {
        Picker("フィルタ", selection: $selectedStatus) {
            Text("すべて").tag(Optional<FragmentStatus>.none)
            Text(FragmentStatus.unprocessed.displayName).tag(Optional(FragmentStatus.unprocessed))
            Text(FragmentStatus.growing.displayName).tag(Optional(FragmentStatus.growing))
            Text(FragmentStatus.used.displayName).tag(Optional(FragmentStatus.used))
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    HomeFilterBarPreview()
        .padding()
}

private struct HomeFilterBarPreview: View {
    @State private var selectedStatus: FragmentStatus? = .growing

    var body: some View {
        HomeFilterBar(selectedStatus: $selectedStatus)
    }
}
