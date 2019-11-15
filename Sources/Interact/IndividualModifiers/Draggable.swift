//
//  Draggable.swift
//  
//
//  Created by Kieran Brown on 11/15/19.
//

import Foundation
import SwiftUI

@available(iOS 13.0, watchOS 6.0 , tvOS 13.0, *)
public struct Draggable: ViewModifier {
    
    @State var offset: CGSize = .zero
    @GestureState var dragState: DragState = .inactive
    var shadowColor: Color
    var shadowRadius: CGFloat
    
    init(shadowColor: Color? = .gray, radius: CGFloat? = 5) {
        self.shadowColor = shadowColor!
        self.shadowRadius = radius!
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .global)
            .updating($dragState) { (value, state, _) in
                state = .active(translation: value.translation)
        }.onEnded { (value) in
            self.offset.width += value.translation.width
            self.offset.height += value.translation.height
        }
    }
    
    enum DragState {
        case inactive
        case active(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .active(translation: let translation):
                return translation
            default:
                return .zero
            }
        }
        
        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .active(_):
                return true
            }
        }
    }
    
    public func body(content: Content) -> some View  {
        
        ZStack {
            content
            .simultaneousGesture(dragGesture)
        }.offset(x: dragState.translation.width + offset.width,
                 y: dragState.translation.height + offset.height)
            .shadow(color: shadowColor, radius: dragState.isActive ? shadowRadius : 0)
    }
}


@available(iOS 13.0, watchOS 6.0 , tvOS 13.0, *)
public extension View {
    func draggable() -> some View {
        self.modifier(Draggable())
    }
    
    
    func draggable(shadowColor: Color?, radius: CGFloat?) -> some View {
        self.modifier(Draggable(shadowColor: shadowColor, radius: radius))
    }
    
}
