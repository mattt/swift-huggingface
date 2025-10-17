import Foundation

public enum Billing {
    /// Organization billing usage response.
    public struct Usage: Codable, Sendable {
        /// Individual billing usage item.
        public struct LineItem: Codable, Sendable {
            /// Entity ID.
            public let entityID: String

            /// Label for the usage item.
            public let label: String?

            /// Product identifier.
            public let product: String

            /// Quantity used.
            public let quantity: Double

            /// When usage started.
            public let startedAt: Date?

            /// When usage stopped (null if still active).
            public let stoppedAt: Date?

            /// Whether this was a free grant.
            public let isFreeGrant: Bool?

            /// Pretty name for the product.
            public let productPrettyName: String

            /// Unit label.
            public let unitLabel: String?

            /// Total cost in micro USD.
            public let totalCostMicroUSD: Double

            /// Unit cost in micro USD.
            public let unitCostMicroUSD: Double

            /// Whether the usage is currently active.
            public let active: Bool

            private enum CodingKeys: String, CodingKey {
                case entityID = "entityId"
                case label
                case product
                case quantity
                case startedAt
                case stoppedAt
                case isFreeGrant = "freeGrant"
                case productPrettyName
                case unitLabel
                case totalCostMicroUSD
                case unitCostMicroUSD
                case active
            }
        }

        /// Usage information by category.
        public let usage: [String: [Usage.LineItem]]

        /// Period information.
        public let period: Period
    }

    /// Billing period information.
    public struct Period: Identifiable, Codable, Sendable {
        /// Period ID.
        public let id: String

        /// Billing entity information.
        public let entity: Entity

        /// Billing period as a closed range.
        public let dateRange: ClosedRange<Date>

        /// Invoice information.
        public let invoice: Invoice?

        /// Charges for this period.
        public let charges: [Charge]?

        /// Entity associated with the billing period.
        public struct Entity: Sendable {
            public enum Kind: String, CaseIterable, Hashable, Codable, Sendable {
                case user
                case organization = "org"
            }

            public let id: String
            public let kind: Kind
            public let name: String
        }

        private enum CodingKeys: String, CodingKey {
            case id = "_id"
            case entityID = "entityId"
            case entityType
            case entityName
            case periodStart
            case periodEnd
            case invoice
            case charges
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.id = try container.decode(String.self, forKey: .id)

            let decodedEntityId = try container.decode(String.self, forKey: .entityID)
            let decodedEntityKind = try container.decode(Entity.Kind.self, forKey: .entityType)
            let decodedEntityName = try container.decode(String.self, forKey: .entityName)
            self.entity = Entity(id: decodedEntityId, kind: decodedEntityKind, name: decodedEntityName)

            let start = try container.decode(Date.self, forKey: .periodStart)
            let end = try container.decode(Date.self, forKey: .periodEnd)
            self.dateRange = start ... end

            self.invoice = try container.decodeIfPresent(Invoice.self, forKey: .invoice)
            self.charges = try container.decodeIfPresent([Charge].self, forKey: .charges)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(entity.id, forKey: .entityID)
            try container.encode(entity.kind, forKey: .entityType)
            try container.encode(entity.name, forKey: .entityName)
            try container.encode(dateRange.lowerBound, forKey: .periodStart)
            try container.encode(dateRange.upperBound, forKey: .periodEnd)
            try container.encode(invoice, forKey: .invoice)
            try container.encode(charges, forKey: .charges)
        }
    }

    /// Billing invoice information.
    public struct Invoice: Identifiable, Codable, Sendable {
        /// Invoice type.
        public let type: String

        /// Invoice ID.
        public let id: String

        /// Amount due in cents (for Stripe invoices).
        public let amountDueCents: Int?

        /// Total amount in cents (for Stripe invoices).
        public let totalCents: Int?

        /// Invoice status (for Stripe invoices).
        public let status: String?

        /// Due date (for Stripe invoices).
        public let dueDate: Date?

        /// Collection method (for Stripe invoices).
        public let collectionMethod: String?
    }

    /// Billing charge information.
    public struct Charge: Identifiable, Codable, Sendable {
        /// Charge ID.
        public let id: String

        /// When the charge was created.
        public let createdAt: Date

        /// Due date for the charge.
        public let dueDate: Date

        /// Usage cost at charge time in micro USD.
        public let usageAtChargeTimeMicroUSD: Double

        /// Amount in cents.
        public let amountCents: Int

        /// How the charge was billed.
        public let billedThrough: String

        /// Payment intent ID.
        public let paymentIntentID: String

        /// Payment intent status.
        public let paymentIntentStatus: String

        private enum CodingKeys: String, CodingKey {
            case id = "_id"
            case createdAt
            case dueDate
            case usageAtChargeTimeMicroUSD
            case amountCents
            case billedThrough
            case paymentIntentID = "paymentIntentId"
            case paymentIntentStatus
        }
    }
}
