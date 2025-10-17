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

extension ResourceGroup {
    /// Role in a resource group.
    public enum Role: String, Hashable, CaseIterable, Codable, Sendable {
        /// Admin role.
        case admin
        /// Write role.
        case write
        /// Contributor role.
        case contributor
        /// Read role.
        case read
    }

    /// Auto-join configuration for a resource group.
    public struct AutoJoin: Codable, Sendable {
        /// Whether auto-join is enabled.
        public let enabled: Bool
        /// The role to assign to the user when they join the resource group.
        public let role: Role?
    }
}
