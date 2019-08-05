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

private let MoviesPerPage = 20

public class Cursor<T> {
    public var page: Int!
    internal var totalPages: Int!
    public var items: [T]!
    
    internal class func loadFrom(_ data: [String: AnyObject], creation: (Int, [String: AnyObject]) -> (T?)) -> Cursor<T>? {
        guard let page = data["page"] as? Int else {
            Logging.log("Page not found from data")
            return nil
        }
        
        guard let total = data["total_pages"] as? Int else {
            Logging.log("Total pages not found")
            return nil
        }
        
        guard let results = data["results"] as? [[String: AnyObject]] else {
            Logging.log("Results element not found")
            return nil
        }
        
        let loaded = (page - 1) * MoviesPerPage
        var index = loaded + 1
        var elements = [T]()
        for result in results {
            if let created = creation(index, result) {
                elements.append(created)
            }
            
            index = index + 1
        }
        
        return Cursor<T>(page: page, totalPages: total, items: elements)
    }
    
    public func hasMoreResults() -> Bool {
        return page < totalPages
    }
    
    convenience init(page: Int, totalPages: Int, items: [T]) {
        self.init()
        
        self.page = page
        self.totalPages = totalPages
        self.items = items
    }
    
    convenience init(items: [T]) {
        self.init()
        
        self.page = 1
        self.totalPages = items.count
        self.items = items
    }
}
