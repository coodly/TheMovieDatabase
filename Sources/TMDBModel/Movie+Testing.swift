import Foundation

extension Movie {
  public static func mock(id: Int = 1, title: String = "Mock Movie") -> Movie {
    let configJSON = """
      {
        "images": {
          "base_url": "http://image.tmdb.org/t/p/",
          "secure_base_url": "https://image.tmdb.org/t/p/",
          "backdrop_sizes": ["w300"],
          "poster_sizes": ["w342"],
          "profile_sizes": ["w45"]
        }
      }
      """
    let configDecoder = JSONDecoder()
    configDecoder.keyDecodingStrategy = .convertFromSnakeCase
    let config = try! configDecoder.decode(Configuration.self, from: Data(configJSON.utf8))
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .formatted(mockDateFormatter)
    decoder.userInfo[.configuration] = config
    let json = """
      {
        "id": \(id),
        "title": "\(title)",
        "overview": "",
        "vote_average": 7.0,
        "popularity": 10.0,
        "release_date": "2024-01-01"
      }
      """
    return try! decoder.decode(Movie.self, from: Data(json.utf8))
  }
}

private let mockDateFormatter: DateFormatter = {
  let f = DateFormatter()
  f.dateFormat = "yyyy-MM-dd"
  return f
}()
