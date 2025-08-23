//
// Transit.swift
//

import Foundation

/// - Tag: TransitID
public typealias TransitID = String

/// - Tag: KeyPathVending
internal protocol KeyPathVending {
  var path: AnyKeyPath { get }
}

/// - Tag: TransitError
public enum TransitError: Error, Sendable {
  case emptySubstring
  case commaExpected
  case quoteExpected
  case invalidFieldType
  case missingRequiredFields
  case headerRecordMismatch
  case invalidColor
}

extension TransitError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .emptySubstring:
      return "Substring is empty"
    case .commaExpected:
      return "A comma was expected, but not found"
    case .quoteExpected:
      return "A quote was expected, but not found"
    case .invalidFieldType:
      return "An invalid field type was found"
    case .missingRequiredFields:
      return "One or more required fields is missing"
    case .headerRecordMismatch:
      return "The number of header and data fields are not the same"
    case .invalidColor:
      return "An invalid color was found"
    }
  }
}

/// - Tag: TransitAssignError
public enum TransitAssignError: Error, Sendable {
  case invalidPath
  case invalidValue
}

extension TransitAssignError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .invalidPath:
      return "Path is invalid"
    case .invalidValue:
      return "Could not value convert to target type"
    }
  }
}

/// - Tag: TransitSomethingError
public enum TransitSomethingError: Error, Sendable {
  case noDataRecordsFound
}

/// - Tag: Feed
public struct Feed: Identifiable {
  public let id = UUID()
  public var agencies: Agencies
  public var routes: Routes
  public var stops: Stops
  public var trips: Trips
  public var stopTimes: StopTimes

  public var agency: Agency {
    return agencies[ 0 ]
  }

  public init(
    contentsOfURL url: URL,
    addAgency: @escaping @Sendable (Agency) async throws -> Void,
    addRoutes: @escaping @Sendable (Route) async throws -> Void,
    addStop: @escaping @Sendable (Stop) async throws -> Void,
    addTrip: @escaping @Sendable (Trip) async throws -> Void,
    addStopTime: @escaping @Sendable (StopTime) async throws -> Void
  ) async throws {
      let (agencies, routes, stops, trips, stopTimes) = try await withThrowingTaskGroup(of: (String, any Sendable).self) { group in
        group.addTask {
            let agencyFileURL: URL = url.appendingPathComponent("agency.txt")
            let agencies = try await Agencies(from: agencyFileURL, addAgency)
            return ("agencies", agencies)
        }
        
        group.addTask {
            let routesFileURL = url.appendingPathComponent("routes.txt")
            let routes = try await Routes(from: routesFileURL, addRoutes)
            return ("routes", routes)
        }
        
        group.addTask {
            let stopsFileURL = url.appendingPathComponent("stops.txt")
            let stops = try await Stops(from: stopsFileURL, addStop)
            return ("stops", stops)
        }
        
        group.addTask {
            let tripsFileURL = url.appendingPathComponent("trips.txt")
            let trips = try await Trips(from: tripsFileURL, addTrip)
            return ("trips", trips)
        }
        
        group.addTask {
            let stopTimesFileURL = url.appendingPathComponent("stop_times.txt")
            let stopTimes = try await StopTimes(from: stopTimesFileURL, addStopTime)
            return ("stopTimes", stopTimes)
        }
        
        var results: [String: Any] = [:]
        for try await (key, value) in group {
            results[key] = value
        }
        
        return (
            results["agencies"] as! Agencies,
            results["routes"] as! Routes,
            results["stops"] as! Stops,
            results["trips"] as! Trips,
            results["stopTimes"] as! StopTimes
        )
    }
    
    self.agencies = agencies
    self.routes = routes
    self.stops = stops
    self.trips = trips
    self.stopTimes = stopTimes

  }
}
