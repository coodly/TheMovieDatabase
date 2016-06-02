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

public struct Details: OptionSetType {
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
    
    public static let Credits = Details(rawValue: 1 << 0, key: "credits")
    public static let Similar = Details(rawValue: 1 << 1, key: "similar")
    public static let Reviews = Details(rawValue: 1 << 2, key: "reviews")
    public static let Translations = Details(rawValue: 1 << 3, key: "translations")
    public static let Videos = Details(rawValue: 1 << 4, key: "videos")
    public static let Images = Details(rawValue: 1 << 5, key: "images")
    
    static let allValues: [Details] = [.Credits, .Similar, .Reviews, .Translations, .Videos, .Images]
}

private let MovieDetailsPath = "/movie"

class FetchDetailsRequest: NetworkRequest {
    private let movie: Movie
    private let include: Details
    
    init(movie: Movie, includedDetails: Details, fetch: NetworkFetch) {
        self.movie = movie
        self.include = includedDetails
        super.init(fetch: fetch)
    }
    
    override func execute() {
        let path = "\(MovieDetailsPath)/\(movie.id)"
        let append = appendForDetails(include)
        
        var params = ["api_key": apiKey]
        if append.characters.count > 0 {
            params["append_to_response"] = append
        }
        
        GET(path, parameters: params)
    }
    
    override func handleSuccessResponse(data: [String : AnyObject]) {
        var result = movie
        if let credits = data["credits"] as? [String: AnyObject] {
            result.directors = Director.loadFromCredits(credits)
        }
        if let production = data["production_companies"] as? [[String: AnyObject]] {
            result.productionCompanies = ProductionCompany.loadFromData(production)
        }
        
        resulthandler(result, nil)
    }
    
    private func appendForDetails(include: Details) -> String {
        var append = [String]()
        
        for check in Details.allValues {
            guard include.contains(check) else {
                continue
            }
            
            append.append(check.key)
        }
        
        return append.joinWithSeparator(",")
    }
}