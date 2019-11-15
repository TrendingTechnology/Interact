//
//  Throwable.swift
//  
//
//  Created by Kieran Brown on 11/15/19.
//

import Foundation
import SwiftUI


///    # Velocity Model
///
///     Used to keep track of a views velocity and displacement after being thrown.
///     Velocity is reset whenever a drag gesture occurs.
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
class VelocityModel: ObservableObject {
    
    @Published var velocity: CGSize = .zero
    @Published var offset: CGSize = .zero
    
    var timer = Timer()
    var refreshRate: Double = 0.005
    
    
    // uses the formula c = x + v*t ,
    // where d, x, v, and t are the current offset, offset, velocity, and time respectively.
    func start() {
        self.timer = Timer.scheduledTimer(withTimeInterval: refreshRate , repeats: true) { timer in
            self.offset.width += self.velocity.width*CGFloat(self.refreshRate)
            self.offset.height += self.velocity.height*CGFloat(self.refreshRate)
        }
    }
    
    func stop() {
        timer.invalidate()
    }
    
    
    func reset() {
        velocity = .zero
    }
}


/// # Throwable
/// Drag and throw any view with this modifier, careful though because it may get lost in the endless expanse.
/// Optionally the shadow color and radius can be set, these are for adding a shadow effect while the view is mid drag.
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
struct ThrowableModifier: ViewModifier {
    
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
    var vScale: CGFloat = 0.5
    
    var shadowColor: Color
    var shadowRadius: CGFloat
    
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
    
    
    func body(content: Content) -> some View {
        content
            .offset(x: self.dragState.translation.width + self.velocityModel.offset.width,
                    y: self.dragState.translation.height + self.velocityModel.offset.height)
            .gesture(DragGesture()
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
                    
            }).shadow(color: shadowColor, radius: dragState.isActive ? shadowRadius : 0)
    }
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
extension View {
    func throwable() -> some View {
        self.modifier(ThrowableModifier())
    }
    
    
    
    func throwable(shadowColor: Color? , radius: CGFloat? ) -> some View {
        self.modifier(ThrowableModifier(shadowColor: shadowColor, radius: radius))
    }
}


