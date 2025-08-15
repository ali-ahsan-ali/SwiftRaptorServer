import Foundation
import HummingbirdFluent
import SwiftTransit

struct GTFSParser {
    private let fluent: Fluent

    init(fluent: Fluent) {
        self.fluent = fluent
    }

    func parseGTFSData(atDirectory directory: URL) async throws {
        _ = try await Feed(
            contentsOfURL: directory,
            addAgency: { agency in
                try await Agency(
                    agencyId: agency.agencyID,
                    agencyName: agency.name,
                    agencyUrl: agency.url.path,
                    agencyTimezone: agency.timeZone.identifier
                )
                .save(on: fluent.db())
            },
            addRoutes: { route in
                try await Route(
                    id: UUID(),
                    routeId: route.routeID,
                    agencyId: route.agencyID,
                    routeShortName: route.shortName,
                    routeLongName: route.name,
                    routeDesc: route.details,
                    routeType: route.type.rawValue,
                    routeUrl: route.url?.absoluteString,
                    routeColor: nil,
                    routeTextColor: nil
                )
                .save(on: fluent.db())
            },
            addStop: { stop in
                try await Stop(
                    id: UUID(),
                    stopId: stop.stopID,
                    stopCode: stop.code,
                    stopName: stop.name,
                    stopDesc: stop.details,
                    stopLat: Double(stop.latitude ?? "0"),
                    stopLon: Double(stop.longitude ?? "0"),
                    zoneId: stop.zoneID,
                    stopUrl: stop.url?.absoluteString,
                    locationType: stop.locationType?.rawValue,
                    parentStation: stop.parentStationID,
                    stopTimezone: stop.timeZone?.identifier,
                    wheelchairBoarding: stop.accessibility?.rawValue
                )
                .save(on: fluent.db())
            },
            addTrip: { trip in
                try await Trip(
                    id: UUID(),
                    routeId: trip.tripID,
                    serviceId: trip.routeID,
                    tripId: trip.serviceID,
                    tripHeadsign: trip.headSign,
                    tripShortName: trip.shortName,
                    directionId: trip.direction,
                    blockId: trip.blockID,
                    shapeId: trip.shapeID,
                    wheelchairAccessible: trip.isAccessible
                )
                .save(on: fluent.db())
            },
            addStopTime: { stopTime in
                try await StopTime(
                    id: UUID(),
                    tripId: stopTime.tripID,
                    arrivalTime: stopTime.arrival,
                    departureTime: stopTime.departure,
                    stopId: stopTime.stopID,
                    stopSequence: stopTime.stopSequenceNumber,
                    stopHeadsign: stopTime.stopHeadingSign,
                    pickupType: stopTime.pickupType,
                    dropOffType: stopTime.dropOffType,
                    shapeDistTraveled: stopTime.distanceTraveledForShape
                )
                .save(on: fluent.db())
            }
        )

        for x in try await StopTime.query(on: fluent.db()).all() {
            print(x)
        }
    }
}
