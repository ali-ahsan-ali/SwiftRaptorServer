import HummingbirdFluent
import FluentKit

final class Calendar: Model, @unchecked Sendable {
    init(id: UUID? = nil, serviceId: String, monday: Int, tuesday: Int, wednesday: Int, thursday: Int, friday: Int, saturday: Int, sunday: Int, startDate: String, endDate: String) {
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
    
    init() { }

    static let schema = "Calendar"

    @ID(key: .id)
    var id: UUID?
    @Field(key: "service_id")
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
}

struct CreateCalendar: AsyncMigration {
    // Prepares the database for storing Calendar models.
    func prepare(on database: Database) async throws {
        try await database.schema(Calendar.schema)
            .id()
            .field("service_id", .string, .required)
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

    func revert(on database: Database) async throws {
        try await database.schema(Calendar.schema).delete()
    }
}