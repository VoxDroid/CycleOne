@testable import CycleOne
import Foundation
import XCTest

final class LocalizationCoverageTests: XCTestCase {
    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private var appRoot: URL {
        repoRoot.appendingPathComponent("CycleOne")
    }

    private func localizedStringsFileURL(for languageCode: String) throws -> URL {
        let candidates = [
            appRoot.appendingPathComponent(
                "LocalizationResources/\(languageCode).lproj/Localizable.strings"
            ),
            appRoot.appendingPathComponent("\(languageCode).lproj/Localizable.strings"),
        ]

        for candidate in candidates where FileManager.default.fileExists(atPath: candidate.path) {
            return candidate
        }

        throw NSError(
            domain: "LocalizationCoverageTests",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Missing Localizable.strings for \(languageCode)"]
        )
    }

    private func keys(inStringsFileAt url: URL) throws -> Set<String> {
        let content = try String(contentsOf: url, encoding: .utf8)
        let regex = try NSRegularExpression(pattern: "^\\\"([^\\\"]+)\\\"\\s*=", options: [.anchorsMatchLines])
        let range = NSRange(content.startIndex ..< content.endIndex, in: content)

        var result = Set<String>()
        regex.enumerateMatches(in: content, options: [], range: range) { match, _, _ in
            guard
                let match,
                let keyRange = Range(match.range(at: 1), in: content)
            else {
                return
            }
            result.insert(String(content[keyRange]))
        }

        return result
    }

    private func extractLocalizedCandidates(from source: String) throws -> Set<String> {
        let patterns = [
            "Text\\(\\\"([^\\\"]+)\\\"",
            "Section\\(\\\"([^\\\"]+)\\\"",
            "Label\\(\\\"([^\\\"]+)\\\"",
            "navigationTitle\\(\\\"([^\\\"]+)\\\"",
            "Button\\(\\\"([^\\\"]+)\\\"",
            "ProgressView\\(\\\"([^\\\"]+)\\\"",
            "alert\\(\\\"([^\\\"]+)\\\"",
            "L10n\\.(?:string|format)\\(\\\"([^\\\"]+)\\\"",
            "title:\\s*\\\"([^\\\"]+)\\\"",
            "subtitle:\\s*\\\"([^\\\"]+)\\\"",
            "message:\\s*\\\"([^\\\"]+)\\\"",
        ]

        var candidates = Set<String>()
        for pattern in patterns {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(source.startIndex ..< source.endIndex, in: source)
            regex.enumerateMatches(in: source, options: [], range: range) { match, _, _ in
                guard
                    let match,
                    let keyRange = Range(match.range(at: 1), in: source)
                else {
                    return
                }

                let candidate = String(source[keyRange])
                if Self.shouldIgnoreCandidate(candidate) {
                    return
                }

                candidates.insert(candidate)
            }
        }

        return candidates
    }

    private static func shouldIgnoreCandidate(_ value: String) -> Bool {
        value.contains("\\(") || value.contains("\\u{")
    }

    private func appSwiftFiles() throws -> [URL] {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: appRoot,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }

        return enumerator.compactMap { item in
            guard let url = item as? URL else { return nil }
            return url.pathExtension == "swift" ? url : nil
        }
    }

    func testLocalizationKeyParityAcrossLanguages() throws {
        let en = try keys(inStringsFileAt: localizedStringsFileURL(for: "en"))
        let fil = try keys(inStringsFileAt: localizedStringsFileURL(for: "fil"))
        let ja = try keys(inStringsFileAt: localizedStringsFileURL(for: "ja"))
        let ko = try keys(inStringsFileAt: localizedStringsFileURL(for: "ko"))

        XCTAssertEqual(en, fil, "English and Filipino keys are out of sync")
        XCTAssertEqual(en, ja, "English and Japanese keys are out of sync")
        XCTAssertEqual(en, ko, "English and Korean keys are out of sync")
    }

    func testUserFacingSourceStringsExistInEnglishTable() throws {
        let englishKeys = try keys(
            inStringsFileAt: localizedStringsFileURL(for: "en")
        )

        var sourceCandidates = Set<String>()
        for file in try appSwiftFiles() {
            let source = try String(contentsOf: file, encoding: .utf8)
            let candidates = try extractLocalizedCandidates(from: source)
            sourceCandidates.formUnion(candidates)
        }

        let missing = sourceCandidates.subtracting(englishKeys)
            .filter { !$0.hasPrefix("http") }
            .sorted()

        XCTAssertTrue(
            missing.isEmpty,
            "Missing localization entries for: \(missing.joined(separator: ", "))"
        )
    }

    func testLocalizedPrivacyPolicyPagesExistForSupportedLanguages() {
        XCTAssertNotNil(AppLanguage.english.localizedResourceURL(forResource: "PrivacyPolicy", withExtension: "html"))
        XCTAssertNotNil(AppLanguage.filipino.localizedResourceURL(forResource: "PrivacyPolicy", withExtension: "html"))
        XCTAssertNotNil(AppLanguage.japanese.localizedResourceURL(forResource: "PrivacyPolicy", withExtension: "html"))
        XCTAssertNotNil(AppLanguage.korean.localizedResourceURL(forResource: "PrivacyPolicy", withExtension: "html"))
    }
}
