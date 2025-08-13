import AsyncHTTPClient
import Hummingbird
import HummingbirdCore
import Logging
import NIOHTTP1
import NIOHTTPTypesHTTP1
import ServiceLifecycle
import ZIPFoundation
import NIO
import Foundation

final class GTFSMetroService: Service {

    private let parser: GTFSParser
    private let client: NSWTransportMetroClient

    init(parser: GTFSParser = GTFSParser()) {
        self.parser = parser
        self.client = NSWTransportMetroClient()
    }
    
    func loadGTFSFeed() async throws {
        let response = try await client.fetchGTFSData()
        let savedFilePath = try await saveZipFile(body: response.body)
        let unzipDirectory = try unzipFile(atPath: savedFilePath)
        parser.parseGTFSData(atDirectory: unzipDirectory)
    }

    func saveZipFile(body: HTTPClientResponse.Body) async throws -> String {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileName = "metro.zip"
        let filePath = tempDirectory.appendingPathComponent(tempFileName).path
        
        guard FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil) else {
            throw GTFSError.failedToCreateFile
        }

        // Create the file handle
        guard let handle = FileHandle(forWritingAtPath: filePath) else {
            throw GTFSError.fileNotFound("Handler for writing at path \(filePath) could not be created.") 
        }
        
        // Write the buffer's contents to the file
        // Asynchronously loop through each chunk (ByteBuffer) from the sequence.
        for try await buffer in body {
            // Write the data from the buffer to the file.
            try handle.write(contentsOf: buffer.readableBytesView)
        }
        
        // Close the file handle
        handle.closeFile()
        return filePath
    }


    func unzipFile(atPath filePath: String) throws -> URL {
        let fileManager = FileManager.default
        let zipDirectory = fileManager.temporaryDirectory
            .appendingPathComponent("metro.zip")

        let unzipDirectory = fileManager.temporaryDirectory
            .appendingPathComponent("metro")

        try fileManager.createDirectory(at: unzipDirectory, withIntermediateDirectories: true, attributes: nil)
        try fileManager.unzipItem(at: zipDirectory, to: unzipDirectory)

        return unzipDirectory
    }

    func run() async throws {
        try? await gracefulShutdown()
        try await self.client.shutdown()
    }
}
