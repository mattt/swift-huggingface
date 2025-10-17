import Foundation

/// A namespace for repository-related types and functionality.
public enum Repo {
    // MARK: - Nested Types

    /// An identifier for a repository in the format "namespace/name".
    public struct ID: Hashable, Sendable {
        /// The namespace (user or organization) of the repository.
        public let namespace: String

        /// The name of the repository.
        public let name: String

        /// Creates a repository identifier from namespace and name components.
        ///
        /// - Parameters:
        ///   - namespace: The namespace (user or organization) of the repository.
        ///   - name: The name of the repository.
        public init(namespace: String, name: String) {
            self.namespace = namespace
            self.name = name
        }
    }

    /// The kind of a repository on the Hugging Face Hub.
    public enum Kind: String, Hashable, CaseIterable, CustomStringConvertible, Codable, Sendable {
        /// A model repository.
        case model

        /// A dataset repository.
        case dataset

        /// A space repository.
        case space

        /// The pluralized path component for API endpoints.
        public var pluralized: String {
            switch self {
            case .model:
                return "models"
            case .dataset:
                return "datasets"
            case .space:
                return "spaces"
            }
        }

        public var description: String {
            return rawValue
        }
    }

    /// The visibility of a repository.
    public enum Visibility: Hashable, Codable, Sendable {
        /// A public repository.
        case `public`

        /// A private repository.
        case `private`

        /// Whether the repository is public.
        public var isPublic: Bool {
            self == .public
        }

        /// Whether the repository is private.
        public var isPrivate: Bool {
            self == .private
        }

        // MARK: Codable

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let boolValue = try container.decode(Bool.self)
            self = boolValue ? .private : .public
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(isPrivate)
        }
    }

    /// Settings for a repository.
    public struct Settings: Codable, Sendable {
        /// The visibility of the repository.
        public var visibility: Visibility?

        /// Whether XET storage is enabled.
        public var xetEnabled: Bool?

        /// Whether discussions are disabled.
        public var discussionsDisabled: Bool?

        /// The gated mode for the repository.
        public var gated: GatedMode?

        /// The email for gated access notifications.
        public var gatedNotificationsEmail: String?

        /// The notification mode for gated access ("bulk" or "real-time").
        public var gatedNotificationsMode: String?

        /// Creates repository settings.
        public init(
            visibility: Visibility? = nil,
            xetEnabled: Bool? = nil,
            discussionsDisabled: Bool? = nil,
            gated: GatedMode? = nil,
            gatedNotificationsEmail: String? = nil,
            gatedNotificationsMode: String? = nil
        ) {
            self.visibility = visibility
            self.xetEnabled = xetEnabled
            self.discussionsDisabled = discussionsDisabled
            self.gated = gated
            self.gatedNotificationsEmail = gatedNotificationsEmail
            self.gatedNotificationsMode = gatedNotificationsMode
        }

        private enum CodingKeys: String, CodingKey {
            case visibility = "private"
            case xetEnabled
            case discussionsDisabled
            case gated
            case gatedNotificationsEmail
            case gatedNotificationsMode
        }
    }
}

// MARK: - RawRepresentable

extension Repo.ID: RawRepresentable {
    /// The raw string representation of the repository identifier.
    public typealias RawValue = String

    /// Initializes a `Repo.ID` from a raw string value in the format "namespace/name".
    ///
    /// - Parameter rawValue: The raw value should be in the format `"namespace/name"`.
    public init?(rawValue: RawValue) {
        let components = rawValue.split(separator: "/", maxSplits: 1)
        guard components.count == 2 else {
            return nil
        }
        self.namespace = String(components[0])
        self.name = String(components[1])
    }

    /// Returns the raw string representation of the `Repo.ID` in the format "namespace/name".
    public var rawValue: String {
        return "\(namespace)/\(name)"
    }
}

// MARK: - CustomStringConvertible

extension Repo.ID: CustomStringConvertible {
    /// A textual representation of the `Repo.ID`.
    public var description: String {
        return rawValue
    }
}

// MARK: - ExpressibleByStringLiteral

extension Repo.ID: ExpressibleByStringLiteral {
    /// Initializes a `Repo.ID` from a string literal.
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)!
    }
}

// MARK: - ExpressibleByStringInterpolation

extension Repo.ID: ExpressibleByStringInterpolation {
    /// Initializes a `Repo.ID` from a string interpolation.
    public init(stringInterpolation: DefaultStringInterpolation) {
        self.init(rawValue: stringInterpolation.description)!
    }
}

// MARK: - Codable

extension Repo.ID: Codable {
    /// Decodes a `Repo.ID` from a single string value.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let identifier = Repo.ID(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid Repo.ID string: \(rawValue)"
            )
        }
        self = identifier
    }

    /// Encodes the `Repo.ID` as a single string value.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
