import AppAPI
import OpenAPIRuntime

struct SwiftRaptor: APIProtocol {
    func getHello(_ input: AppAPI.Operations.GetHello.Input) async throws -> AppAPI.Operations.GetHello.Output {
        return .ok(.init(body: .plainText("Hello!")))
    }
}
