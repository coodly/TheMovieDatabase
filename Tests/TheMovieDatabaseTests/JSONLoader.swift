/*
 * Copyright 2017 Coodly LLC
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

protocol JSONLoader {
    func json<Result>(from file: String) -> Result
}

extension JSONLoader {
    func json<Result>(from file: String) -> Result {
        let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("TestData", isDirectory: true)
            .appendingPathComponent("\(file).json")
        let data =  try! Data(contentsOf: path)
        return try! JSONSerialization.jsonObject(with: data, options: []) as! Result
    }
}
