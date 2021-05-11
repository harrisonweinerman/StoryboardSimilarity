//
//  XcodeProjectParser.swift
//  StoryboardSimilarity
//
//  Created by Harrison Weinerman on 3/3/20.
//  Copyright © 2020 Harrison Weinerman. All rights reserved.
//

import Foundation

class XcodeProjectParser: NSObject, IDParser {
    private var path: String
    
    required init(path: String) {
        self.path = path
        super.init()
    }
    
    func parse() -> [String]? {
        var objectIDs = [String]()
        let url = URL(fileURLWithPath: path)
        do {
            let pbxprojData = try String(contentsOf: url).split { $0.isNewline }
            var hasFoundLines = false
            for line in pbxprojData {
                if !hasFoundLines && line == "/* Begin PBXFileReference section */" {
                    hasFoundLines = true
                    continue
                }
                
                if hasFoundLines && line == "/* End PBXFileReference section */" {
                    hasFoundLines = false
                    break
                }
                
                if hasFoundLines,
                    let idSubsequence = line.split(separator: " ").first {
                    let id = String(idSubsequence).trimmingCharacters(in: .whitespaces)
                    objectIDs.append(id)
                }
            }
        } catch {
            print("Error: unable to parse Xcode project at \(path)")
            return nil
        }
        return objectIDs
    }
}
