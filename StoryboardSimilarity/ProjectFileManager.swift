//
//  ProjectFileManager.swift
//  StoryboardSimilarity
//
//  Created by Harrison Weinerman on 2/29/20.
//  Copyright © 2020 Harrison Weinerman. All rights reserved.
//

import Foundation

/// Responsible for finding Xcode projects and Storyboard files in the search directory, creating a
/// `StoryboardParser` for each Storyboard and an `XcodeProjectParser` for each Xcode project.
/// Unique identifiers are cached to derive similarity results.
class ProjectFileManager: NSObject {
    var storyboardFilePaths = [String]()
    var pbxprojFilePaths = [String]()
    private typealias ObjectID = String
    private typealias StudentName = String
    
    private let userDataTracker = UserDataTracker()
    private var objectIDs = [ObjectID : [StudentName]]()
    private var studentSimilarityIncidents = [StudentName : [(StudentName, ObjectID)]]()
    
    required init(searchDirectory path: String) {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(atPath: path) else {
            print("Error: Unable to enumerate files at: \(path)")
            super.init()
            return
        }
        // Find all relevant files in the search directory
        while let file = enumerator.nextObject() as? String {
            if file.hasSuffix("storyboard") && !file.contains("LaunchScreen") {
                storyboardFilePaths.append(path + "/\(file)")
            }
            if file.hasSuffix("pbxproj") && !file.contains("Pods") {
                pbxprojFilePaths.append(path + "/\(file)")
            }
            if file.hasSuffix("xcuserdatad") {
                if let studentName = URL(string: file)?.lastPathComponent,
                   let projectName = URL(string: file)?.deletingLastPathComponent().deletingLastPathComponent().lastPathComponent
                   {
                    userDataTracker.log(student: studentName, project: projectName)
                } else {
                    print("Error: not able to unwrap student and/or project name parsing xcuserdatad for \(file)")
                }
            }
        }
        print("Found \(storyboardFilePaths.count) Storyboards in \(path)")
        print("Found \(pbxprojFilePaths.count) Xcode projects in \(path)")
        super.init()
    }
    
    /// Checks for similarities in the Storyboards found in the search directory and prints the results
    func check() {
        // Find students who may have sent/opened each other's projects
        userDataTracker.printStudentsLoggedIntoMultipleFiles()
        
        // Find identical Storyboard objects
        for path in storyboardFilePaths {
            let parser = StoryboardParser(path: path)
            parser.parse()?.forEach { id in
                // Associate this student with this object ID,
                // or, add this student to the list of students associated with this object id
                objectIDs[id] = (objectIDs[id] ?? [StudentName]()) + [path]
            }
        }
        
        // Find identical Xcode project references
        for path in pbxprojFilePaths {
            let parser = XcodeProjectParser(path: path)
            parser.parse()?.forEach{ id in
                objectIDs[id] = (objectIDs[id] ?? [StudentName]()) + [path]
            }
        }
        
        // Tally repeated objects per student
        for (id, studentNames) in objectIDs {
            // We are not interested in object IDs found just once, since they are unique to a student
            if studentNames.count > 1 {
                for name in studentNames {
                    // For each instance of this object ID being found in another student's
                    // storyboard, log this on the student.
                    var newSimilarityIncidents = studentSimilarityIncidents[name] ?? [(StudentName, ObjectID)]()
                    newSimilarityIncidents += studentNames.filter({ $0 != name }).map({ ($0, id) })
                    studentSimilarityIncidents[name] = newSimilarityIncidents
                }
            }
        }
        
        // Format results
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        print("Begin Storyboard Similarity Results (\(formatter.string(from: Date())))")
        for (studentName, studentInfractions) in studentSimilarityIncidents {
            // Print each student's total count of similarity incidents followed by
            // each non-unique object ID and the file where it was also located
            print("\n\n\(studentName): \(studentInfractions.count) identical object IDs")
            for infraction in studentInfractions {
                print("\t\(infraction.1) matched student \(infraction.0)")
            }
        }
        print("End Storyboard Similarity Results (\(formatter.string(from: Date())))")
    }
}
