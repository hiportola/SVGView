//
//  Serializer.swift
//  SVGView
//
//  Created by Yuriy Strot on 17.01.2021.
//

import Foundation
import CoreGraphics

public class Serializer {

    public static func serialize(_ serializable: SerializableBlock) -> String {
        return serialize(serializable, level: 0) + "\n"
    }

    public static func serialize(_ serializable: SerializableBlock, level: Int) -> String {
        let serializer = Serializer(level: level)
        var prefix = ""
        var elId = ""
        if let element = serializable as? SerializableElement {
            prefix = typeNameForElement(element)
            elId = element.id ?? ""
            serializer.add("id", element.id)
        }
        serializable.serialize(serializer)
        if serializer.children.count > 0 {
            return "<" + prefix + " id=\"\(elId)\">" + serializer.toString() + "</" + prefix + ">"
        } else {
            return "<" + prefix + " id=\"\(elId)\"" + serializer.toString() + "/>"
        }
    }
    
    private static func typeNameForElement(_ se:SerializableElement) -> String {
        switch se {
        case is SVGViewport: return "viewport"
        case is SVGGroup: return "g"
        case is SVGRect: return  "rect"
        case is SVGText: return "text"
        case is SVGDataImage: return "unsupported"
        case is SVGURLImage: return "unsupported"
        case is SVGEllipse: return "ellipse"
        case is SVGLine: return "line"
        case is SVGPolyline: return "polyline"
        case is SVGPath: return "path"
        case is SVGCircle: return "circle"
        case is SVGUserSpaceNode: return "unsupported"
        case is SVGPolygon: return "polygon"
        case is SVGImage: return "unsupported"
        case is SVGShape: return "unsupported"
        default: return "unsupported"
        }
        return ""
    }

    private let level: Int

    private var blocks = [String]()
    private var text = ""
    private var complex = false
    private var children: [SVGNode] = []

    private init(level: Int) {
        self.level = level
    }
    
    @discardableResult func addChildren(_ nodes: [SVGNode]) {
        children = nodes
    }

    @discardableResult func add<S: SerializableAtom>(_ key: String, _ value: S?) -> Serializer {
        if let val = value {
            add(key: key, block: val.serialize())
        }
        return self
    }

    @discardableResult func add<S>(_ key: String, _ value: S, _ defVal: S) -> Serializer where S: SerializableAtom, S: Equatable {
        if (value != defVal) {
            add(key: key, block: value.serialize())
        }
        return self
    }

    @discardableResult public func add<S: SerializableOption>(_ key: String, _ value: S) -> Serializer {
        if !value.isDefault() {
            add(key: key, block: "\"\(value.serialize())\"")
        }
        return self
    }

    @discardableResult public func add(_ key: String, _ value: SerializableBlock?) -> Serializer {
        if let val = value {
            makeComplex()
            add(key: key, block: Serializer.serialize(val, level: level + 1))
        }
        return self
    }

    @discardableResult public func add(_ key: String, _ values: [SerializableBlock]) -> Serializer {
        if !values.isEmpty {
            makeComplex()
            add(key: key, block: "[")
            var isFirst = true
            for value in values {
                if isFirst {
                    isFirst = false
                } else {
                    text += ","
                }
                text += "\n" + indent(level + 2) + Serializer.serialize(value, level: level + 2)
            }
            text += "\n\(indent(level + 1))]"
        }
        return self
    }

    private func toString() -> String {
        if complex {
            return text + "\n" + indent(level)
        }
        let length = blocks.reduce(0) { $0 + $1.count }
        if length > 60 {
            let ind = indent(level + 1)
            return "\(ind)\(blocks.joined(separator: " "))\n\(indent(level))"
        }
        var str = blocks.joined(separator: " ")
        //if children.count > 0 { str += ">" }
        children.forEach { n in
            str += "\n\(indent(level + 1))\(Serializer.serialize(n))"
        }
        return str
    }

    private func makeComplex() {
        if !complex {
            complex = true
            for block in blocks {
                add(block: block)
            }
            blocks = []
        }
    }

    private func add(key: String, block: String) {
        add(block: "\(key)=\(block)")
    }

    private func add(block: String) {
        if complex {
            add(string: block)
        } else {
            blocks.append(block)
        }
    }

    private func add(string: String) {
        if !text.isEmpty {
            text += ","
        }
        text += "\n" + indent(level + 1) + string
    }

    private func indent(_ indent: Int) -> String {
        return String(repeating: "\t", count: indent)
    }

}
