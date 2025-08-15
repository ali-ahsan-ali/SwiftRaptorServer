import HummingbirdFluent
import FluentKit

// MARK: - Agency Model

final class Agency: Model, @unchecked Sendable {
    static let schema = "agency"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "agencyId")
    var agencyId: String?
    
    @Field(key: "agencyName")
    var agencyName: String
    
    @Field(key: "agencyUrl")
    var agencyUrl: String
    
    @Field(key: "agencyTimezone")
    var agencyTimezone: String
    
    @OptionalField(key: "agencyLang")
    var agencyLang: String?
    
    @OptionalField(key: "agencyPhone")
    var agencyPhone: String?
    
    @OptionalField(key: "agencyFareUrl")
    var agencyFareUrl: String?
    
    @OptionalField(key: "agencyEmail")
    var agencyEmail: String?

    // Required empty initializer for Fluent
    init() { }

    // Complete initializer for creating new instances
    init(id: UUID? = nil, agencyId: String? = nil, agencyName: String, agencyUrl: String, agencyTimezone: String, agencyLang: String? = nil, agencyPhone: String? = nil, agencyFareUrl: String? = nil, agencyEmail: String? = nil) {
        self.id = id
        self.agencyId = agencyId
        self.agencyName = agencyName
        self.agencyUrl = agencyUrl
        self.agencyTimezone = agencyTimezone
        self.agencyLang = agencyLang
        self.agencyPhone = agencyPhone
        self.agencyFareUrl = agencyFareUrl
        self.agencyEmail = agencyEmail
    }
}

// MARK: - Migration

struct CreateAgency: AsyncMigration {
    /// Prepares the database for storing Agency models.
    /// This function creates the 'agency' schema with all the required fields.
    func prepare(on database: Database) async throws {
        try await database.schema(Agency.schema)
            .id()
            .field("agencyId", .string)
            .field("agencyName", .string, .required)
            .field("agencyUrl", .string, .required)
            .field("agencyTimezone", .string, .required)
            .field("agencyLang", .string)
            .field("agencyPhone", .string)
            .field("agencyFareUrl", .string)
            .field("agencyEmail", .string)
            .create()
    }

    /// Reverts the database schema changes made in the prepare method.
    /// This function deletes the 'agency' schema.
    func revert(on database: Database) async throws {
        try await database.schema(Agency.schema).delete()
    }
}
