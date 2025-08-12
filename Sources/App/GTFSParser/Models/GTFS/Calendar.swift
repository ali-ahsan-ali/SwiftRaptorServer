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
    @ID(custom: "service_id")
    var serviceId: String?
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