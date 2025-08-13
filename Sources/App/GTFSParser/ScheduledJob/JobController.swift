import Jobs

struct JobController {
        struct GTFSMetroParameters: JobParameters {
        static let jobName: String = "GTFSMetroJob"
    }   

    init(queue: some JobQueueProtocol, service: GTFSMetroService) {
        // This function demonstrates two different ways to register a job
        // Register Job with predefined job identifier


        queue.registerJob(parameters: GTFSMetroParameters.self) { parameters, context in
            try await service.loadGTFSFeed()
        }
    }
}