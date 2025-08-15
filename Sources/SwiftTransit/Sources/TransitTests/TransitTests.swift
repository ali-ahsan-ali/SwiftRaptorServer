//
// TransitTests.swift
//

import XCTest

// final class TransitTests: XCTestCase {

//   override func setUpWithError() throws {
//     super.setUp()
//     let resourcePath = Bundle.main.resourcePath
//     let feedURL = URL(fileURLWithPath: resourcePath!)
//     let feed = try Feed(contentsOfURL: feedURL)
//     print(feed.agency.name)
//     for route in feed.routes {
//       print(route)
//     }
//     for stop in feed.stops {
//       print(stop)
//     }
//   }

// }

/*
func test_initWithURL() {
  if let agencyFileURL = self.agencyFileURL {
    if let agency = Feed.agencyFromFeed(url: agencyFileURL) {
      XCTAssertNil(agency.agencyID, "CTA agency ID should be nil")
      XCTAssertEqual(agency.name, "Chicago Transit Authority")
      XCTAssertEqual(agency.url, URL(string: "http://transitchicago.com"))
      XCTAssertEqual(agency.timeZone, TimeZone(identifier: "America/Chicago"))
      XCTAssertEqual(agency.language, "en")
      XCTAssertEqual(agency.phone, "1-888-YOURCTA")
      XCTAssertEqual(
        agency.fareURL,
        URL(string:
			"http://www.transitchicago.com/travel_information/fares/default.aspx"))
      XCTAssertNil(agency.email, "CTA email address should be nil")
    }
  }
}
*/
