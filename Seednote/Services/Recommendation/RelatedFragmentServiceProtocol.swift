import Foundation

protocol RelatedFragmentServiceProtocol {
    func relatedFragments(for fragment: Fragment, from fragments: [Fragment]) -> [RelatedFragment]
}
