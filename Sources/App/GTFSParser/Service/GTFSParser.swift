import HummingbirdFluent 
import Foundation
import SwiftTransit

struct GTFSParser {

    func parseGTFSData(atDirectory directory: URL) {
        let feed = Feed(contentsOfURL: directory)
    }

} 