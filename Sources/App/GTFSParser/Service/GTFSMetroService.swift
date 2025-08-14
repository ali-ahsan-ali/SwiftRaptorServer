import AsyncHTTPClient
import Hummingbird
import HummingbirdCore
import Logging
import NIOHTTP1
import NIOHTTPTypesHTTP1
import ServiceLifecycle
import ZipArchive
import NIO
import Foundation
import HummingbirdFluent

final class GTFSMetroService: Service {
    private let parser: GTFSParser
    private let client: NSWTransportMetroClient

    init(fluent: Fluent) {
        self.parser = GTFSParser(fluent: fluent)
        self.client = NSWTransportMetroClient()
    }
    
    func loadGTFSFeed() async throws {
        let response = try await client.fetchGTFSData()
        let savedFilePath = try await saveZipFile(body: response.body)
        let unzipDirectory = try unzipFile(atPath: savedFilePath)
        try await parser.parseGTFSData(atDirectory: unzipDirectory)
    }

    func saveZipFile(body: HTTPClientResponse.Body) async throws -> String {
        let directory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let tempFileName = "metro.zip"
        let filePath = directory.appendingPathComponent(tempFileName).path

        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                throw GTFSError.failedToRemoveDirectory(error.localizedDescription)
            }
        }

        guard FileManager.default.createFile(atPath: filePath, contents: nil, attributes: [.posixPermissions: NSNumber(value: 0o666)]) else {
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
        let directory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let unzipDirectory = directory.appendingPathComponent("metro")

        // Remove any pre-existing directory to ensure a clean slate
        var isDirectory: Bool = false
        if FileManager.default.fileExists(atPath: unzipDirectory.path, isDirectory: &isDirectory) {
            if isDirectory {
                // If it exists and is a directory, remove it
                do {
                    try FileManager.default.removeItem(atPath: unzipDirectory.path)
                } catch {
                    throw GTFSError.failedToRemoveDirectory(error.localizedDescription)
                }
            } else {
                // If it exists but is not a directory, throw an error
                throw GTFSError.fileNotFound("Expected a directory at \(unzipDirectory.path), but found a file.")
            }
        }

        // Create the directory. The ZipArchiveReader will populate this folder.
        try FileManager.default.createDirectory(at: unzipDirectory, withIntermediateDirectories: true, attributes: nil)

        do {
            try ZipArchiveReader.withFile(filePath) { reader in
                do {
                    try reader.extract(to: .init(unzipDirectory.path))
                } catch {
                    throw GTFSError.failedToUnzipFile(error.localizedDescription)
                }
            }
        } catch {
            throw error 
        }

        return unzipDirectory
    }

    func run() async throws {
        try? await gracefulShutdown()
        try await self.client.shutdown()
    }
}
