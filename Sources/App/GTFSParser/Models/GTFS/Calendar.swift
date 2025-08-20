import HummingbirdFluent
import FluentKit

// MARK: - Calendar Model

final class Calendar: Model, @unchecked Sendable {
    static let schema = "calendar"

    @ID(custom: .id)
    var id: String?

    @Field(key: "serviceId")
    var serviceId: String

    @Field(key: "monday")
    var monday: Int

    @Field(key: "tuesday")
    var tuesday: Int

    @Field(key: "wednesday")
    var wednesday: Int

    @Field(key: "thursday")
    var thursday: Int

    @Field(key: "friday")
    var friday: Int

    @Field(key: "saturday")
    var saturday: Int

    @Field(key: "sunday")
    var sunday: Int

    @Field(key: "startDate")
    var startDate: String

    @Field(key: "endDate")
    var endDate: String

    // Required empty initializer for Fluent
    init() { }

    // Complete initializer for creating new instances
    init(
        id: String? = nil,
        serviceId: String,
        monday: Int,
        tuesday: Int,
        wednesday: Int,
        thursday: Int,
        friday: Int,
        saturday: Int,
        sunday: Int,
        startDate: String,
        endDate: String
    ) {
        self.id = id
        self.serviceId = serviceId
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
        self.startDate = startDate
        self.endDate = endDate
    }
}

// MARK: - Migration

struct CreateCalendar: AsyncMigration {
    /// Prepares the database for storing Calendar models.
    /// This function creates the 'calendar' schema with all the required fields.
    func prepare(on database: Database) async throws {
        try await database.schema(Calendar.schema)
            .id()
            .field("serviceId", .string, .required)
            .field("monday", .int, .required)
            .field("tuesday", .int, .required)
            .field("wednesday", .int, .required)
            .field("thursday", .int, .required)
            .field("friday", .int, .required)
            .field("saturday", .int, .required)
            .field("sunday", .int, .required)
            .field("startDate", .string, .required)
            .field("endDate", .string, .required)
            .create()
    }

    /// Reverts the database schema changes made in the prepare method.
    /// This function deletes the 'calendar' schema.
    func revert(on database: Database) async throws {
        try await database.schema(Calendar.schema).delete()
    }
}
