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
            guard let pr = typeNameForElement(element) else { return "" }
            prefix = pr
            elId = element.id ?? ""
            serializer.add("id", element.id)
        }
        serializable.serialize(serializer)
//        print("Serialize (\(level)) prefix: \(prefix) | elId: \(elId) | childCount: \(serializer.children.count)")
        return "<\(prefix) \(serializer.paramsString())>\(serializer.childrenString())</\(prefix)>"
    }

    private func paramsString() -> String {
        return blocks.joined(separator: " ")
    }

    private func childrenString() -> String {
        if complex {
            return text + "\n" + indent(level)
        }

        var str = ""
        children.forEach { n in
//            print("    toString \(n)")
            str += "\n\(indent(level + 1))\(Serializer.serialize(n))"
        }
        return str
    }

    private static func typeNameForElement(_ se:SerializableElement) -> String? {
        switch se {
        case is SVGViewport: return "viewport"
        case is SVGGroup: return "g"
        case is SVGRect: return  "rect"
        case is SVGText: return "text"
        case is SVGEllipse: return "ellipse"
        case is SVGLine: return "line"
        case is SVGPolyline: return "polyline"
        case is SVGPath: return "path"
        case is SVGCircle: return "circle"
        case is SVGPolygon: return "polygon"
//        case is SVGUserSpaceNode: return "unsupported4"
//        case is SVGDataImage: return "unsupported6"
//        case is SVGURLImage: return "unsupported5"
//        case is SVGImage: return "unsupported3"
//        case is SVGShape: return "unsupported2"
        default: return nil
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
            add(key: key, block: "\"\(value.serialize())\"")
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

    private func makeComplex() {
        if !complex {
            print("MAKE COMPLEX")
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
