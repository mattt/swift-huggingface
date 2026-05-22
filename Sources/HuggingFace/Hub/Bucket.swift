#if HUGGINGFACE_ENABLE_XET

    import Foundation

    /// A namespace for bucket-related types and functionality.
    ///
    /// Buckets are a non-versioned object-storage repo type on the Hub. They sit
    /// alongside models/datasets/spaces rather than being a fourth `Repo.Kind`
    /// case, because their data model differs in load-bearing ways: no `revision`
    /// dimension, content is Xet-addressed (every file carries an `xet_hash`),
    /// and the endpoint layout is `/api/buckets/{id}` rather than the
    /// `/api/{type}s/{namespace}/{name}` pattern shared by the other kinds.
    ///
    /// Because file content is fundamentally Xet-content-addressed, the entire
    /// bucket surface is gated behind the `Xet` package trait — without Xet, the
    /// types in this namespace and the methods on `HubClient` are absent.
    public enum Bucket {
        // MARK: - Identifier

        /// An identifier for a bucket in the format `"namespace/name"`.
        ///
        /// Some endpoints take the full `{namespace}/{name}` as a single path
        /// component; others (notably `createBucket`) take the two halves
        /// separately. Both forms are exposed here for convenience.
        public struct ID: Hashable, Sendable, CustomStringConvertible {
            /// The namespace (user or organization) that owns the bucket.
            public let namespace: String

            /// The bucket's name within its namespace.
            public let name: String

            public init(namespace: String, name: String) {
                self.namespace = namespace
                self.name = name
            }

            /// Parse a bucket identifier of the form `"namespace/name"`.
            ///
            /// - Returns: A parsed identifier, or `nil` if `rawValue` doesn't
            ///   match the `namespace/name` shape (exactly one `/`, non-empty
            ///   halves).
            public init?(rawValue: String) {
                let parts = rawValue.split(separator: "/", omittingEmptySubsequences: false)
                guard parts.count == 2, !parts[0].isEmpty, !parts[1].isEmpty else { return nil }
                self.namespace = String(parts[0])
                self.name = String(parts[1])
            }

            /// The `"namespace/name"` form used in URL path components.
            public var rawValue: String { "\(namespace)/\(name)" }

            public var description: String { rawValue }
        }

        // MARK: - Metadata

        /// Information about a bucket on the Hub, returned by
        /// ``HubClient/bucketInfo(_:)`` and ``HubClient/listBuckets(namespace:search:)``.
        public struct Info: Codable, Hashable, Sendable {
            /// The bucket's full identifier, `"namespace/name"`.
            public let id: String

            /// Whether the bucket is private.
            public let isPrivate: Bool

            /// When the bucket was created.
            public let createdAt: Date

            /// Total size of the bucket in bytes.
            public let size: Int64

            /// Number of files in the bucket.
            public let totalFiles: Int

            private enum CodingKeys: String, CodingKey {
                case id
                case isPrivate = "private"
                case createdAt
                case size
                case totalFiles
            }
        }

        // MARK: - URL

        /// A parsed bucket URL on the Hub. Returned by ``HubClient/createBucket(_:visibility:resourceGroupId:region:existOk:)``.
        public struct URL: Hashable, Sendable {
            /// The full URL, e.g. `"https://huggingface.co/buckets/user/my-bucket"`.
            public let url: String

            /// Hub endpoint (usually `"https://huggingface.co"`).
            public let endpoint: String

            /// The bucket's namespace (user or organization).
            public let namespace: String

            /// The bucket's full identifier, `"namespace/name"`.
            public let bucketID: String

            /// The bucket as a `hf://buckets/{namespace}/{name}` URI string.
            public var uri: String { "hf://buckets/\(bucketID)" }
        }

        // MARK: - Tree entries

        /// An entry in a bucket's tree listing — either a file or a folder.
        ///
        /// The Hub returns a mixed stream of files and folders for non-recursive
        /// listings; this enum discriminates on the `type` field.
        public enum TreeEntry: Sendable, Hashable, Decodable {
            case file(File)
            case folder(Folder)

            /// The path of this entry within the bucket.
            public var path: String {
                switch self {
                case .file(let f): return f.path
                case .folder(let f): return f.path
                }
            }

            private enum DiscriminatorKeys: String, CodingKey { case type }

            public init(from decoder: Decoder) throws {
                let kindContainer = try decoder.container(keyedBy: DiscriminatorKeys.self)
                let type = try kindContainer.decode(String.self, forKey: .type)
                let single = try decoder.singleValueContainer()
                switch type {
                case "file":
                    self = .file(try single.decode(File.self))
                case "directory":
                    self = .folder(try single.decode(Folder.self))
                default:
                    throw DecodingError.dataCorruptedError(
                        forKey: .type,
                        in: kindContainer,
                        debugDescription: "Unknown bucket tree entry type '\(type)' (expected 'file' or 'directory')"
                    )
                }
            }
        }

        /// A file in a bucket.
        public struct File: Codable, Hashable, Sendable {
            /// Discriminator: always `"file"`.
            public let type: String

            /// The file's path within the bucket.
            public let path: String

            /// File size in bytes.
            public let size: Int64

            /// Content-addressed Xet hash. Always present (buckets are Xet-only).
            public let xetHash: String

            /// Last-modified time, if known.
            public let mtime: Date?

            /// When the file was uploaded to the bucket, if known.
            public let uploadedAt: Date?

            private enum CodingKeys: String, CodingKey {
                case type
                case path
                case size
                case xetHash
                case mtime
                case uploadedAt
            }
        }

        /// A folder in a bucket.
        public struct Folder: Codable, Hashable, Sendable {
            /// Discriminator: always `"directory"`.
            public let type: String

            /// The folder's path within the bucket.
            public let path: String

            /// When the folder was last touched, if known.
            public let uploadedAt: Date?
        }

        /// Metadata for a single bucket file: size + Xet hash. Returned by
        /// ``HubClient/getBucketPathsInfo(_:paths:)`` and similar.
        public struct FileMetadata: Codable, Hashable, Sendable {
            public let size: Int64
            public let xetHash: String
        }

        // MARK: - Region (create-bucket option)

        /// Optional cloud region for bucket creation. Requires Team plan or above.
        public enum Region: String, Codable, Sendable, CaseIterable {
            case us
            case eu
        }
    }

#endif  // HUGGINGFACE_ENABLE_XET
