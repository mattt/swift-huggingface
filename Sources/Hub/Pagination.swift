import Foundation

/// Sort direction for list queries.
public enum SortDirection: Int, Hashable, Sendable {
    /// Ascending order.
    case ascending = 1

    /// Descending order.
    case descending = -1
}

/// A response that includes pagination information from Link headers.
public struct PaginatedResponse<T: Decodable & Sendable>: Sendable {
    /// The items in the current page.
    public let items: [T]

    /// The URL for the next page, if available.
    public let nextURL: URL?

    /// Creates a paginated response.
    ///
    /// - Parameters:
    ///   - items: The items in the current page.
    ///   - nextURL: The URL for the next page, if available.
    public init(items: [T], nextURL: URL?) {
        self.items = items
        self.nextURL = nextURL
    }
}

// MARK: -

extension HTTPURLResponse {
    /// Parses the Link header to extract the next page URL.
    ///
    /// The Link header format follows RFC 8288: `<url>; rel="next"`
    ///
    /// - Returns: The URL for the next page, or `nil` if not found.
    func nextPageURL() -> URL? {
        guard let linkHeader = value(forHTTPHeaderField: "Link") else {
            return nil
        }

        // Parse Link header format: <https://example.com/page2>; rel="next"
        let links = linkHeader.components(separatedBy: ",")
        for link in links {
            let components = link.components(separatedBy: ";")
            guard components.count >= 2 else { continue }

            let urlPart = components[0].trimmingCharacters(in: .whitespaces)
            let relPart = components[1].trimmingCharacters(in: .whitespaces)

            // Check if this is the "next" link
            if relPart.contains("rel=\"next\"") || relPart.contains("rel='next'") {
                // Extract URL from angle brackets
                let urlString = urlPart.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
                if let url = URL(string: urlString) {
                    return url
                }
            }
        }

        return nil
    }
}
