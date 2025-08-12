import HummingbirdFluent
import FluentKit

final class Agency: Model, @unchecked Sendable {
    static let schema = "agency"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "agencyId")
    var agencyId: String?
    
    @Field(key: "agencyName")
    var agencyName: String
    
    @Field(key: "agencyUrl")
    var agencyUrl: String
    
    @Field(key: "agencyTimezone")
    var agencyTimezone: String
    
    @OptionalField(key: "agencyLang")
    var agencyLang: String?
    
    @OptionalField(key: "agencyPhone")
    var agencyPhone: String?
    
    @OptionalField(key: "agencyFareUrl")
    var agencyFareUrl: String?
    
    @OptionalField(key: "agencyEmail")
    var agencyEmail: String?

    init() { }

    init(id: UUID? = nil, agencyId: String? = nil, agencyName: String, agencyUrl: String, agencyTimezone: String, agencyLang: String? = nil, agencyPhone: String? = nil, agencyFareUrl: String? = nil, agencyEmail: String? = nil) {
        self.id = id
        self.agencyId = agencyId
        self.agencyName = agencyName
        self.agencyUrl = agencyUrl
        self.agencyTimezone = agencyTimezone
        self.agencyLang = agencyLang
        self.agencyPhone = agencyPhone
        self.agencyFareUrl = agencyFareUrl
        self.agencyEmail = agencyEmail
    }
}