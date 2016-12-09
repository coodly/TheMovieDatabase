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

private extension DateFormatter {
    static let cacheDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

internal class ListCache {
    func data(for list: String) -> Data? {
        let listKey = key(for: list)
        let cacheFileURL = ListCache.cacheFolder.appendingPathComponent(listKey)
        do {
            let data = try Data(contentsOf: cacheFileURL)
            Logging.log("Cache hit for \(list)")
            return data
        } catch {
            Logging.log("No cache hit for: \(list)")
            return nil
        }
    }

    func cache(_ data: Data, for list: String) {
        let listKey = key(for: list)
        let cacheFileURL = ListCache.cacheFolder.appendingPathComponent(listKey)
        do {
            if FileManager.default.fileExists(atPath: cacheFileURL.path) {
                try FileManager.default.removeItem(at: cacheFileURL)
            }
        } catch {
            Logging.log("Remove file error: \(error)")
        }

        do {
            try data.write(to: cacheFileURL)
        } catch {
            Logging.log("Write file error: \(error)")
        }
    }

    private func key(for list: String) -> String {
        let dateString = DateFormatter.cacheDate.string(from: Date())
        return "\(dateString)-\(list).json"
    }

    private static var cacheFolder: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let last = urls.last!
        let folderName = "org.themoviedb.www.cache"
        let cacheFolder = last.appendingPathComponent(folderName)
        Logging.log("Caches folder: \(cacheFolder)")
        do {
            try FileManager.default.createDirectory(at: cacheFolder, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            Logging.log("Create tmdb caches folder error \(error)")
        }
        return cacheFolder
    }()
}
