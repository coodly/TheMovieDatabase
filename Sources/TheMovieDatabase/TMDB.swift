/*
 * Copyright 2016 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import Sharing
import TMDBLogging
import TMDBModel

public struct TMDB: Sendable {
  private let apiKey: String
  private let fetch: NetworkFetch
  
  public init(apiKey: String, networkFetch: NetworkFetch) {
    self.apiKey = apiKey
    self.fetch = networkFetch
  }
    
  public func fetch(page: Int, in list: List, sort: SortBy = .popularity(.desc)) async throws -> MoviesPage {
    let path: String
    var params = ["page": String(describing: page)]
    switch list {
    case .popular:
      path = "/movie/popular"
    case .topRated:
      path = "/movie/top_rated"
    case .genre(let int):
      path = "/discover/movie"
      params["with_genres"] = String(describing: int)
      params["include_adult"] = "false"
      params["include_video"] = "true"
      params["vote_count.gte"] = "50"
      
      switch sort {
      case .none:
        break // no op
      default:
        params["sort_by"] = sort.value
      }
        
    case .search(let string):
      path = "/search/movie"
      params["query"] = string
    case .actor(let int):
      path = "/discover/movie"
      params["with_cast"] = String(describing: int)
      params["include_adult"] = "false"
      params["include_video"] = "true"
      params["vote_count.gte"] = "50"

      switch sort {
      case .none:
        break // no op
      default:
        params["sort_by"] = sort.value
      }

    case .user(let int):
      fatalError()
    }

    return try await get(path: path, params: params)
  }

  @Sendable
  func perform<Result: Decodable>(_ method: HTTPMethod, path: String, parameters: [String: String]) async throws -> Result {
    let APIServer = "https://api.themoviedb.org/3"
    var components = URLComponents(url: URL(string: APIServer)!, resolvingAgainstBaseURL: true)!
    components.path = components.path + path
        
    Logging.log("Perform \(method.rawValue) to \(components.url!)")

    var queryItems = [URLQueryItem]()
          
    for (name, value) in parameters {
      var encode: String?
      if let integer = value as? Int {
        encode = String(integer)
      } else if let string = value as? String {
        encode = string
      }
              
      guard let toEncode = encode else {
        continue
      }
              
      queryItems.append(URLQueryItem(name: name, value: toEncode))
    }
          
    components.queryItems = queryItems

    let requestURL = components.url!
    let request = NSMutableURLRequest(url: requestURL)
    request.httpMethod = method.rawValue
    
    let (data, result) = try await fetch.fetch(request: request as URLRequest)
    
#if DEBUG
    if let string = String(data: data, encoding: .utf8) {
      Logging.log(string)
    }
#endif
    
    @Shared(.configuration) var configuration

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"

    let decoder = JSONDecoder()
        
    decoder.dateDecodingStrategy = .formatted(formatter)
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    if let configuration {
      decoder.userInfo[.configuration] = configuration
    }

    do {
      return try decoder.decode(Result.self, from: data)
    } catch {
      if let failure = try? decoder.decode(TMDBError.self, from: data) {
        throw failure
      } else {
        throw error
      }
    }
  }
  
  
  @Sendable
  func fetchConfigutation() async throws -> Configuration {
    try await perform(.get, path: "/configuration", parameters: ["api_key": apiKey])
  }
  
  @Sendable
  func get<Result: Decodable>(path: String, params: [String: String]) async throws -> Result {
    @Shared(.configuration) var configuration
    if configuration == nil {
      let loaded = try await fetchConfigutation()
      print(loaded)
      $configuration.withLock { $0 = loaded }
    }
    
    var paramsSent = params
    paramsSent["api_key"] = apiKey
    return try await perform(.get, path: path, parameters: paramsSent)
  }
}

extension TMDB {
  public func poster(with path: String?) -> Image {
    @Shared(.configuration) var configuration

    return Image(path: path, config: configuration?.posterConfig)
  }
}

extension TMDB {
  public func listMovieGenres(in language: String = "en") async throws -> [Genre] {
    struct GenresResponse: Codable {
      let genres: [Genre]
    }

    let response: GenresResponse = try await get(path: "/genre/movie/list", params: ["language": language])
    return response.genres
  }
}

extension TMDB {
  public func detailsFor(movie: Movie, inclidedDetails details: Details = []) async throws -> Movie {
    Logging.log("Fetch details for movie:\(movie)")
    return try await detailsFor(movieId: movie.id, inclidedDetails: details)
  }

  public func detailsFor(movieId: Int, inclidedDetails details: Details = []) async throws -> Movie {
    Logging.log("Fetch details for movieId:\(movieId)")
    
    func appendForDetails(_ include: Details) -> String {
      var append = [String]()
          
      for check in Details.allValues {
        guard include.contains(check) else {
          continue
        }
              
        append.append(check.key)
      }
          
      return append.joined(separator: ",")
    }
    
    let MovieDetailsPath = "/movie"
    let path = "\(MovieDetailsPath)/\(movieId)"
    let append = appendForDetails(details)
    
    var params: [String: String] = [:]
    if append.count > 0 {
      params["append_to_response"] = append
    }

    
    return try await get(path: path, params: params)
    
    //return try await withCheckedThrowingContinuation { continuation in
    //  let request = FetchDetailsRequest(movieId: movieId, includedDetails: details)
    //  request.resulthandler = {
    //    movie, error in

    //    if let movie = movie {
    //      continuation.resume(returning: movie)
    //    } else {
    //      continuation.resume(throwing: error ?? TMDBError.unknown)
    //    }
    //  }
    //  runWithConfigCheck(request: request)
    //}
  }
}

extension TMDB {
  public func findWithIMDB(id: String) async throws -> Movie? {
    let ByExternalIDPathBase = "/find/"
    let path = "\(ByExternalIDPathBase)\(id)"
    let result: FindResult = try await get(path: path, params: ["external_source": "imdb_id"])
    return result.movieResults.first
  }
}

extension TMDB {
  public func fetch(collection id: Int) async throws -> Collection {
    try await get(path: "/collection/\(id)", params: [:])
  }
}

//public typealias TMDBCompletionClosure = ((Cursor<Movie>?, Error?) -> ())
//
//public class TMDB: InjectionHandler {
//  public init(apiKey: String, networkFetch: NetworkFetch) {
//    Injector.sharedInsatnce.apiKey = apiKey
//    Injector.sharedInsatnce.networkFetch = networkFetch
//  }
//
//  fileprivate func runWithConfigCheck<Response: Codable, Result>(request: NetworkRequest<Response, Result>) {
//    let injectAndRunClosure = {
//      self.inject(into: request)
//      request.execute()
//    }
//
//    if Injector.sharedInsatnce.configuration != nil {
//      injectAndRunClosure()
//      return
//    }
//
//    let configRequest = ConfigurationsRequest()
//    inject(into: configRequest)
//    configRequest.resulthandler = {
//      result, error in
//
//      if let error = error {
//        request.handle(error: error)
//        return
//      }
//
//      if let config = result {
//        Injector.sharedInsatnce.configuration = config
//        let cached = CachedConfiguration(configuration: config, time: Date())
//        cached.write()
//      }
//
//      injectAndRunClosure()
//    }
//    configRequest.execute()
//  }
//}
//
//// MARK: - 
//// MARK: Movie details
//extension TMDB {
//  public func detailsFor(movie: Movie, inclidedDetails details: Details = []) async throws -> Movie {
//    Logging.log("Fetch details for movie:\(movie)")
//    return try await detailsFor(movieId: movie.id, inclidedDetails: details)
//  }
//
//  public func detailsFor(movieId: Int, inclidedDetails details: Details = []) async throws -> Movie {
//    Logging.log("Fetch details for movieId:\(movieId)")
//    return try await withCheckedThrowingContinuation { continuation in
//      let request = FetchDetailsRequest(movieId: movieId, includedDetails: details)
//      request.resulthandler = {
//        movie, error in
//
//        if let movie = movie {
//          continuation.resume(returning: movie)
//        } else {
//          continuation.resume(throwing: error ?? TMDBError.unknown)
//        }
//      }
//      runWithConfigCheck(request: request)
//    }
//  }
//}
//
//// MARK: -
//// MARK: Lists
//extension TMDB {
//  public func fetch(page: Int, in list: List, sort: SortBy = .popularity(.desc)) async throws -> Cursor<Movie>? {
//    try await withCheckedThrowingContinuation {
//      continuation in
//      
//      let completion: (Cursor<Movie>?, Error?) -> () = { cursor, error in
//        if let error {
//          continuation.resume(throwing: error)
//        } else {
//          continuation.resume(returning: cursor)
//        }
//      }
//      
//      let request: NetworkRequest<MoviesPage, Cursor<Movie>>
//      switch list {
//      case .topRated:
//        request = ListTopMoviesRequest(page: page)
//      case .popular:
//        request = ListPopularMoviesRequest(page: page)
//      case .genre(let genreId):
//        request = MoviesDiscoverRequest(genreId: genreId, page: page, sort: sort)
//      case .search(let term):
//        guard !term.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
//          continuation.resume(returning: nil)
//          return
//        }
//        request = SearchMoviesRequest(page: page, term: term)
//      case .actor(let actorId):
//        request = MoviesDiscoverRequest(actorId: actorId, page: page, sort: sort)
//      case .user(let listId):
//        let request = ListMoviesInUserList(listId: listId)
//        request.resulthandler = completion
//        runWithConfigCheck(request: request)
//        return
//      }
//
//      request.resulthandler = completion
//
//      runWithConfigCheck(request: request)
//    }
//  }
//}
//
//// MARK: -
//// MARK: By external ID
//extension TMDB {
//  public func findWithIMDB(id: String, completion: @escaping ((Movie?, Error?) -> Void)) {
//    let request = FindWithIMDBRequest(imdbID: id)
//    request.resulthandler = completion
//    runWithConfigCheck(request: request)
//  }
//}
//
//// MARK: -
//// MARK: Collections
//public typealias TMDBCollectionClosure = ((Collection?) -> ())
//extension TMDB {
//  public func fetch(collection id: Int, completion: @escaping TMDBCollectionClosure) {
//    let request = CollectionDetailsRequest(collectionId: id)
//    request.resulthandler = {
//      result, error in
//
//      completion(result)
//    }
//    runWithConfigCheck(request: request)
//  }
//}
//
//// MARK: -
//// MARK: Movie genres list
//extension TMDB {
//  public func listMovieGenres(in language: String = "en") async throws -> [Genre] {
//    try await withCheckedThrowingContinuation { continuation in
//      let request = ListMovieGenresRequest(language: language)
//      inject(into: request)
//      request.resulthandler = {
//        result, error in
//
//        if let error {
//          continuation.resume(throwing: error)
//        } else {
//          continuation.resume(returning: result ?? [])
//        }
//      }
//      request.execute()
//    }
//  }
//}
//
//extension TMDB {
//  public func poster(with path: String?) -> Image {
//    return Image(path: path, config: Injector.sharedInsatnce.configuration?.posterConfig)
//  }
//}
//
//// MARK: -
//// MARK: Supported languages
//extension TMDB {
//  public func listLanguages(completion: @escaping ((Result<[Language], Error>) -> Void)) {
//    let request = ListLanguagesRequest()
//    inject(into: request)
//    request.resulthandler = {
//      languages, error in
//
//      if let error = error {
//        completion(.failure(error))
//      } else {
//        completion(.success(languages ?? []))
//      }
//    }
//    request.execute()
//  }
//}
