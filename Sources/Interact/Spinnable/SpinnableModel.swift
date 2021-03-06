//
//  SpinnableModel.swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI


/// Data model describing a view that can be rotated and spun with a handle.
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public class SpinnableModel<Handle: View>: ObservableObject, RotationModel {
    
    
    // MARK: State
    var model: AngularVelocityModel
    /// This is kind of like the angular equivalent of a draggable view's `offset`.
    @Binding public var angle: CGFloat
    /// Describes the angular drag state of the rotation handle. 
    @Published public var gestureState: RotationOverlayState = SpinState.inactive
    @Binding public var isSelected: Bool
    /// Value describing the distance from the top of the view to the rotation handle.
    var radialOffset: CGFloat = 50
    /// Value used to scale down the velocity of a drag.
    let vScale: CGFloat = 0.5
    /// minimum angular velocity required to start spinning the view.
    var threshold: CGFloat = 0
    var handle: (Bool, Bool) -> Handle
    
    
    /// #  Spin State
    /// Used to keep track of a drag gesture that is constrained to a circle.
    /// Allows access to variables such as the change in angle `deltaTheta`
    ///  or the `angularVelocity` of a `DragGesture` Constrained to a radius.
    enum SpinState: RotationOverlayState {
        case inactive
        case active(translation: CGSize, time: Date?, deltaTheta: CGFloat, angularVelocity: CGFloat)
        
        /// `DragGesture`'s translation value
        var translation: CGSize {
            switch self {
            case .active(let translation, _, _, _):
                return translation
            default:
                return .zero
            }
        }
        /// `DragGesture`s time value
        var time: Date? {
            switch self {
            case .active(_, let time, _, _):
                return time
            default:
                return nil
            }
        }
        /// The change in angle from the last translation to the current translation.
        /// A computed value that requires the drag be constrained to a radius.
        var deltaTheta: CGFloat {
            switch self {
            case .active(_, _, let angle, _):
                return angle
            default:
                return .zero
            }
        }
        /// Angular velocity is computed from the deltaTheta/deltaTime
        var angularVelocity: CGFloat {
            switch self {
            case .active(_, _, _, let velocity):
                return velocity
            default:
                return .zero
            }
        }
        
        
        var isActive: Bool {
            switch self {
            case .active(_ ,_ , _, _):
                return true
            default:
                return false
            }
        }
    }
    
    
    public func setVelocity() {
        model.angularVelocity = (gestureState as! SpinState).angularVelocity
    }
    
    
    // MARK: Calculations
    
    /// Returns the radius of  rotation
   public  func calculateRadius(proxy: GeometryProxy) -> CGFloat {
        return proxy.size.height/2 + radialOffset
    }
    
    // The Y component of the bottom handles should not affect the offset of the rotation handle
    // The Y component of the top handles are doubled to compensate.
    // All X components contribute half of their value.
    public func calculateRotationalOffset(proxy: GeometryProxy, rotationGestureState: CGFloat = 0, magnification: CGFloat = 1, dragWidths: CGFloat = 0, dragTopHeights: CGFloat = 0) -> CGSize {
        
        let angles = angle + gestureState.deltaTheta + rotationGestureState
        
        let rX = sin(angles)*(calculateRadius(proxy: proxy) - (1-magnification)*proxy.size.width/2)
        let rY = -cos(angles)*(calculateRadius(proxy: proxy) - (1-magnification)*proxy.size.height/2)
        let x =   rX + cos(angle)*dragWidths/2 - sin(angle)*dragTopHeights
        let y =   rY + cos(angle)*dragTopHeights + sin(angle)*dragWidths/2
        
        return CGSize(width: x, height: y)
    }
    
    /// Returns the change of angle from the dragging the handle
    public func calculateDeltaTheta(radius: CGFloat, translation: CGSize) -> CGFloat {
        
        let lastX = radius*sin(angle)
        let lastY = -radius*cos(angle)
        
        let newX = lastX + translation.width
        let newY = lastY + translation.height
        
        let newAngle = atan2(newY, newX) + .pi/2
        
        return (newAngle-angle)
        
    }
    
    /// Calculates the angular velocity of the rotational drag
    public func calculateDragAngularVelocity(proxy: GeometryProxy, value: DragGesture.Value) -> CGFloat {
        
        if (self.gestureState as! SpinState).time == nil {
            return 0
        }
        let radius = calculateRadius(proxy: proxy)
        let deltaA = self.calculateDeltaTheta(radius: radius, translation: value.translation)-self.gestureState.deltaTheta
        let deltaT = CGFloat((self.gestureState as! SpinState).time!.timeIntervalSince(value.time))
        let aV = -vScale*deltaA/deltaT
        
        return aV
    }
    
    // MARK: Timer
    
    var timer = Timer()
    var refreshRate: Double = 0.02
    
    
    func start() {
        self.timer = Timer.scheduledTimer(withTimeInterval: refreshRate , repeats: true) { timer in
            let aV = self.model.getAngularVelocity(angle: self.angle)
            self.angle += aV*CGFloat(self.refreshRate)
        }
    }
    
    func stop() {
        timer.invalidate()
    }
    
    func reset() {
        timer.invalidate()
        model.angularVelocity = 0
    }
    
    // MARK: Overlay
    
    public func getOverlay(proxy: GeometryProxy, rotationGestureState: CGFloat = 0, magnification: CGFloat = 1, dragWidths: CGFloat = 0, dragTopHeights: CGFloat = 0) -> AnyView {
        AnyView(ZStack {
            handle(isSelected, (gestureState as! SpinState).isActive)
        }.offset(calculateRotationalOffset(proxy: proxy, rotationGestureState: rotationGestureState, magnification: magnification, dragWidths: dragWidths, dragTopHeights: dragTopHeights))
            .gesture(
                DragGesture()
                    .onChanged({ (value) in
                        self.reset()
                        let radius = self.calculateRadius(proxy: proxy)
                        let deltaTheta = self.calculateDeltaTheta(radius: radius, translation: value.translation)
                        let angularVelocity = self.calculateDragAngularVelocity(proxy: proxy, value: value)
                        self.gestureState = SpinState.active(translation: value.translation, time: value.time, deltaTheta: deltaTheta, angularVelocity: angularVelocity)
                    })
                    .onEnded({ (value) in
                        let radius = self.calculateRadius(proxy: proxy)
                        self.angle += self.calculateDeltaTheta(radius: radius, translation: value.translation)
                        if abs( (self.gestureState as! SpinState).angularVelocity ) > self.threshold {
                            self.start()
                            self.setVelocity()
                        }
                        self.gestureState = SpinState.inactive
                    })
        ))
    }
    
    
    // MARK: Init
    
    public init(angle: Binding<CGFloat>, isSelected: Binding<Bool>, model: AngularVelocityModel = AngularVelocity(), threshold: CGFloat = 0, handle: @escaping (_ isSelected: Bool, _ isActive: Bool) -> Handle) {
        self._angle = angle
        self._isSelected = isSelected
        self.model = model
        self.handle = handle
        self.threshold = threshold
    }
    
}
