//
//  RotationOverlayModel.swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI

@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public class RotationOverlayModel<Handle: View>: ObservableObject, RotationModel {
    
    
    // MARK: State
    // distance from the top of the view to the rotation handle
    var radialOffset: CGFloat = 50
    @Binding public var angle: CGFloat
    @Published public var gestureState: RotationOverlayState = RotationState.inactive
    @Binding public var isSelected: Bool
    
    var handle: (Bool, Bool) -> Handle
    
    /// Use to model the state of the rotation handles drag gesture.
    /// The movement of the rotation handle is restricted to the radius of the circle given by half the height of the rotated view plus the `radialOffset`
    enum RotationState: RotationOverlayState {
        case inactive
        case active(translation: CGSize, deltaTheta: CGFloat)
        
        /// `DragGesture`'s translation value
        var translation: CGSize {
            switch self {
            case .active(let translation, _):
                return translation
            default:
                return .zero
            }
        }
        /// Value calculated by restricting the translation to a specific radius.
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
    
    
    
    // MARK: Calculations 
    
    // Calculates the radius of the circle that the rotation handle is constrained to.
    public func calculateRadius(proxy: GeometryProxy, magnification: CGFloat = 1) -> CGFloat {
        return (proxy.size.height/2)*magnification + radialOffset
        
    }
    
    // Calculates the change in angle when the rotational handle is dragging
    public func calculateDeltaTheta(radius: CGFloat, translation: CGSize) -> CGFloat {
        
        let lastX = radius*sin(angle)
        let lastY = -radius*cos(angle)
        
        let newX = lastX + translation.width
        let newY = lastY + translation.height
        let newAngle = atan2(newY, newX) + .pi/2
        
        return (newAngle-angle)
        
    }
    
    // The Y component of the bottom handles should not affect the offset of the rotation handle
    // The Y component of the top handles are doubled to compensate.
    // All X components contribute half of their value.
    public func calculateRotationalOffset(proxy: GeometryProxy, rotationGestureState: CGFloat = 0, magnification: CGFloat = 1, dragWidths: CGFloat = 0, dragTopHeights: CGFloat = 0) -> CGSize {
           
           let angles = angle + gestureState.deltaTheta + rotationGestureState
           
           
           let rX = sin(angles)*(calculateRadius(proxy: proxy, magnification: magnification))
           let rY = -cos(angles)*(calculateRadius(proxy: proxy, magnification: magnification))
           let x =   rX + cos(angle)*dragWidths/2 - sin(angle)*dragTopHeights
           let y =   rY + cos(angle)*dragTopHeights + sin(angle)*dragWidths/2
           
           
           return CGSize(width: x, height: y)
       }
    
    
    public func getOverlay(proxy: GeometryProxy, rotationGestureState: CGFloat = 0, magnification: CGFloat = 1, dragWidths: CGFloat = 0, dragTopHeights: CGFloat = 0) -> AnyView {
        AnyView(ZStack {
            handle(isSelected, (gestureState as! RotationState).isActive)
        }
        .offset(calculateRotationalOffset(proxy: proxy, rotationGestureState: rotationGestureState, magnification: magnification, dragWidths: dragWidths, dragTopHeights: dragTopHeights))
        .gesture(
            DragGesture()
                .onChanged({ (value) in
                    let radius = self.calculateRadius(proxy: proxy)
                    let deltaTheta = self.calculateDeltaTheta(radius: radius, translation: value.translation)
                    self.gestureState = RotationState.active(translation: value.translation, deltaTheta: deltaTheta)
                })
                .onEnded({ (value) in
                    let radius = self.calculateRadius(proxy: proxy)
                    self.angle += self.calculateDeltaTheta(radius: radius, translation: value.translation)
                    self.gestureState = RotationState.inactive
                })
        ))
    }
    
    
    
    
    
    // MARK: Init
    
    public init(angle: Binding<CGFloat>, isSelected: Binding<Bool>, @ViewBuilder handle: @escaping (Bool, Bool) -> Handle) {
        self._angle = angle
        self._isSelected = isSelected
        self.handle = handle
    }
    
}
