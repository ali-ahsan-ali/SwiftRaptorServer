import FluentKit

final class Route: Model, @unchecked Sendable {
    static let schema = "route"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "routeId")
    var routeId: String

    @OptionalField(key: "agencyId")
    var agencyId: String?

    @OptionalField(key: "routeShortName")
    var routeShortName: String?

    @OptionalField(key: "routeLongName")
    var routeLongName: String?

    @OptionalField(key: "routeDesc")
    var routeDesc: String?

    @Field(key: "routeType")
    var routeType: Int

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
        id: UUID? = nil,
        routeId: String,
        agencyId: String?,
        routeShortName: String?,
        routeLongName: String?,
        routeDesc: String?,
        routeType: Int,
        routeUrl: String?,
        routeColor: String?,
        routeTextColor: String?
    ) {
        self.id = id
        self.routeId = routeId
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
            .id()
            .field("routeId", .string, .required)
            .field("agencyId", .string)
            .field("routeShortName", .string)
            .field("routeLongName", .string)
            .field("routeDesc", .string)
            .field("routeType", .int, .required)
            .field("routeUrl", .string)
            .field("routeColor", .string)
            .field("routeTextColor", .string)
            .create()
    }

    // Reverts the database schema changes made in prepare.
    func revert(on database: Database) async throws {
        try await database.schema(Route.schema).delete()
    }
}
