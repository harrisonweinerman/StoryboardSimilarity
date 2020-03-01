//
//  main.swift
//  StoryboardSimilarity
//
//  Created by Harrison Weinerman on 2/29/20.
//  Copyright © 2020 Harrison Weinerman. All rights reserved.
//

import Foundation

// Either pass in the directory you'd like to scan Storyboards in, or use the working directory
let searchPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : FileManager.default.currentDirectoryPath
let manager = StoryboardFileManager(searchDirectory: searchPath)
manager.check()
