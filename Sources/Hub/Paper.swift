import Foundation

/// Information about a paper on the Hub.
public struct Paper: Identifiable, Codable, Sendable {
    /// The paper's unique identifier.
    public let id: String

    /// The paper's title.
    public let title: String?

    /// The paper's authors.
    public let authors: [String]?

    /// The paper's summary/abstract.
    public let summary: String?

    /// The date the paper was published.
    public let publishedAt: Date?

    /// The date the paper was updated.
    public let updatedAt: Date?

    /// The URL to the paper.
    public let url: String?

    /// The arXiv ID of the paper.
    public let arXivID: String?

    /// The number of upvotes.
    public let upvotes: Int?

    /// Whether the paper is featured.
    public let isFeatured: Bool?

    /// Associated models with this paper.
    public let models: [String]?

    /// Associated datasets with this paper.
    public let datasets: [String]?

    /// Associated spaces with this paper.
    public let spaces: [String]?

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case authors
        case summary
        case publishedAt = "published"
        case updatedAt = "updated"
        case url
        case arXivID = "arxiv_id"
        case upvotes
        case isFeatured = "featured"
        case models
        case datasets
        case spaces
    }
}

// MARK: -

/// Information about a daily paper submission on the Hub.
public struct DailyPaper: Codable, Sendable {
    /// The paper information.
    public let paper: Paper

    /// The date this was published as a daily paper.
    public let publishedAt: Date

    /// The title of the daily paper.
    public let title: String

    /// The summary of the daily paper.
    public let summary: String

    /// Media URLs associated with the daily paper.
    public let mediaUrls: [String]?

    /// Thumbnail URL for the daily paper.
    public let thumbnail: String

    /// Number of comments on the daily paper.
    public let numberOfComments: Int

    /// User who submitted this as a daily paper.
    public let submittedBy: User

    /// Whether the author is participating in the discussion.
    public let isAuthorParticipating: Bool
}
