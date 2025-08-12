import HummingbirdFluent
import FluentKit

final class StopTime: Model, @unchecked Sendable {
    static let schema = "stop_time"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "tripId")
    var tripId: String
    
    @OptionalField(key: "arrivalTime")
    var arrivalTime: String?
    
    @OptionalField(key: "departureTime")
    var departureTime: String?
    
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
    init(id: UUID? = nil, tripId: String, arrivalTime: String? = nil, departureTime: String? = nil, stopId: String? = nil, locationGroupId: String? = nil, locationId: String? = nil, stopSequence: Int, stopHeadsign: String? = nil, pickupType: Int? = nil, dropOffType: Int? = nil, shapeDistTraveled: Double? = nil) {
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