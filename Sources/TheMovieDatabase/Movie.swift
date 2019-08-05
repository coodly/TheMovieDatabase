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

public struct Movie: Codable {
    public let id: Int
    public let title: String
    public let originalTitle: String?
    public let overview: String?
    public let voteAverage: Double
    public let popularity: Double
    private let posterPath: String?
    private let backdropPath: String?
    public let releaseDate: Date
    public var cast: [Actor]? {
        return credits?.cast
    }
    public var similar: [Movie]?
    var posters: [Image]?
    private let config: Configuration
    public var collection: CollectionSummary?
    public let genreIds: [Int]?
    public let tagline: String?
    
    public var rating: Double {
        return voteAverage
    }
    public var poster: Image? {
        return Image(path: posterPath, config: config.posterConfig)
    }
    public var backdrop: Image? {
        return Image(path: backdropPath, config: config.backdropConfig)
    }
    private let credits: Credits?
    
    public init(from decoder: Decoder) throws {
        guard let config = decoder.userInfo[.configuration] as? Configuration else {
            fatalError("Missing configuration or invalid configuration")
        }
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        originalTitle = try? values.decode(String.self, forKey: .originalTitle)
        overview = try? values.decode(String.self, forKey: .overview)
        voteAverage = (try? values.decode(Double.self, forKey: .voteAverage)) ?? 0.0
        popularity = (try? values.decode(Double.self, forKey: .popularity)) ?? 0.0
        posterPath = try? values.decode(String.self, forKey: .posterPath)
        backdropPath = try? values.decode(String.self, forKey: .backdropPath)
        releaseDate = (try? values.decode(Date.self, forKey: .releaseDate)) ?? Date.distantPast
        self.config = config
        credits = try? values.decode(Credits.self, forKey: .credits)
        similar = (try? values.decode(MoviesPage.self, forKey: .similar))?.results
        posters = nil
        collection = nil
        genreIds = try? values.decode([Int].self, forKey: .genreIds)
        tagline = try? values.decode(String.self, forKey: .tagline)
    }
    
    static func loadFromData(_ index: Int, data: [String: AnyObject], config: Configuration? = nil) -> Movie? {
        return nil
    }
}
