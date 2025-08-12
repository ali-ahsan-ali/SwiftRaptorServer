import HummingbirdFluent
import FluentKit

final class Trip: Model, @unchecked Sendable {
    static let schema = "trip"

    @ID(key: .id)
    var id: UUID?

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
    var directionId: Int?

    @OptionalField(key: "blockId")
    var blockId: String?

    @OptionalField(key: "shapeId")
    var shapeId: String?

    @OptionalField(key: "wheelchairAccessible")
    var wheelchairAccessible: Int?

    // Required empty initializer for Fluent
    init() { }

    // Complete initializer for creating new instances
    init(id: UUID? = nil, routeId: String, serviceId: String, tripId: String, tripHeadsign: String? = nil, tripShortName: String? = nil, directionId: Int? = nil, blockId: String? = nil, shapeId: String? = nil, wheelchairAccessible: Int? = nil) {
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