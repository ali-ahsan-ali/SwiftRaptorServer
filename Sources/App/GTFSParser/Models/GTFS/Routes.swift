import FluentKit

final class Route: Model, @unchecked Sendable {
    static let schema = "route"

    @ID(custom: .id)
    var id: String?

    @OptionalField(key: "agencyId")
    var agencyId: String?

    @OptionalField(key: "routeShortName")
    var routeShortName: String?

    @OptionalField(key: "routeLongName")
    var routeLongName: String?

    @OptionalField(key: "routeDesc")
    var routeDesc: String?

    @OptionalField(key: "routeType")
    var routeType: Int?

    @OptionalField(key: "routeUrl")
    var routeUrl: String?

    @OptionalField(key: "routeColor")
    var routeColor: String?

    @OptionalField(key: "routeTextColor")
    var routeTextColor: String?

    // An empty initializer is required for Fluent to create a new model.
    init() { }

    // A complete initializer to create a new Route instance.
    public init(
        id: String? = UUID().uuidString,
        agencyId: String?,
        routeShortName: String?,
        routeLongName: String?,
        routeDesc: String?,
        routeType: Int?,
        routeUrl: String?,
        routeColor: String?,
        routeTextColor: String?
    ) {
        self.id = id
        self.agencyId = agencyId
        self.routeShortName = routeShortName
        self.routeLongName = routeLongName
        self.routeDesc = routeDesc
        self.routeType = routeType
        self.routeUrl = routeUrl
        self.routeColor = routeColor
        self.routeTextColor = routeTextColor
    }
}

// MARK: - Route Migration

struct CreateRoute: AsyncMigration {
    // Prepares the database for storing Route models.
    func prepare(on database: Database) async throws {
        try await database.schema(Route.schema)
            .field("id", .string, .identifier(auto: false))
            .field("agencyId", .string)
            .field("routeShortName", .string)
            .field("routeLongName", .string)
            .field("routeDesc", .string)
            .field("routeType", .int)
            .field("routeUrl", .string)
            .field("routeColor", .string)
            .field("routeTextColor", .string)
            .create()
    }

    // Reverts the database schema changes made in prepare.
    func revert(on database: Database) async throws {
        try? await database.schema(Route.schema).delete()
    }
}
