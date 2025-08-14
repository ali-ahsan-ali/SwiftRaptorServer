import HummingbirdFluent 
import Foundation
import SwiftTransit

struct GTFSParser {
    private let fluent : Fluent 
    private static let AgencyTableName = "agency"

    init(fluent: Fluent) {
        self.fluent = fluent
    }

    func parseGTFSData(atDirectory directory: URL) async throws {
        let feed = try Feed(contentsOfURL: directory)
        for agency in feed.agencies {
            let mappedAgency = Agency (agencyName: agency.name, agencyUrl: agency.url.path, agencyTimezone: agency.timeZone.identifier)
            _ = try await mappedAgency.save(on: fluent.db())
        }
        for x in try await Agency.query(on: fluent.db()).all() {
            print("Agency: \(x.agencyName), URL: \(x.agencyUrl), Timezone: \(x.agencyTimezone)")
        }
        logger.debug("\(String(describing: feed.agencies))")
    }

} 