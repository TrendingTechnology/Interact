//
//  ThrowableRotatable.swift
//  
//
//  Created by Kieran Brown on 11/15/19.
//

import Foundation
import SwiftUI

/// # Throwable and Rotatable
/// Provides a handle above a view which can be dragged in a circular motion and rotates the view to the corresponding angle.
/// Also allows the RotationGesture to be performed on the modified view.
/// Can be drag and release to be thrown.
@available(iOS 13.0, watchOS 6.0 , tvOS 13.0, *)
public struct ThrowableRotatable: ViewModifier {
    
    @State var throwState = VelocityState.inactive
    @ObservedObject var velocityModel: VelocityModel = VelocityModel()
    @State private var isSelected: Bool = false
    let vScale: CGFloat = 0.5
    enum VelocityState {
        case inactive
        case active(time: Date,
            translation: CGSize,
            location: CGPoint,
            velocity: CGSize)
        
        var time: Date? {
            switch self {
            case .active(let time, _, _, _):
                return time
            default:
                return nil
            }
        }
        
        var translation: CGSize {
            switch self {
            case .active(_, let translation, _ , _):
                return translation
            default:
                return .zero
            }
        }
        
        var velocity: CGSize {
            switch self {
            case .active(_, _, _, let velocity):
                return velocity
            default:
                return .zero
            }
        }
        
        var location: CGPoint {
            switch self {
            case .active(_, _, let location ,_):
                return location
            default:
                return .zero
            }
        }
        
        var isActive: Bool {
            switch self {
            case .active(_, _, _ ,_):
                return true
            default:
                return false
            }
        }
    }

    
    var shadowColor: Color
    var shadowRadius: CGFloat
    
    var throwGesture: some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .global)
            .onChanged({ (value) in
                if self.throwState.time == nil {
                    self.velocityModel.reset()
                }
                let v = self.calculateVelocity(state: self.throwState, value: value)
                self.throwState = .active(time: value.time,
                                         translation: value.translation,
                                         location: value.location,
                                         velocity: v)
                
            })
            .onEnded { (value) in
                self.velocityModel.velocity = self.throwState.velocity
                self.velocityModel.offset.width += value.translation.width
                self.velocityModel.offset.height += value.translation.height
                self.throwState = .inactive
                self.velocityModel.start()
                
        }
    }
    
    init(shadowColor: Color? = .gray, radius: CGFloat? = 5) {
        self.shadowColor = shadowColor!
        self.shadowRadius = radius!
    }
    
    func calculateVelocity(state: VelocityState, value: DragGesture.Value) -> CGSize {
        if state.time == nil {
            return .zero
        }
        
        let deltaX = value.translation.width-state.translation.width
        let deltaY = value.translation.height-state.translation.height
        let deltaT = CGFloat((state.time?.timeIntervalSince(value.time) ?? 1))
        
        let vX = -vScale*deltaX/deltaT
        let vY = -vScale*deltaY/deltaT
        
        return CGSize(width: vX, height: vY)
    }
    
    
    
    
    
    
    @State var angle: CGFloat = 0
    @State var rotateState: RotateState = .inactive
    @State var rotationState: CGFloat = 0
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
        .simultaneousGesture(throwGesture)
            .rotationEffect(Angle(radians: Double(self.angle + rotateState.deltaTheta + rotationState) ))
            .simultaneousGesture(
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
        .offset(x: self.velocityModel.offset.width + throwState.translation.width,
            y: self.velocityModel.offset.height + throwState.translation.height)
    }
}
