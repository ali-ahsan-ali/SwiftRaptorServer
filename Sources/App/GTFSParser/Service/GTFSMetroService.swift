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
    }

    func saveZipFile(buffer: ByteBuffer) throws -> String {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileName = "metro.zip"
        let filePath = tempDirectory.appendingPathComponent(tempFileName).path
        
        // Create the file handle
        let fileHandle = FileHandle(forWritingAtPath: filePath)
        
        // Check if the file was created successfully
        guard let handle = fileHandle else {
            throw GTFSError.unzipFailed // Or a more specific error
        }
        
        // Write the buffer's contents to the file
        try handle.write(contentsOf: buffer.readableBytesView)
        
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
