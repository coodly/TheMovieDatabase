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

public struct Movie {
    private static let dateFormatter: DateFormatter =  {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    public let index: Int
    public let id: Int
    public let title: String
    public let originalTitle: String?
    public let overview: String?
    public let poster: Image?
    public let backdrop: Image?
    public let rating: Float
    public let releaseDate: Date
    public var directors: [Director]?
    public var productionCompanies: [ProductionCompany]?
    public var cast: [Actor]?
    public var similar: [Movie]?
    public var posters: [Image]?
    public var collection: CollectionSummary?
    
    static func loadFromData(_ index: Int, data: [String: AnyObject], config: Configuration? = nil) -> Movie? {
        guard let id = data["id"] as? Int else {
            Logging.log("id not found")
            return nil
        }
        
        guard let title = data["title"] as? String else {
            Logging.log("Title not found")
            return nil
        }
        
        guard let rating = data["vote_average"] as? Float else {
            Logging.log("Rating not found")
            return nil
        }
        
        let releaseDate: Date
        if let dateString = data["release_date"] as? String, let date = Movie.dateFormatter.date(from: dateString) {
            releaseDate = date
        } else {
            releaseDate = Date.distantPast
        }
        
        let originalTitle = data["original_title"] as? String
        let posterPath = data["poster_path"] as? String
        let overview = data["overview"] as? String
        let poster = Image(path: posterPath, config: config?.posterConfig)
        let backdropPath = data["backdrop_path"] as? String
        let backdrop = Image(path: backdropPath, config: config?.backdropConfig)
        
        let collection: CollectionSummary?
        if let summaryData = data["belongs_to_collection"] as? [String: AnyObject], let summary = CollectionSummary(data: summaryData, config: config) {
            collection = summary
        } else {
            collection = nil
        }
        
        return Movie(index: index, id: id, title: title, originalTitle: originalTitle, overview: overview, poster: poster, backdrop: backdrop, rating: rating, releaseDate: releaseDate, directors: nil, productionCompanies: nil, cast: nil, similar: nil, posters: nil, collection: collection)
    }
}
