import HummingbirdFluent
import FluentKit

// MARK: - Stop Model

final class Stop: Model, @unchecked Sendable {
    static let schema = "stop"

    @ID(custom: .id)
    var id: String?

    @OptionalField(key: "stopCode")
    var stopCode: String?

    @OptionalField(key: "stopName")
    var stopName: String?

    @OptionalField(key: "stopDesc")
    var stopDesc: String?

    @OptionalField(key: "stopLat")
    var stopLat: Double?

    @OptionalField(key: "stopLon")
    var stopLon: Double?

    @OptionalField(key: "zoneId")
    var zoneId: String?

    @OptionalField(key: "stopUrl")
    var stopUrl: String?

    @OptionalField(key: "locationType")
    var locationType: Int?

    @OptionalField(key: "parentStation")
    var parentStation: String?

    @OptionalField(key: "stopTimezone")
    var stopTimezone: String?

    @OptionalField(key: "wheelchairBoarding")
    var wheelchairBoarding: Int?

    // An empty initializer is required for Fluent.
    init() { }

    // A complete initializer for creating new instances.
    init(
        id: String? = UUID().uuidString,
        stopCode: String? = nil,
        stopName: String? = nil,
        stopDesc: String? = nil,
        stopLat: Double? = nil,
        stopLon: Double? = nil,
        zoneId: String? = nil,
        stopUrl: String? = nil,
        locationType: Int? = nil,
        parentStation: String? = nil,
        stopTimezone: String? = nil,
        wheelchairBoarding: Int? = nil
    ) {
        self.id = id
        self.stopCode = stopCode
        self.stopName = stopName
        self.stopDesc = stopDesc
        self.stopLat = stopLat
        self.stopLon = stopLon
        self.zoneId = zoneId
        self.stopUrl = stopUrl
        self.locationType = locationType
        self.parentStation = parentStation
        self.stopTimezone = stopTimezone
        self.wheelchairBoarding = wheelchairBoarding
    }
}

// MARK: - Migration

struct CreateStop: AsyncMigration {
    /// Prepares the database for storing Stop models.
    /// This function creates the 'stop' schema with all the required fields.
    func prepare(on database: Database) async throws {
        try await database.schema(Stop.schema)
            .field("id", .string, .identifier(auto: false))
            .field("stopCode", .string)
            .field("stopName", .string)
            .field("stopDesc", .string)
            .field("stopLat", .double)
            .field("stopLon", .double)
            .field("zoneId", .string)
            .field("stopUrl", .string)
            .field("locationType", .int)
            .field("parentStation", .string)
            .field("stopTimezone", .string)
            .field("wheelchairBoarding", .int)
            .create()
    }

    /// Reverts the database schema changes made in prepare.
    /// This function deletes the 'stop' schema.
    func revert(on database: Database) async throws {
        try? await database.schema(Stop.schema).delete()
    }
}
