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

public struct Actor {
    public let id: Int
    public let name: String
    public let profile: Image?
    
    static func loadFrom(_ data: [String: AnyObject], profileConfiguration: ImageConfiguration) -> [Actor] {
        guard let cast = data["cast"] as? [[String: AnyObject]] else {
            return []
        }
        
        
        var result = [Actor]()
        for actor in cast {
            guard let actor = loadFromData(actor, with: profileConfiguration) else {
                continue
            }
            
            result.append(actor)
        }
        
        return result
    }
    
    static func loadFromData(_ data: [String: AnyObject], with config: ImageConfiguration) -> Actor? {
        guard let name = data["name"] as? String else {
            return nil
        }
        
        guard let id = data["id"] as? Int else {
            return nil
        }
        
        var profile: Image? = nil
        if let path = data["profile_path"] as? String {
            profile = Image(path: path, config: config)
        }
        
        return Actor(id: id, name: name, profile: profile)
    }
}
