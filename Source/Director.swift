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

public struct Director {
    let id: Int
    let name: String
    
    static func loadFromCredits(data: [String: AnyObject]) -> [Director] {
        guard let crew = data["crew"] as? [[String: AnyObject]] else {
            return []
        }
        
        
        var result = [Director]()
        for member in crew {
            guard let job = member["job"] as? String where job == "Director" else {
                continue
            }
            
            guard let director = loadFromData(member) else {
                continue
            }
            
            result.append(director)
        }
        
        return result
    }
    
    static func loadFromData(data: [String: AnyObject]) -> Director? {
        guard let name = data["name"] as? String else {
            return nil
        }
        
        guard let id = data["id"] as? Int else {
            return nil
        }
        
        return Director(id: id, name: name)
    }
}