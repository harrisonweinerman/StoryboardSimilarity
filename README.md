# StoryboardSimilarity
Measures similarity of Storyboard files to help detect suspected plagiarism in iOS development classes.

## What it Does
Storyboards create an object ID for each item you add. Usually, these are random, and as such they probably
should be unique to projects. If 2 people independently make the exact same app (and Storyboard), they will
have different object IDs in the Storyboard XML. If someone plagiarizes part of a project (i.e. copies a
Storyboard or an entire project then tries to modify it to make it their own), it is likely that object IDs will be 
copied.

StoryboardSimilarity checks for unique object IDs in projects for common Storyboard components and reports
any object IDs that are used across files which may be an indication of plagiarism.

Certain components, like the default View Controller scene, its view, and First Responder, are common between
Storyboard files. These object IDs are removed from results, but feel free to add or remove some of these IDs in
`StoryboardParser.swift` if you're running into any trouble.

Currently, the project is configured only to check object IDs of UI components that are of note in USC's iOS
class homeworks. Feel free to add more components to the whitelist in `StoryboardParser.swift`.

If you see object IDs are identical between Storyboards, open each Storyboard as XML, either in a text editor
or by right clicking the Storyboard in Xcode and choosing *Open As>Source Code*. Search for the object ID 
that was flagged and determine its interest. If it is just the default scene, it is probably not plagiarism. If UI
components, constraints, etc. have identical IDs, it may be cause for further investigation.

**Just like Stanford's MOSS, this project cannot automatically detect plagiarism, and all results should be interpreted by a human!**

## Preparation
It's easiest to move all of the Xcode projects to a folder. The Storyboards can be nested at any level, but for the results to be useful, you'll want filepath to contain the student's name.

Alternatively, you can move just the Storyboard files without the rest of the Xcode project, but you'll want to
rename the files so you know which is which.

## How to Use
Just run the tool, passing in a path to the directory you'd like to scan for Storyboards in.
`./StoryboardSimilarity ~/Documents/XcodeProjects`

Or, run with no argument to scan the directory where you're running from.
`./StoryboardSimilarity`
