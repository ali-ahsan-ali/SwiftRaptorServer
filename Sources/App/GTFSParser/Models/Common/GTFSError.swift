enum GTFSError: Error {
    case invalidURL
    case networkError
    case unzipFailed
    case parsingError(String)
    case fileNotFound(String)
    case failedToUnzipFile(String)
    case failedToCreateFile
    case failedToRemoveDirectory(String)
}
