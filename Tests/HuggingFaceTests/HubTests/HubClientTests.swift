import Foundation
import Testing

@testable import Hub

@Suite("Hub Client Tests")
struct HubClientTests {
    @Test("Client can be initialized with default configuration")
    func testDefaultClientInitialization() {
        let client = Client.default
        #expect(client.host == URL(string: "https://huggingface.co/")!)
        #expect(client.userAgent == nil)
        #expect(client.bearerToken == nil)
    }

    @Test("Client can be initialized with custom configuration")
    func testCustomClientInitialization() {
        let host = URL(string: "https://huggingface.co")!
        let userAgent = "TestApp/1.0"
        let bearerToken = "test_token"

        let client = Client(
            host: host,
            userAgent: userAgent,
            bearerToken: bearerToken
        )

        #expect(client.host.absoluteString.hasPrefix(host.absoluteString))
        #expect(client.userAgent == userAgent)
        #expect(client.bearerToken == bearerToken)
    }

    @Test("Client normalizes host URL with trailing slash")
    func testHostNormalization() {
        let hostWithoutSlash = URL(string: "https://huggingface.co")!
        let client = Client(host: hostWithoutSlash)

        #expect(client.host.path.hasSuffix("/"))
    }
}
