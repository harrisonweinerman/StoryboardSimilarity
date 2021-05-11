//
//  StoryboardParser.swift
//  StoryboardSimilarity
//
//  Created by Harrison Weinerman on 2/29/20.
//  Copyright © 2020 Harrison Weinerman. All rights reserved.
//

import Foundation

/// Represents a Storyboard and its XML
class StoryboardParser: NSObject, XMLParserDelegate, IDParser {
    /// Components of interest supported by this parser. Feel free to add more.
    private static let inspectableElements: Set<String> = [
        "view",
        "label",
        "imageView",
        "constraint",
        "placeholder",
        "scene",
        "button",
        "outlet",
        "textField",
        "segmentedControl",
        "action",
        "switch",
        "stepper",
        "slider",
        "tapGestureRecognizer",
        
    ]
    
    /// Some IDs are okay to be common between projects
    private static let ignoredIDs: Set<String> = [
        "tne-QT-ifu", // Default scene
        "BYZ-38-t0r", // Default root VC
        "8bC-Xf-vdC", // Default root VC's view
        "dkx-z0-nzr", // Default first responder
        "EHf-IW-A2E", // Alternate default scene
        "Ze5-6b-2t3", // Alternate default root VC's view
        "iYj-Kq-Ea1", // Alternate default first responder
    ]
    
    private var objectIDs = [String]()
    private var path: String
    
    required init(path: String) {
        self.path = path
        super.init()
    }
    
    /// Parses the Storyboard represented by this parser
    /// - returns: Array of object IDs in this Storyboard, or nil if the path was not valid XML
    func parse() -> [String]? {
        let url = URL(fileURLWithPath: path)
        guard let parser = XMLParser(contentsOf: url) else {
            print("Error: unable to parse \(url)")
            return nil
        }
        parser.delegate = self
        parser.parse()
        return objectIDs
    }
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        guard StoryboardParser.isInspectableElement(elementName) else { return }
        var relevantID: String?
        // Scenes do not have an ID, they have a sceneID
        if elementName == "scene", let id = attributeDict["sceneID"] {
            relevantID = id
        } else if let id = attributeDict["id"] {
            relevantID = id
        }
        
        if let id = relevantID, !StoryboardParser.isIgnoredID(id) {
            objectIDs.append(id)
        }
    }

    private static func isInspectableElement(_ elementName: String) -> Bool {
        return inspectableElements.contains(elementName)
    }
    
    private static func isIgnoredID(_ id: String) -> Bool {
        ignoredIDs.contains(id)
    }
}
