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

public struct ProductionCompany: Codable {
    public let id: Int
    public let name: String
    
    static func loadFromData(_ data: [[String: AnyObject]]) -> [ProductionCompany] {
        var result = [ProductionCompany]()
        for company in data {
            guard let name = company["name"] as? String else {
                continue
            }
            
            guard let id = company["id"] as? Int else {
                continue
            }
            
            let p = ProductionCompany(id: id, name: name)
            result.append(p)
        }
        
        return result
    }
}
