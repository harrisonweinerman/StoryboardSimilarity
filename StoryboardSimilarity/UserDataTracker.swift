//
//  UserDataTracker.swift
//  StoryboardSimilarity
//
//  Created by Harrison Weinerman on 4/5/21.
//  Copyright © 2021 Harrison Weinerman. All rights reserved.
//

import Foundation

class UserDataTracker {
    private typealias ProjectName = String
    private typealias StudentName = String
    private var projectsByStudent = [StudentName : [ProjectName]]()
    
    func log(student: String, project: String) {
        guard project != "project.xcworkspace", student != "student.xcuserdatad" else { return }
        if let _ = projectsByStudent[student] {
            projectsByStudent[student]?.append(project)
        } else {
            projectsByStudent[student] = [project]
        }
    }
    
    func printStudentsLoggedIntoMultipleFiles() {
        for (studentName, projects) in projectsByStudent {
            if projects.count > 1 {
                print("\(studentName) accessed \(projects.count) projects:")
                for project in projects {
                    print("\t\(project)")
                }
            }
        }
    }
}
