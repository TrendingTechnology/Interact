//
//  DraggableRotatable.swift
//  
//
//  Created by Kieran Brown on 11/15/19.
//

import Foundation
import SwiftUI



/// # Draggable And Rotatable
/// Provides a handle above a view which can be dragged in a circular motion and rotates the view to the corresponding angle.
/// Also allows the RotationGesture to be performed on the modified view.
@available(iOS 13.0, watchOS 6.0 , tvOS 13.0, *)
public struct DraggableRotatable: ViewModifier {
    
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
    
    
    
    @State var angle: CGFloat = 0
    @State var rotateState: RotateState = .inactive
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
        let x = calculateRadius(proxy: proxy)*sin(angle + rotateState.deltaTheta + rotationState)
        let y = -calculateRadius(proxy: proxy)*cos(angle + rotateState.deltaTheta + rotationState)
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
                            self.rotateState = .active(translation: value.translation, deltaTheta: deltaTheta)
                        })
                        .onEnded({ (value) in
                            self.angle += self.calculateDeltaTheta(proxy: proxy, translation: value.translation)
                            self.rotateState = .inactive
                        })
            )
        }
    }
    
    public func body(content: Content) -> some View  {
        content
        .shadow(color: shadowColor, radius: shadowRadius)
        .simultaneousGesture(dragGesture)
            .rotationEffect(Angle(radians: Double(self.angle + rotateState.deltaTheta + rotationState) ))
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
        .offset(x: offset.width + dragState.translation.width,
                y: offset.height + dragState.translation.height)
    }
}
