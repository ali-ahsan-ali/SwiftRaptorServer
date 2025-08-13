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

    init(client: HTTPClient, parser: GTFSParser) {
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
        
        // Create the file handle
        let fileHandle = FileHandle(forWritingAtPath: filePath)
        
        // Check if the file was created successfully
        guard let handle = fileHandle else {
            throw GTFSError.unzipFailed 
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
