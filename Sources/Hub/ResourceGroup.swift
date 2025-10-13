import Foundation

/// Resource group information for a repository.
public struct ResourceGroup: Codable, Sendable {
    /// Repository name.
    public let name: String

    /// Repository type.
    public let type: String

    /// Repository visibility.
    public let visibility: Repo.Visibility

    /// Who added the repository.
    public let addedBy: String

    private enum CodingKeys: String, CodingKey {
        case name
        case type
        case visibility = "private"
        case addedBy
    }
}

public extension ResourceGroup {
    enum Role: String, Codable, Sendable {
        case admin
        case write
        case contributor
        case read
    }

    struct AutoJoin: Codable, Sendable {
        public let enabled: Bool
        public let role: Role?
    }
}
