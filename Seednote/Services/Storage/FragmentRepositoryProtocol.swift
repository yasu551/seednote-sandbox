import Foundation

protocol FragmentRepositoryProtocol {
    func fetchAll() throws -> [Fragment]
    func save(_ fragment: Fragment) throws
    func delete(_ fragment: Fragment) throws
    func update(_ fragment: Fragment) throws
}
