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
                do {
                    try await Agency(
                        id: agency.agencyID,
                        agencyName: agency.name,
                        agencyUrl: agency.url.path,
                        agencyTimezone: agency.timeZone.identifier
                    )
                    .save(on: fluent.db())
                } catch {
                    logger.error("Failed to save agency \(agency.agencyID ?? "NO ID"): \(error.localizedDescription)")
                    throw error
                }
            },
            addRoutes: { route in
                do {
                    try await Route(
                        id: route.routeID,
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
                } catch {
                    logger.error("Failed to save route \(route.routeID): \(error.localizedDescription)")
                    throw error
                }
            },
            addStop: { stop in
                do {
                    try await Stop(
                        id: stop.stopID,
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
                } catch {
                    logger.error("Failed to save stop \(stop.stopID): \(error.localizedDescription)")
                    throw error
                }
            },
            addTrip: { trip in
                do {
                    try await Trip(
                        id: trip.tripID,
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
                } catch {
                    logger.error("Failed to save trip \(trip.tripID): \(error.localizedDescription)")
                    throw error
                }
            },
            addStopTime: { stopTime in
                do {
                    try await StopTime(
                        id: stopTime.tripID
                            + (stopTime.arrival?.description ?? "")
                            + (stopTime.departure?.description ?? "")
                            + stopTime.stopID,
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
                } catch {
                    logger.error("Failed to save stop time for trip \(stopTime.tripID): \(error.localizedDescription)")
                    throw error
                }
            }
        )
        print("GTFS data parsed and saved successfully.")
    }
}
