import Foundation

struct URLValidator {
    private enum URLError: String, Error {
        case emptyInput = "No input provided"
        case invalidScheme = "Only HTTPS scheme is supported"
        case invalidURL = "Invalid URL"
    }

    static func convertToURL(_ string: String?) -> Result<URL,Error> {
        guard let string = string, !string.isEmpty else {
            return .failure(URLError.emptyInput)
        }

        guard var components = URLComponents(string: string) else {
            return .failure(URLError.invalidURL)
        }

        if let scheme = components.scheme {
            if scheme.lowercased() != "https" {
                return .failure(URLError.invalidScheme)
            }
        } else {
            components.scheme = "https"
        }

        guard let url = components.url else {
            return .failure(URLError.invalidURL)
        }

        return .success(url)
    }
}
