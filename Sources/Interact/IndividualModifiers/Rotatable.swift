//
//  Rotatable.swift
//  
//
//  Created by Kieran Brown on 11/15/19.
//

import Foundation
import SwiftUI


/// # Rotatable Modifier
/// Provides a handle above a view which can be dragged in a circular motion and rotates the view to the corresponding angle.
/// Also allows the RotationGesture to be performed on the modified view.
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
struct Rotatable: ViewModifier {
    @State var angle: CGFloat = 0
    @State var dragState: RotateState = .inactive
    @State var rotationState: CGFloat = 0
    @State var isSelected: Bool = false
    var radialOffset: CGFloat = 50
    var handleSize: CGSize = CGSize(width: 30, height: 30)
    
    /// Modified drag state, has a deltaTheta value to use when the gesture is in progress.
    enum RotateState {
        case inactive
        case active(translation: CGSize, deltaTheta: CGFloat)
        
        var translation: CGSize {
            switch self {
            case .active(let translation, _):
                return translation
            default:
                return .zero
            }
        }
        
        var deltaTheta: CGFloat {
            switch self {
            case .active(_, let angle):
                return angle
            default:
                return .zero
            }
        }
        
        var isActive: Bool {
            switch self {
            case .active(_ , _):
                return true
            default:
                return false
            }
        }
    }
    
    /// Returns the radius of  rotation
    private func calculateRadius(proxy: GeometryProxy) -> CGFloat {
        return proxy.size.height/2 + radialOffset
    }
    
    /// Returns the offset of the rotation handle
    private func calculateOffset(proxy: GeometryProxy) -> CGSize {
        let x = calculateRadius(proxy: proxy)*sin(angle + dragState.deltaTheta + rotationState)
        let y = -calculateRadius(proxy: proxy)*cos(angle + dragState.deltaTheta + rotationState)
        return CGSize(width: x, height: y)
    }
    
    /// Returns the change of angle from the dragging the handle
    private func calculateDeltaTheta(proxy: GeometryProxy, translation: CGSize) -> CGFloat {
        let radius = calculateRadius(proxy: proxy)
        
        let lastX = radius*sin(self.angle)
        let lastY = -radius*cos(self.angle)
        
        let newX = lastX + translation.width
        let newY = lastY + translation.height
        
        let newAngle = atan2(newY, newX) + .pi/2
  
        return (newAngle-self.angle)
        
    }
    
    private var handleOverlay: some View {
        GeometryReader { (proxy: GeometryProxy) in
            Circle()
                .frame(width: self.handleSize.width, height: self.handleSize.height)
                .offset(self.calculateOffset(proxy: proxy))
                .gesture(
                    DragGesture()
                        .onChanged({ (value) in
                            let deltaTheta = self.calculateDeltaTheta(proxy: proxy, translation: value.translation)
                            self.dragState = .active(translation: value.translation, deltaTheta: deltaTheta)
                        })
                        .onEnded({ (value) in
                            self.angle += self.calculateDeltaTheta(proxy: proxy, translation: value.translation)
                            self.dragState = .inactive
                        })
            )
        }
    }
    
    func body(content: Content) -> some View  {
        content
            .rotationEffect(Angle(radians: Double(self.angle + dragState.deltaTheta + rotationState) ))
            .gesture(
                RotationGesture()
                    .onChanged({ (value) in
                        self.rotationState = CGFloat(value.radians)
                    })
                    .onEnded({ (value) in
                        self.angle += CGFloat(value.radians)
                        self.rotationState = 0
                    })
        ).onTapGesture {
            withAnimation(.easeIn(duration: 0.2)) {
                self.isSelected.toggle()
            }
        }
        .overlay(handleOverlay.opacity(isSelected ? 1 : 0))
    }
}


@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
extension View {
    /// # Rotatable Modifier
    /// Provides a handle above a view which can be dragged in a circular motion and rotates the view to the corresponding angle.
    /// Also allows the RotationGesture to be performed on the modified view.
    func rotatable() -> some View {
        self.modifier(Rotatable())
    }
    
    
    func rotatable(drag: DragType? = .none) -> some View {
        switch drag {
        case .normal:
            return AnyView(self.modifier(DraggableRotatable()))
        case .throwable:
            return AnyView(self.modifier(ThrowableRotatable()))
        case .none:
            return AnyView(self.modifier(Rotatable()))
        }
    }
}

