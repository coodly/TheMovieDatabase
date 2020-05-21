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
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension CodingUserInfoKey {
    internal static let configuration = CodingUserInfoKey(rawValue: "configuration")!
}

private let APIServer = "https://api.themoviedb.org/3"

public struct TMDBError: Codable, Error, LocalizedError {
    public var code: Int {
        return statusCode
    }
    public var message: String {
        return statusMessage
    }
    public let statusCode: Int
    public let statusMessage: String
    
    public var errorDescription: String? {
        return message
    }
}

private enum Method: String {
    case POST
    case GET
}

internal class NetworkRequest<Response: Codable, Result>:  NetworkFetchConsumer, APIKeyConsumer, ListCacheConsumer {
    var fetch: NetworkFetch!
    var apiKey: String!
    var cache: ListCache!
    var resulthandler: ((Result?, Error?) -> Void)!
    private lazy var decoder: JSONDecoder = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.userInfo[.configuration] = Injector.sharedInsatnce.configuration
        
        return decoder
    }()

    func execute() {
        fatalError("Override \(#function)")
    }
    
    func GET(_ path: String, parameters: [String: AnyObject]? = nil) {
        executeMethod(.GET, path: path, parameters: parameters)
    }
    
    func POST(_ path: String, parameters: [String: AnyObject]? = nil) {
        executeMethod(.POST, path: path, parameters: parameters)
    }
    
    private func executeMethod(_ method: Method, path: String, parameters: [String: AnyObject]?) {
        if let cachedRequest = self as? CachedRequest, let data = cache.data(for: cachedRequest.cacheKey) {
            do {
                let response = try decoder.decode(Response.self, from: data)
                Logging.log("Had cache hit for \(cachedRequest.cacheKey)")
                handle(response: response)
                return
            } catch {
                Logging.log("Cached data error: \(error)")
            }
        }

        var components = URLComponents(url: URL(string: APIServer)!, resolvingAgainstBaseURL: true)!
        components.path = components.path + path
        
        if let parameters = parameters {
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
        }
        
        let requestURL = components.url!
        let request = NSMutableURLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        
        fetch.fetch(request: request as URLRequest, completion: handleRaw)
    }
    
    func handleRaw(data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            Logging.log("Fetch error \(error)")
            self.handle(error: error)
        }
        
        if let cached = self as? CachedRequest, let data = data {
            self.cache.cache(data, for: cached.cacheKey)
        }
        
        guard let data = data else {
            handle(error: error)
            return
        }
        
        Logging.log("Response \(String(data: data, encoding: .utf8).debugDescription)")
        do {
            let response = try decoder.decode(Response.self, from: data)
            handle(response: response)
        } catch let error as NSError {
            if let serverMessage = try? decoder.decode(TMDBError.self, from: data) {
                Logging.log("Error from server: \(serverMessage)")
                handle(error: serverMessage)
            } else {
                handle(error: error)
            }
        }
    }
    
    func handle(response: Response) {
        Logging.log("Handle response: \(response)")
    }
    
    func handle(error: Error?) {
        Logging.log("handleErrorResponse: \(error.debugDescription)")
        resulthandler(nil, error)
    }
}
