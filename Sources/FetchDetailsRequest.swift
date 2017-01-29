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

public struct Details: OptionSet {
    public let rawValue : Int
    let key: String
    
    public init(rawValue: Int, key: String) {
        self.rawValue = rawValue
        self.key = key
    }
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
        self.key = ""
    }
    
    public static let credits = Details(rawValue: 1 << 0, key: "credits")
    public static let similar = Details(rawValue: 1 << 1, key: "similar")
    public static let reviews = Details(rawValue: 1 << 2, key: "reviews")
    public static let translations = Details(rawValue: 1 << 3, key: "translations")
    public static let videos = Details(rawValue: 1 << 4, key: "videos")
    public static let images = Details(rawValue: 1 << 5, key: "images")
    
    static let allValues: [Details] = [.credits, .similar, .reviews, .translations, .videos, .images]
}

private let MovieDetailsPath = "/movie"

class FetchDetailsRequest: NetworkRequest, ConfigurationConsumer {
    private let movieId: Int
    private let include: Details
    var configuration: Configuration!
    
    init(movieId: Int, includedDetails: Details) {
        self.movieId = movieId
        self.include = includedDetails
    }
    
    override func execute() {
        let path = "\(MovieDetailsPath)/\(movieId)"
        let append = appendForDetails(include)
        
        var params: [String: AnyObject] = ["api_key": apiKey as AnyObject]
        if append.characters.count > 0 {
            params["append_to_response"] = append as AnyObject?
        }
        
        GET(path, parameters: params)
    }
    
    override func handle(success data: [String : AnyObject]) {
        guard var result = Movie.loadFromData(0, data: data, config: self.configuration) else {
            resulthandler(nil, nil)
            return
        }
        
        if let credits = data["credits"] as? [String: AnyObject] {
            result.directors = Director.loadFrom(credits)
            result.cast = Actor.loadFrom(credits, profileConfiguration: self.configuration.profileConfig)
        }
        if let production = data["production_companies"] as? [[String: AnyObject]] {
            result.productionCompanies = ProductionCompany.loadFromData(production)
        }
        if let images = data["images"] as? [String: Any], let posters = images["posters"] as? [[String: Any]] {
            var loaded = [Image]()
            for poster in posters {
                guard let path = poster["file_path"] as? String else {
                    continue
                }
                
                loaded.append(Image(path: path, config: configuration.posterConfig))
            }
            result.posters = loaded
        }
        if let similar = data["similar"] as? [String: AnyObject], let results = similar["results"] as? [[String: AnyObject]] {
            var loaded = [Movie]()
            for result in results {
                if let movie = Movie.loadFromData(0, data: result, config: self.configuration) {
                    loaded.append(movie)
                }
            }

            result.similar = loaded
        }
        
        resulthandler(result, nil)
    }
    
    private func appendForDetails(_ include: Details) -> String {
        var append = [String]()
        
        for check in Details.allValues {
            guard include.contains(check) else {
                continue
            }
            
            append.append(check.key)
        }
        
        return append.joined(separator: ",")
    }
}
