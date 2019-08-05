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

public struct Collection: Codable {
    public let id: Int
    public let name: String
    public let overview: String
    public var poster: Image {
        return Image(path: posterPath, config: config.posterConfig)
    }
    public var backdrop: Image {
        return Image(path: backdropPath, config: config.backdropConfig)
    }
    public var movies: [Movie] {
        return parts
    }
    
    private let posterPath: String?
    private let backdropPath: String?
    private let parts: [Movie]
    
    private let config: Configuration
    
    public init(from decoder: Decoder) throws {
        guard let config = decoder.userInfo[.configuration] as? Configuration else {
            fatalError("Missing configuration or invalid configuration")
        }
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        overview = try values.decode(String.self, forKey: .overview)
        posterPath = try? values.decode(String.self, forKey: .posterPath)
        backdropPath = try? values.decode(String.self, forKey: .backdropPath)
        parts = try values.decode([Movie].self, forKey: .parts)
        
        self.config = config
    }
    
    public var formattedPeriod: String? {
        let gregorian = Calendar(identifier: .gregorian)
        let years = movies.filter({ $0.releaseDate > Date.distantPast }).map({ gregorian.component(.year, from: $0.releaseDate)})
        guard let min = years.min(), let max = years.max() else {
            return nil
        }
        
        return "(\(min)-\(max))"
    }
    
    public var averageRating: Double? {
        let ratings = movies.map({ $0.rating }).filter({ $0 > 0.1 })
        let combinedRating = ratings.reduce(0, +)
        guard ratings.count > 0 else {
            return nil
        }
        
        return combinedRating / Double(ratings.count)
    }
}

internal extension Collection {
    init?(json: [String: AnyObject], config: Configuration? = nil) {
        return nil
    }
}
