import Foundation

protocol AIAPIClient {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}
