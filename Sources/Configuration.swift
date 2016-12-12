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

struct Configuration {
    let backdropConfig: ImageConfiguration
    let posterConfig: ImageConfiguration
    let time: Date?
    
    func write() {
        let dict: [String: AnyObject] = [
            "time": time!.timeIntervalSince1970 as AnyObject,
            "backdrop": ["base": backdropConfig.baseURL, "sizes": backdropConfig.sizes] as AnyObject,
            "poster": ["base": posterConfig.baseURL, "sizes": posterConfig.sizes] as AnyObject
        ]
        let data = try! JSONSerialization.data(withJSONObject: dict)
        try! data.write(to: Configuration.configFilePath)
        Logging.log("Config saved to \(Configuration.configFilePath)")
    }
    
    static func load() -> Configuration? {
        let path = configFilePath
        guard FileManager.default.fileExists(atPath: path.path) else {
            Logging.log("No config file")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: path)
            guard let content = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] else {
                return nil
            }
            
            guard let time = content["time"] as? TimeInterval else {
                return nil
            }
            
            guard let back = content["backdrop"] as? [String: AnyObject], let backBase = back["base"] as? String, let backSizes = back["sizes"] as? [String] else {
                return nil
            }

            guard let poster = content["poster"] as? [String: AnyObject], let posterBase = poster["base"] as? String, let posterSizes = poster["sizes"] as? [String] else {
                return nil
            }

            let backdrop = ImageConfiguration(baseURL: backBase, sizes: backSizes)
            let posterConfig = ImageConfiguration(baseURL: posterBase, sizes: posterSizes)
            let result = Configuration(backdropConfig: backdrop, posterConfig: posterConfig, time: Date(timeIntervalSince1970: time))
            Logging.log("Did load \(result)")
            return result
        } catch {
            Logging.log("Load error: \(error)")
            return nil
        }
    }
    
    private static var configFilePath: URL = {
        return workingFilesDirectory.appendingPathComponent("Configuration.json")
    }()
    
    private static var workingFilesDirectory: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let last = urls.last!
        let identifier = Bundle.main.bundleIdentifier ?? "org.themoviedb.www"
        let dbIdentifier = identifier + ".tmdb"
        let dbFolder = last.appendingPathComponent(dbIdentifier)
        do {
            try FileManager.default.createDirectory(at: dbFolder, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            Logging.log("Create tmdb folder error \(error)")
        }
        return dbFolder
    }()

}
