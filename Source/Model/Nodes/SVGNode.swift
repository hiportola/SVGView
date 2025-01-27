import SwiftUI
import Combine

public class SVGNode: SerializableElement, NSCopying {

    public var transform: CGAffineTransform = CGAffineTransform.identity
    @Published public var opaque: Bool
    @Published public var opacity: Double
    @Published public var clip: SVGNode?
    @Published public var mask: SVGNode?
    @Published public var id: String?
    @Published public var dataName: String?

    var gestures = [AnyGesture<()>]()

    public init(transform: CGAffineTransform = .identity, opaque: Bool = true, opacity: Double = 1, clip: SVGNode? = nil, mask: SVGNode? = nil, 
                id: String? = nil, dataName: String? = nil) {
        self.transform = transform
        self.opaque = opaque
        self.opacity = opacity
        self.clip = clip
        self.mask = mask
        self.id = id
        self.dataName = dataName
    }

    public func bounds() -> CGRect {
        let frame = frame()
        return CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    public func frame() -> CGRect {
        fatalError()
    }

    public func getNode(byId id: String) -> SVGNode? {
        return self.id == id ? self : .none
    }
    
    public func getNode(byDataName dataName: String) -> SVGNode? {
        return self.dataName == dataName ? self : getNode(byId: dataName)
    }

    public func onTapGesture(_ count: Int = 1, tapClosure: @escaping ()->()) {
        let newGesture = TapGesture(count: count).onEnded {
            tapClosure()
        }
        gestures.append(AnyGesture(newGesture.map { _ in () }))
    }

    public func addGesture<T: Gesture>(_ newGesture: T) {
        gestures.append(AnyGesture(newGesture.map { _ in () }))
    }

    public func removeAllGestures() {
        gestures.removeAll()
    }

    public func serialize(_ serializer: Serializer) {
        if !transform.isIdentity {
            let t = transform
            let s = "matrix(\(t.a), \(t.b), \(t.c), \(t.d), \(t.tx), \(t.ty))"
            serializer.add("transform", s)
        }
        serializer.add("opacity", opacity, 1)
        serializer.add("opaque", opaque, true)
        serializer.add("clip", clip).add("mask", mask)
    }

    public var typeName: String {
        return String(describing: type(of: self))
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = SVGNode(transform: self.transform, opaque: self.opaque, opacity: self.opacity,
                           clip: self.clip, mask: self.mask, id: self.id, dataName: self.dataName)
        return copy
    }
}

extension SVGNode {
    @ViewBuilder
    public func toSwiftUI() -> some View {
        switch self {
        case let model as SVGViewport:
            SVGViewportView(model: model)
        case let model as SVGGroup:
            model.contentView()
        case let model as SVGRect:
            model.contentView()
        case let model as SVGText:
            model.contentView()
        case let model as SVGDataImage:
            model.contentView()
        case let model as SVGURLImage:
            model.contentView()
        case let model as SVGEllipse:
            model.contentView()
        case let model as SVGLine:
            model.contentView()
        case let model as SVGPolyline:
            model.contentView()
        case let model as SVGPath:
            model.contentView()
        case let model as SVGCircle:
            model.contentView()
        case let model as SVGUserSpaceNode:
            model.contentView()
        case let model as SVGPolygon:
            model.contentView()
        case is SVGImage:
            fatalError("Base SVGImage is not convertable to SwiftUI")
        case is SVGShape:
            fatalError("Base shape SVGShape is not convertable to SwiftUI")
        default:
            fatalError("Base SVGNode is not convertable to SwiftUI")
        }
    }
}
