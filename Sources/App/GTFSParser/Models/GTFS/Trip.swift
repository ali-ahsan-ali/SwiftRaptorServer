import HummingbirdFluent
import FluentKit

// MARK: - Trip Model

final class Trip: Model, @unchecked Sendable {
    static let schema = "trip"

    @ID(custom: .id)
    var id: String?

    @Field(key: "routeId")
    var routeId: String

    @Field(key: "serviceId")
    var serviceId: String

    @Field(key: "tripId")
    var tripId: String

    @OptionalField(key: "tripHeadsign")
    var tripHeadsign: String?

    @OptionalField(key: "tripShortName")
    var tripShortName: String?

    @OptionalField(key: "directionId")
    var directionId: String?

    @OptionalField(key: "blockId")
    var blockId: String?

    @OptionalField(key: "shapeId")
    var shapeId: String?

    @OptionalField(key: "wheelchairAccessible")
    var wheelchairAccessible: String?

    // Required empty initializer for Fluent
    init() { }

    // Complete initializer for creating new instances
    init(
        id: String? = nil,
        routeId: String,
        serviceId: String,
        tripId: String,
        tripHeadsign: String? = nil,
        tripShortName: String? = nil,
        directionId: String? = nil,
        blockId: String? = nil,
        shapeId: String? = nil,
        wheelchairAccessible: String? = nil
    ) {
        self.id = id
        self.routeId = routeId
        self.serviceId = serviceId
        self.tripId = tripId
        self.tripHeadsign = tripHeadsign
        self.tripShortName = tripShortName
        self.directionId = directionId
        self.blockId = blockId
        self.shapeId = shapeId
        self.wheelchairAccessible = wheelchairAccessible
    }
}

// MARK: - Migration

struct CreateTrip: AsyncMigration {
    /// Prepares the database for storing Trip models.
    /// This function creates the 'trip' schema with all the required fields.
    func prepare(on database: Database) async throws {
        try await database.schema(Trip.schema)
            .id()
            .field("routeId", .string, .required)
            .field("serviceId", .string, .required)
            .field("tripId", .string, .required)
            .field("tripHeadsign", .string)
            .field("tripShortName", .string)
            .field("directionId", .string)
            .field("blockId", .string)
            .field("shapeId", .string)
            .field("wheelchairAccessible", .string)
            .create()
    }

    /// Reverts the database schema changes made in prepare.
    /// This function deletes the 'trip' schema.
    func revert(on database: Database) async throws {
        try await database.schema(Trip.schema).delete()
    }
}
