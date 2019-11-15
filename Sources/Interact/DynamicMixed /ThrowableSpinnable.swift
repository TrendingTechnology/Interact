//
//  ThrowableSpinnable.swift
//  
//
//  Created by Kieran Brown on 11/15/19.
//

import Foundation
import SwiftUI



/// # Throwable And Spinnable
/// Modifer That allows a view to be rotated and also to spin when the rotation handle is released.
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
struct ThrowableSpinnable: ViewModifier {
    
    // MARK: Spin
    @ObservedObject var angularModel: AngularVelocityModel = AngularVelocityModel()
    
    @State private var spinState: SpinState = .inactive
    @State private var rotationState: CGFloat = 0
    @State private var isSelected: Bool = false
    var radialOffset: CGFloat = 50
    var handleSize: CGSize = CGSize(width: 30, height: 30)
    let vScale: CGFloat = 0.5
    
    var rotationGesture: some Gesture {
        RotationGesture()
        .onChanged({ (value) in
            self.angularModel.stop()
            self.rotationState = CGFloat(value.radians)
        })
        .onEnded({ (value) in
            self.angularModel.angle += CGFloat(value.radians)
            self.rotationState = 0
        })
    }
    
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
        let x = calculateRadius(proxy: proxy)*sin(angularModel.angle + spinState.deltaTheta + rotationState)
        let y = -calculateRadius(proxy: proxy)*cos(angularModel.angle + spinState.deltaTheta + rotationState)
        return CGSize(width: x, height: y)
    }
    
    /// Returns the change of angle from the dragging the handle
    private func calculateDeltaTheta(proxy: GeometryProxy, translation: CGSize) -> CGFloat {
        let radius = calculateRadius(proxy: proxy)
        
        let lastX = radius*sin(self.angularModel.angle)
        let lastY = -radius*cos(self.angularModel.angle)
        
        let newX = lastX + translation.width
        let newY = lastY + translation.height
        
        let newAngle = atan2(newY, newX) + .pi/2
  
        return (newAngle-self.angularModel.angle)
        
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
                            self.angularModel.stop()
                            let deltaTheta = self.calculateDeltaTheta(proxy: proxy, translation: value.translation)
                            self.spinState = .active(translation: value.translation,
                                                     time: value.time,
                                                     deltaTheta: deltaTheta,
                                                     angularVelocity: self.calculateAngularVelocity(proxy: proxy, value: value))
                        })
                        .onEnded({ (value) in
                            self.angularModel.angle += self.calculateDeltaTheta(proxy: proxy, translation: value.translation)
                            self.angularModel.angularVelocity = self.spinState.angularVelocity
                            self.spinState = .inactive
                            self.angularModel.start()
                        })
            )
        }.opacity(isSelected ? 1 : 0)
    }
    
    // MARK: Throw
    
    /// # Velocity State
    /// Similar to the example given by apple in the composing gestures article.
    /// Additionally the drags velocity has been included.
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

    @State var dragState = VelocityState.inactive
    @ObservedObject var velocityModel: VelocityModel = VelocityModel()
    
    var shadowColor: Color
    var shadowRadius: CGFloat
    
    var throwGesture: some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .global)
            .onChanged({ (value) in
                if self.dragState.time == nil {
                    self.velocityModel.reset()
                }
                let v = self.calculateVelocity(state: self.dragState, value: value)
                self.dragState = .active(time: value.time,
                                         translation: value.translation,
                                         location: value.location,
                                         velocity: v)
                
            })
            .onEnded { (value) in
                self.velocityModel.velocity = self.dragState.velocity
                self.velocityModel.offset.width += value.translation.width
                self.velocityModel.offset.height += value.translation.height
                self.dragState = .inactive
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
    
    
    // MARK: Body
    func body(content: Content) -> some View  {
        content
            .rotationEffect(Angle(radians: Double(self.angularModel.angle + spinState.deltaTheta + rotationState)))
            .simultaneousGesture(rotationGesture)
            .simultaneousGesture(throwGesture)
            .onTapGesture {
            withAnimation(.easeIn(duration: 0.2)) {
                self.isSelected.toggle()
            }
        }
        .overlay(handleOverlay)
        .offset(x: self.dragState.translation.width + self.velocityModel.offset.width,
                y: self.dragState.translation.height + self.velocityModel.offset.height)
        .shadow(color: shadowColor, radius: dragState.isActive ? shadowRadius : 0)
        
        
    }
}
