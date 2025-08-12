import AsyncHTTPClient
import Hummingbird
import NIOHTTP1

final class NSWTransportMetroClient: Sendable {
    private let baseURL = "https://api.transport.nsw.gov.au/v2/gtfs/schedule/metro"
    
    init() {
    }
    
    func fetchGTFSData() async throws -> HTTPClientResponse{
        let environment = Environment()

        let headers = HTTPHeaders([("Accept", "application/octet-stream"), ("Authorization", environment.get("API_KEY")!)])
        var request = HTTPClientRequest(url: baseURL)
        request.headers = headers
        let response =  try await HTTPClient.shared.execute(request, timeout: .seconds(30))
        return response
    }

    func shutdown() async throws {
    }
}