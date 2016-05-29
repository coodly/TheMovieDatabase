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
    private static let dateFormatter: NSDateFormatter =  {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    public let id: Int
    public let title: String
    public let originalTitle: String?
    public let rating: Float
    public let releaseDate: NSDate
    
    static func loadFromData(data: [String: AnyObject]) -> Movie? {
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
        
        guard let releaseDate = data["release_date"] as? String, date  = Movie.dateFormatter.dateFromString(releaseDate) else {
            Logging.log("Release date not found")
            return nil
        }
        
        let originalTitle = data["original_title"] as? String
        
        return Movie(id: id, title: title, originalTitle: originalTitle, rating: rating, releaseDate: date)
    }
}