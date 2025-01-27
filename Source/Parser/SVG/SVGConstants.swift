//
//  SVGConstants.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 17/07/2020.
//

import Foundation

open class SVGConstants {

    static let groupTags = ["svg", "g"]

    static let availableStyleAttributes = [
        "stroke",
        "stroke-width",
        "stroke-opacity",
        "stroke-dasharray",
        "stroke-dashoffset",
        "stroke-linecap",
        "stroke-linejoin",
        "stroke-miterlimit",
        "fill",
        "fill-rule",
        "fill-opacity",
        "mask",
        "color",
        "stop-color",
        "stop-opacity",
        "font-family",
        "font-size",
        "font-weight",
        "text-anchor",
        "visibility",
        "display",
        "data-name",
    ]

}

public class SVGParserRegexHelper {

    fileprivate static let transformAttributePattern = "([a-z]+)\\(((\\-?\\d+\\.?\\d*e?\\-?\\d*\\s*,?\\s*)+)\\)"
    fileprivate static let transformPattern = "\\-?\\d+\\.?\\d*e?\\-?\\d*"
    fileprivate static let textElementPattern = "<text.*?>((?s:.*))<\\/text>"
    fileprivate static let maskIdenitifierPattern = "url\\(#((?s:.*))\\)"
    fileprivate static let unitsIdenitifierPattern = "([a-zA-Z]+)$"

    fileprivate static var transformMatcher: NSRegularExpression?
    fileprivate static var transformAttributeMatcher: NSRegularExpression?
    fileprivate static var textElementMatcher: NSRegularExpression?
    fileprivate static var maskIdenitifierMatcher: NSRegularExpression?
    fileprivate static var unitsMatcher: NSRegularExpression?

    class func getTransformAttributeMatcher() -> NSRegularExpression? {
        if self.transformAttributeMatcher == nil {
            do {
                self.transformAttributeMatcher = try NSRegularExpression(pattern: transformAttributePattern, options: .caseInsensitive)
            } catch {

            }
        }
        return self.transformAttributeMatcher
    }

    class func getTransformMatcher() -> NSRegularExpression? {
        if self.transformMatcher == nil {
            do {
                self.transformMatcher = try NSRegularExpression(pattern: transformPattern, options: .caseInsensitive)
            } catch {

            }
        }
        return self.transformMatcher
    }

    class func getTextElementMatcher() -> NSRegularExpression? {
        if self.textElementMatcher == nil {
            do {
                self.textElementMatcher = try NSRegularExpression(pattern: textElementPattern, options: .caseInsensitive)
            } catch {

            }
        }
        return self.textElementMatcher
    }

    class func getMaskIdenitifierMatcher() -> NSRegularExpression? {
        if self.maskIdenitifierMatcher == nil {
            do {
                self.maskIdenitifierMatcher = try NSRegularExpression(pattern: maskIdenitifierPattern, options: .caseInsensitive)
            } catch {

            }
        }
        return self.maskIdenitifierMatcher
    }

    class func getUnitsIdenitifierMatcher() -> NSRegularExpression? {
        if unitsMatcher == nil {
            do {
                unitsMatcher = try NSRegularExpression(pattern: unitsIdenitifierPattern, options: .caseInsensitive)
            } catch {

            }
        }
        return unitsMatcher
    }

}

