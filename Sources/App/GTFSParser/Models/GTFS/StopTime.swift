import HummingbirdFluent
import FluentKit

// MARK: - StopTime Model

final class StopTime: Model, @unchecked Sendable {
    static let schema = "stop_time"

    @ID(custom: .id)
    var id: String?

    @Field(key: "tripId")
    var tripId: String

    @OptionalField(key: "arrivalTime")
    var arrivalTime: Date?

    @OptionalField(key: "departureTime")
    var departureTime: Date?

    @OptionalField(key: "stopId")
    var stopId: String?

    @OptionalField(key: "locationGroupId")
    var locationGroupId: String?

    @OptionalField(key: "locationId")
    var locationId: String?

    @Field(key: "stopSequence")
    var stopSequence: Int

    @OptionalField(key: "stopHeadsign")
    var stopHeadsign: String?

    @OptionalField(key: "pickupType")
    var pickupType: Int?

    @OptionalField(key: "dropOffType")
    var dropOffType: Int?

    @OptionalField(key: "shapeDistTraveled")
    var shapeDistTraveled: Double?

    // Required empty initializer for Fluent
    init() { }

    // Complete initializer for creating new instances
    init(
        id: String? = UUID().uuidString,
        tripId: String,
        arrivalTime: Date? = nil,
        departureTime: Date? = nil,
        stopId: String? = nil,
        locationGroupId: String? = nil,
        locationId: String? = nil,
        stopSequence: Int,
        stopHeadsign: String? = nil,
        pickupType: Int? = nil,
        dropOffType: Int? = nil,
        shapeDistTraveled: Double? = nil
    ) {
        self.id = id
        self.tripId = tripId
        self.arrivalTime = arrivalTime
        self.departureTime = departureTime
        self.stopId = stopId
        self.locationGroupId = locationGroupId
        self.locationId = locationId
        self.stopSequence = stopSequence
        self.stopHeadsign = stopHeadsign
        self.pickupType = pickupType
        self.dropOffType = dropOffType
        self.shapeDistTraveled = shapeDistTraveled
    }
}

// MARK: - Migration

struct CreateStopTime: AsyncMigration {
    /// Prepares the database for storing StopTime models.
    /// This function creates the 'stop_time' schema with all the required fields.
    func prepare(on database: Database) async throws {
        try await database.schema(StopTime.schema)
            .field("id", .string, .identifier(auto: false))
            .field("tripId", .string, .required)
            .field("arrivalTime", .date)
            .field("departureTime", .date)
            .field("stopId", .string)
            .field("locationGroupId", .string)
            .field("locationId", .string)
            .field("stopSequence", .int, .required)
            .field("stopHeadsign", .string)
            .field("pickupType", .int)
            .field("dropOffType", .int)
            .field("shapeDistTraveled", .double)
            .create()
    }

    /// Reverts the database schema changes made in prepare.
    /// This function deletes the 'stop_time' schema.
    func revert(on database: Database) async throws {
        try? await database.schema(StopTime.schema).delete()
    }
}
