import Foundation

typealias UserCommands = Array<String>
extension UserCommands {
    func createCommandDictionary() -> [String: [String]] {
        var commands: [String: [String]] = [String: [String]]()
        var currentKey: String = ""
        for aCommand in self {
            if aCommand.hasPrefix("-") {
                currentKey = aCommand
            } else {
                if currentKey == "" {
                    continue
                }
                var userCommands = [String]()
                if let currentUserCommands = commands[currentKey] {
                    userCommands = currentUserCommands
                }
                userCommands.append(aCommand)
                commands[currentKey] = userCommands
            }
        }
        return commands
    }
}

class LocalizableSouceCodeWriter {

    let commands: [String]

    init(commands: [String]) {
        print("Begin init command")
        self.commands = commands
    }

    func executeCommand() {
        print("Begin execute command")
        guard commands.count >= 2 else {
            fatalError("insufficient commands")
        }
        let slicedCommands: UserCommands = Array(commands.dropFirst(1))
        let commandsDictionary = slicedCommands.createCommandDictionary()
        guard let outputFileCommands = commandsDictionary["-o"],
            let outputFile = outputFileCommands.first
        else {
            fatalError("Invalid Argument Error!")
        }        
        readAllLocalizableFilesAndMergeToMainFile(outputFile)
    }

    func readAllLocalizableFilesAndMergeToMainFile(_ path: String) {
        print("Begin read all localiz files")
        guard let file = try? File(path: path) else {
            print("Unable to load file at path: ", path)
            return
        }
        print("File name is:", file.nameExcludingExtension)

        print("Parent folder is:", file.parent?.name ?? "Unknow parent folder")

        let projectMainFolderPath = file.parent?.path ?? "Unknow parent folder" // Should split from path

        let localizeFileName = file.nameExcludingExtension

        let tempFileName = "tempLocalizable"
        let fileExtension = file.extension ?? "strings"

        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "d/MMM/YYYY"
        let current = dateFormater.string(from: Date())


        let yearFormater = DateFormatter()
        yearFormater.dateFormat = "YYYY"
        let year = yearFormater.string(from: Date())

        let header = """
        //
        //  \(localizeFileName).swift
        //  Infinity
        //
        //  Created by Phan Viet Trung on \(current).
        //  Copyright \(year) @Dwarves Foundation. All rights reserved.
        //

        /* This file is auto-generated. Do not edit. */
        """


        //Find all localizable files in project
        print("Find all localizable files at path: ", file.parent?.path ?? "Error: Empty path")
        let localizeFiles = findAllLocalizeableFiles(at: file.parent?.path ?? "")

        //Exclude main file
        let childLocalizeFiles = localizeFiles.filter { file in
            file.nameExcludingExtension != localizeFileName
        }

        //Create temp file to merge all localize data into it
        guard let mainFolder = try? Folder(path: projectMainFolderPath) else {
            print("Error: Can't find folder at path: \(projectMainFolderPath)")
            return
        }
        guard let tempLocalizableFile = try? mainFolder.createFile(named: tempFileName.appending(".\(fileExtension)")) else {
            print("Error: Can't create temp file")
            return
        }

        let commentRegax = #"\*(.|[\r\n])*?\*"#
        let regex = try! NSRegularExpression(pattern: commentRegax, options: .caseInsensitive)

        var localizeFinalString =  childLocalizeFiles.reduce(into: "") { partialResult, file in
            guard var fileContent = try? file.readAsString() else {
                print("Error: Can't read file: \(file.name)")
                return
            }

            let range = NSMakeRange(0, fileContent.count)
            fileContent = regex.stringByReplacingMatches(in: fileContent, options: [], range: range, withTemplate: "/\(file.nameExcludingExtension)/")

            partialResult += "\n"
            partialResult += fileContent
        }

        localizeFinalString = header + "\n" + localizeFinalString

        //Replace by temp file
        do {
            try tempLocalizableFile.write(localizeFinalString)
            if let oldLocalizableFile = try? mainFolder.file(named: localizeFileName + "." + fileExtension) {
                try oldLocalizableFile.delete()
            }
            try tempLocalizableFile.rename(to: localizeFileName)

        } catch {
            print(error)
            return
        }
    }

    func findAllLocalizeableFiles(at path: String) -> [File] {
        guard let folder = try? Folder(path: path) else { return [] }
        let files = folder.subfolders.recursive.reduce(into: []) { result, folder in
            result += folder.files.filter({ file in
                file.extension == "strings"
            })
        }

        for file in files {
            print("filename:", file.name)
        }

        return files
    }

}

/// Run Main Script
let sourceCodeWriter = LocalizableSouceCodeWriter(commands: CommandLine.arguments)
sourceCodeWriter.executeCommand()
