//
//  Draggable.swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI


#if os(macOS)
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public struct Draggable: ViewModifier {
    
    @State var offset: CGSize = .zero
    @State var dragState: CGSize = .zero
    var shadowColor: Color
    var shadowRadius: CGFloat
    
    init(shadowColor: Color = .gray, radius: CGFloat = 5) {
        self.shadowColor = shadowColor
        self.shadowRadius = radius
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .global)
            .onChanged({ (value) in
                self.dragState = CGSize(width: value.translation.width, height: -value.translation.height)
            })
            .onEnded { (value) in
                self.offset.width += value.translation.width
                self.offset.height -= value.translation.height
                self.dragState = .zero
        }
    }
    
    
    
    public func body(content: Content) -> some View  {
        content
            .gesture(dragGesture)
            .offset(x: dragState.width + offset.width,
                    y: dragState.height + offset.height)
            .shadow(color: shadowColor, radius: dragState != .zero ? shadowRadius : 0)
    }
}

#else
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public struct Draggable: ViewModifier {
    
    @State var offset: CGSize = .zero
    @State var dragState: CGSize = .zero
    var shadowColor: Color
    var shadowRadius: CGFloat
    
    public init(shadowColor: Color = .gray, radius: CGFloat = 5) {
        self.shadowColor = shadowColor
        self.shadowRadius = radius
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .global)
            .onChanged({ (value) in
                self.dragState = value.translation
            })
            .onEnded { (value) in
                self.offset.width += value.translation.width
                self.offset.height += value.translation.height
                self.dragState = .zero
        }
    }
    
    
    
    public func body(content: Content) -> some View  {
        content
            .gesture(dragGesture)
            .offset(x: dragState.width + offset.width,
                    y: dragState.height + offset.height)
            .shadow(color: shadowColor, radius: dragState != .zero ? shadowRadius : 0)
    }
}
#endif

@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public extension View {
    
    /// Add To Drag Your View Around The Screen
    ///
    ///   - note:
    ///         If you want to resize or rotate you view as well make sure to this modifier last in the chain.  Not doing so will have unintended effects. The order draggable and throwable modifiers will always come last.
    ///
    func draggable() -> some View {
        self.modifier(Draggable())
    }
}
