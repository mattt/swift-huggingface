import Foundation
import Testing

@testable import Hub

@Suite("Repo.Kind Tests")
struct RepoKindTests {
    @Test("Repo.Kind has correct raw values")
    func testRepoKindRawValues() {
        #expect(Repo.Kind.model.rawValue == "model")
        #expect(Repo.Kind.dataset.rawValue == "dataset")
        #expect(Repo.Kind.space.rawValue == "space")
    }

    @Test("Repo.Kind has correct pluralized values")
    func testRepoKindPluralizedValues() {
        #expect(Repo.Kind.model.pluralized == "models")
        #expect(Repo.Kind.dataset.pluralized == "datasets")
        #expect(Repo.Kind.space.pluralized == "spaces")
    }
}
