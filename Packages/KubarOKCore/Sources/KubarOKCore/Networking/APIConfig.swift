import Foundation

public enum APIConfig {

    public static let baseURL = URL(
        string: "https://kubarok.kutaibaratkab.go.id/v1"
    )!

    /// Keeps requests from waiting indefinitely on an unavailable production API.
    public static let requestTimeout: TimeInterval = 30
}
