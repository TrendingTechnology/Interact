//
//  Spinnable.swift
//  
//
//  Created by Kieran Brown on 11/15/19.
//

import Foundation
import SwiftUI

///    # Angular Velocity Model
///
///     Used to keep track of a views angular velocity and  angle after being thrown.
///     angular velocity is reset whenever a drag gesture occurs.
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
class AngularVelocityModel: ObservableObject {
    
    @Published var angularVelocity: CGFloat = 0
    @Published var angle: CGFloat = 0
    
    var timer = Timer()
    var refreshRate: Double = 0.005
    
    // uses the formula theta = a + aV*t ,
    // where theta, a, aV, and t are the new angle, current angle, angular velocity, and time respectively.
    func start() {
        self.timer = Timer.scheduledTimer(withTimeInterval: refreshRate , repeats: true) { timer in
            self.angle += self.angularVelocity*CGFloat(self.refreshRate)
        }
    }
    
    func stop() {
        timer.invalidate()
    }
    
    func reset() {
        angularVelocity = 0
    }
}

/// # Spinnable Modifier
/// Modifer That allows a view to be rotated and also to spin when the rotation handle is released.
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
struct Spinnable: ViewModifier {
    
    @ObservedObject var angularVelocity: AngularVelocityModel = AngularVelocityModel()
    
    @State private var spinState: SpinState = .inactive
    @State private var rotationState: CGFloat = 0
    @State private var isSelected: Bool = false
    var radialOffset: CGFloat = 50
    var handleSize: CGSize = CGSize(width: 30, height: 30)
    let vScale: CGFloat = 0.5
    
    /// Modified drag state, has a deltaTheta value to use when the gesture is in progress and an angularVelocity value for on the throws end.
    enum SpinState {
        case inactive
        case active(translation: CGSize, time: Date?, deltaTheta: CGFloat, angularVelocity: CGFloat)
        
        var translation: CGSize {
            switch self {
            case .active(let translation, _, _, _):
                return translation
            default:
                return .zero
            }
        }
        
        var time: Date? {
            switch self {
            case .active(_, let time, _, _):
                return time
            default:
                return nil
            }
        }
        
        var deltaTheta: CGFloat {
            switch self {
            case .active(_, _, let angle, _):
                return angle
            default:
                return .zero
            }
        }
        
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
    
    /// Returns the radius of  rotation
    private func calculateRadius(proxy: GeometryProxy) -> CGFloat {
        return proxy.size.height/2 + radialOffset
    }
    
    /// Returns the offset of the rotation handle
    private func calculateOffset(proxy: GeometryProxy) -> CGSize {
        let x = calculateRadius(proxy: proxy)*sin(angularVelocity.angle + spinState.deltaTheta + rotationState)
        let y = -calculateRadius(proxy: proxy)*cos(angularVelocity.angle + spinState.deltaTheta + rotationState)
        return CGSize(width: x, height: y)
    }
    
    /// Returns the change of angle from the dragging the handle
    private func calculateDeltaTheta(proxy: GeometryProxy, translation: CGSize) -> CGFloat {
        let radius = calculateRadius(proxy: proxy)
        
        let lastX = radius*sin(self.angularVelocity.angle)
        let lastY = -radius*cos(self.angularVelocity.angle)
        
        let newX = lastX + translation.width
        let newY = lastY + translation.height
        
        let newAngle = atan2(newY, newX) + .pi/2
  
        return (newAngle-self.angularVelocity.angle)
        
    }
    
    private func calculateAngularVelocity(proxy: GeometryProxy, value: DragGesture.Value) -> CGFloat {
        
        if self.spinState.time == nil {
            return 0
        }
        
        let deltaA = self.calculateDeltaTheta(proxy: proxy, translation: value.translation)-self.spinState.deltaTheta
        let deltaT = CGFloat((self.spinState.time?.timeIntervalSince(value.time) ?? 1))
        let aV = -vScale*deltaA/deltaT
        
        return aV
    }
    
    private var handleOverlay: some View {
        GeometryReader { (proxy: GeometryProxy) in
            Circle()
                .frame(width: self.handleSize.width, height: self.handleSize.height)
                .offset(self.calculateOffset(proxy: proxy))
                .gesture(
                    DragGesture()
                        .onChanged({ (value) in
                            self.angularVelocity.stop()
                            let deltaTheta = self.calculateDeltaTheta(proxy: proxy, translation: value.translation)
                            self.spinState = .active(translation: value.translation,
                                                     time: value.time,
                                                     deltaTheta: deltaTheta,
                                                     angularVelocity: self.calculateAngularVelocity(proxy: proxy, value: value))
                        })
                        .onEnded({ (value) in
                            self.angularVelocity.angle += self.calculateDeltaTheta(proxy: proxy, translation: value.translation)
                            self.angularVelocity.angularVelocity = self.spinState.angularVelocity
                            self.spinState = .inactive
                            self.angularVelocity.start()
                        })
            )
        }
    }
    
    func body(content: Content) -> some View  {
        content
            .rotationEffect(Angle(radians: Double(self.angularVelocity.angle + spinState.deltaTheta + rotationState) ))
            .simultaneousGesture(
                RotationGesture()
                    .onChanged({ (value) in
                        self.angularVelocity.stop()
                        self.rotationState = CGFloat(value.radians)
                    })
                    .onEnded({ (value) in
                        self.angularVelocity.angle += CGFloat(value.radians)
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
    func spinnable() -> some View {
        self.modifier(Spinnable())
    }
    
    
    func spinnable(drag: DragType? = .none) -> some View {
        switch drag {
        case .normal:
            return AnyView(self.modifier(DraggableSpinnable()))
        case .throwable:
            return AnyView(self.modifier(ThrowableSpinnable()))
        case .none:
            return AnyView(self.modifier(Spinnable()))
        }
    }
}

