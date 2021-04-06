import Foundation
import Files

//MARK: - Parse data
let tsvFolder = try! Folder.home.createSubfolderIfNeeded(withName: "tsvSheetsTranslations")
let dataEn = readFile(folder: tsvFolder, name: "input-en.tsv")
let dataEs = readFile(folder: tsvFolder, name: "input-es.tsv")

print("Parsing all strings in <homeFolder>/input-en.tsv")
print("Parsing all strings in <homeFolder>/input-es.tsv")
let inputEn = getTSVString(data: dataEn)
let inputEs = getTSVString(data: dataEs)

//MARK: - Treat data

//English for all
let filenames = inputEn.first!
for (i, name) in filenames.enumerated() {
    guard i != 0 else { continue }

    var rows = [String]()
    for j in 0 ..< inputEn.count {
        guard j != 0 else { continue }
        let id = inputEn[j][0]
        var value = inputEn[j][i]
        if let firstTransChar = value.first,
           let firstOriginalChar = inputEn[j][1].first {

            let charTranslation = String(firstTransChar)
            let charOriginal = String(firstOriginalChar)
            if isUppercase(string: charOriginal),
               !isUppercase(string: charTranslation) {
                value.capitalizeFirstLetter()
            }
        }
        rows.append("\"\(id)\" = \"\(value)\";")
    }
    let united = rows.joined(separator: "\n")
    save(string: united, countryName: name)
}

//Spanish for latin languages only
let filenamesEs = inputEs.first!
for (i, name) in filenamesEs.enumerated() {
    guard i != 0 else { continue }
    guard let lang = LanguageCode(rawValue: name),
          lang.isLatin else {
        continue
    }
    
    var rows = [String]()
    for j in 0 ..< inputEs.count {
        guard j != 0 else { continue }
        let id = inputEs[j][0]
        var value = inputEs[j][i]
        if let firstTransChar = value.first,
           let firstOriginalChar = inputEs[j][2].first {
            
            let charTranslation = String(firstTransChar)
            let charOriginal = String(firstOriginalChar)
            if isUppercase(string: charOriginal),
               !isUppercase(string: charTranslation) {
                value.capitalizeFirstLetter()
            }
        }
        rows.append("\"\(id)\" = \"\(value)\";")
    }
    let united = rows.joined(separator: "\n")
    guard united.count > 0 else { continue }
    save(string: united, countryName: name)
}


//MARK: - Private

func save(string: String, countryName: String) {
    let countryFolder = try! tsvFolder.createSubfolderIfNeeded(withName: "\(countryName).lproj")
    let file = try! countryFolder.createFile(named: "Localizable.strings")
    try! file.write(string, encoding: .utf8)
    print("Writing strings for \(countryName)")
}

func readFile(folder: Folder, name: String) -> Data {
    let file = try! folder.file(named: name)
    let data = try! file.read()
    return data
}

func getTSVString(data: Data) -> [[String]] {
    let content = String(decoding: data, as: UTF8.self)
    let rows: [String] = content.components(separatedBy: "\n")
    var result = [[String]]()
    for r in rows {
        let columns = r.components(separatedBy: "\t")
        result.append(columns)
    }
    return result
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

func isUppercase(string: String) -> Bool {
    let set = CharacterSet.uppercaseLetters
    
    if let scala = UnicodeScalar(string) {
        return set.contains(scala)
    } else {
        return false
    }
}

enum LanguageCode: String {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case cs = "cs"
    case el = "el"
    case fi = "fi"
    case he = "he"
    case hu = "hu"
    case italian = "it"
    case japanese = "ja"
    case korean = "ko"
    case polish = "pl"
    case portuguese = "pt"
    case romanian = "ro"
    case russian = "ru"
    case sv = "sv"
    case th = "th"
    
    var isLatin: Bool {
        switch self {
        case .spanish, .french, .romanian, .italian, .portuguese:
            return true
        default:
            return false
        }
    }
}
