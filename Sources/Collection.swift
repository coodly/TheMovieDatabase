/*
 * Copyright 2017 Coodly LLC
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

public struct Collection {
    public let id: Int
    public let name: String
    public let overview: String
    public let poster: Image
    public let backdrop: Image
    public let movies: [Movie]
    
    public var formattedPeriod: String? {
        let gregorian = Calendar(identifier: .gregorian)
        let years = movies.filter({ $0.releaseDate > Date.distantPast }).map({ gregorian.component(.year, from: $0.releaseDate)})
        guard let min = years.min(), let max = years.max() else {
            return nil
        }
        
        return "(\(min)-\(max))"
    }
    
    public var averageRating: Float? {
        let ratings = movies.map({ $0.rating }).filter({ $0 > 0.1 })
        let combinedRating = ratings.reduce(0, +)
        guard ratings.count > 0 else {
            return nil
        }
        
        return combinedRating / Float(ratings.count)
    }
}

internal extension Collection {
    init?(json: [String: AnyObject], config: Configuration? = nil) {
        guard let id = json["id"] as? Int else {
            return nil
        }
        
        guard let name = json["name"] as? String else {
            return nil
        }
        
        guard let overview = json["overview"] as? String else {
            return nil
        }
        
        guard let parts = json["parts"] as? [[String: AnyObject]] else {
            return nil
        }
        
        var movies = [Movie]()
        for part in parts {
            if let movie = Movie.loadFromData(0, data: part, config: config) {
                movies.append(movie)
            }
        }
        
        self.id = id
        self.name = name
        self.overview = overview
        self.movies = movies
        
        poster = Image(path: json["poster_path"] as? String, config: config?.posterConfig)
        backdrop = Image(path: json["backdrop_path"] as? String, config: config?.backdropConfig)
    }
}
