/*
 * Copyright 2019 Coodly LLC
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

private let ConfigInvalidationTimeSecods = TimeInterval(60 * 60 * 24 * 3)

internal struct CachedConfiguration: Codable {
    let configuration: Configuration
    let time: Date
    
    internal func write() {
        do {
            let data = try JSONEncoder().encode(self)
            if FileManager.default.fileExists(atPath: CachedConfiguration.configFilePath.path) {
                try? FileManager.default.removeItem(at: CachedConfiguration.configFilePath)
            }
            try data.write(to: CachedConfiguration.configFilePath)
        } catch {
            Logging.log("Write config error: \(error)")
        }
    }
    
    internal static func load() -> CachedConfiguration? {
        guard FileManager.default.fileExists(atPath: configFilePath.path) else {
            Logging.log("No config file")
            return nil
        }
        
        guard let data = try? Data(contentsOf: configFilePath) else {
            Logging.log("No data")
            return nil
        }
        
        do {
            let loaded = try JSONDecoder().decode(CachedConfiguration.self, from: data)
            
            if Date().timeIntervalSince(loaded.time) > ConfigInvalidationTimeSecods {
                Logging.log("Config cache expired: \(loaded.time)")
                return nil
            }
            
            return loaded
        } catch {
            Logging.log("Config decode error: \(error)")
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
