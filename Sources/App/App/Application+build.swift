import Hummingbird
import Logging
import OpenAPIHummingbird
import HummingbirdRedis
import HummingbirdFluent
import Jobs
import JobsRedis
import ServiceLifecycle
import FluentPostgresDriver
import AsyncHTTPClient

/// Application arguments protocol. We use a protocol so we can call
/// `buildApplication` inside Tests as well as in the App executable. 
/// Any variables added here also have to be added to `App` in App.swift and 
/// `TestArguments` in AppTest.swift
public protocol AppArguments {
    var hostname: String { get }
    var port: Int { get }
    var logLevel: Logger.Level? { get }
    var shouldCompleteStartupTask: Bool { get }
}

// Request context used by application
typealias AppRequestContext = BasicRequestContext

let logger = {
    var logger = Logger(label: "Global")
    logger.logLevel = .info
    return logger
}()

///  Build application
/// - Parameter arguments: application arguments
public func buildApplication(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
    let env = try await Environment.dotEnv()
    let redisLogger = Logger(label: "Redis")
    let jobLogger = {
        var logger = Logger(label: "Jobs")
        logger.logLevel =
            arguments.logLevel ?? env.get("LOG_LEVEL").flatMap { Logger.Level(rawValue: $0) } ?? .info
        return logger
    }()

    let redisHost = env.get("REDIS_HOST") ?? "localhost"
    let redisService = try RedisConnectionPoolService(
        .init(hostname: redisHost, port: 6379),
        logger: redisLogger
    )
    let jobQueue = try await JobQueue(
        .redis(
            redisService.pool,
            configuration: .init(queueName: "FetchAndMapGTFSData", retentionPolicy: .init(completedJobs: .retain)),
            logger: jobLogger
        ),
        logger: jobLogger
    )

    let fluent = Fluent(logger: logger)    // add sqlite database
     let postgreSQLConfig = SQLPostgresConfiguration(
        hostname: "localhost",
        port: env.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: env.get("DATABASE_USERNAME") ?? "username",
        password: env.get("DATABASE_PASSWORD") ?? "password",
        database: env.get("DATABASE_NAME") ?? "hb-db",
        tls: .disable
    )

    fluent.databases.use(.postgres(configuration: postgreSQLConfig, sqlLogLevel: .warning), as: .psql)

    let fluentPersist = await FluentPersistDriver(fluent: fluent)
    await fluent.migrations.add(
        CreateAgency(),
        CreateCalendar(),
        CreateRoute(),
        CreateStop(),
        CreateStopTime(),
        CreateTrip()
    )
    // fluent persist driver requires a migrate the first time you run
    try await fluent.migrate()

    let metroService = GTFSMetroService(fluent: fluent)
    jobQueue.registerJob(parameters: GTFSMetroJob.self) { _, _ in
        try await metroService.loadGTFSFeed()
    }

    var jobSchedule: JobSchedule = JobSchedule()
    jobSchedule.addJob(
        JobName<GTFSMetroJob>("GTFSMetroJob"),
        parameters: .init(),
        schedule: .daily(hour: 2)
    )
    jobSchedule.addJob(
        jobQueue.queue.cleanupJob,
        parameters: .init(completedJobs: .remove(maxAge: .seconds(24 * 60 * 60))),
        schedule: .hourly(minute: 52)
    )

    var app = await Application(
        router: try buildRouter(),
        configuration: .init(
            address: .hostname(arguments.hostname, port: arguments.port),
            serverName: "{{HB_PACKAGE_NAME}}"
        ),
        services: [
            metroService,
            fluent,
            fluentPersist,
            redisService,
            jobQueue.processor(options: .init(numWorkers: 4, gracefulShutdownTimeout: .seconds(10))),
            jobSchedule.scheduler(on: jobQueue, named: "JobScheduler")
        ],
        logger: logger
    )

    if arguments.shouldCompleteStartupTask {
        app.beforeServerStarts {
            try await metroService.loadGTFSFeed()
        }
    }

    return app
}

/// Build router
func buildRouter() throws -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)
    // Add middleware
    router.addMiddleware {
        // logging middleware
        LogRequestsMiddleware(.info)
        // store request context in TaskLocal
        OpenAPIRequestContextMiddleware()
    }
    // Add OpenAPI handlers
    let api = SwiftRaptor()
    try api.registerHandlers(on: router)
    return router
}

struct GTFSMetroJob: JobParameters {
    static let jobName: String = "GTFSMetroJob"
}
