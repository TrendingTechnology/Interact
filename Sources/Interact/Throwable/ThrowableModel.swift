//
//  ThrowableModel.swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI


/// Data model describing the position and velocity of a view that can be dragged and released
/// The `Model` is any type conforming to the `VelocityModel` protocol. Create your own custom `VelocityModel`
/// to add in additional calculations such as gravity, air resistance or some wacky forcefield.
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public class ThrowableModel: ObservableObject {
    
    // MARK: State
    @Published var throwState = ThrowState.inactive
    @Binding var offset: CGSize
    var currentOffset: CGSize {
        CGSize(width: offset.width + throwState.translation.width,
               height: offset.height + throwState.translation.height)
    }
    var velocityModel: VelocityModel
    /// Value used to scale the velocity of the drag gesture.
    var vScale: CGFloat = 0.5
    var threshold: CGFloat = 0
    
    
    /// # Throw State
    /// Similar to the example given by apple in the composing gestures article.
    /// Additionally the drags velocity has been included so that upon ending the drag gesture the velocity can be used for animations.
    enum ThrowState {
        case inactive
        case active(time: Date,
            translation: CGSize,
            velocity: CGSize)
        
        /// `DragGesture`'s translation value
        var time: Date? {
            switch self {
            case .active(let time, _, _):
                return time
            default:
                return nil
            }
        }
        /// `DragGesture`s time value
        var translation: CGSize {
            switch self {
            case .active(_, let translation, _):
                return translation
            default:
                return .zero
            }
        }
        /// Velocity calculated from the difference in translations divided by the difference in times from the old state to the current state to the ne
        var velocity: CGSize {
            switch self {
            case .active(_, _, let velocity):
                return velocity
            default:
                return .zero
            }
        }
        /// The magnitude of the velocity vector, used in comparison with the `threshold` value, if greater then throw object  if less then dont.
        var velocityMagnitude: CGFloat {
            switch self {
            case .active(_, _, let v):
                return sqrt(v.width*v.width+v.height*v.height)
            default:
                return 0
            }
        }
        
        var isActive: Bool {
            switch self {
            case .active(_, _, _):
                return true
            default:
                return false
            }
        }
    }
    
    
    
    // MARK: Timer
    var timer = Timer()
    var refreshRate: Double = 0.005
    
    // uses the formula c = x + v*t ,
    // where d, x, v, and t are the current offset, offset, velocity, and time respectively.
    func start() {
        self.timer = Timer.scheduledTimer(withTimeInterval: refreshRate , repeats: true) { timer in
            let v = self.velocityModel.getVelocity(offset: self.offset)
            self.offset.width += v.width*CGFloat(self.refreshRate)
            self.offset.height += v.height*CGFloat(self.refreshRate)
        }
    }
    
    func stop() {
        timer.invalidate()
    }
    
    
    func reset() {
        timer.invalidate()
        velocityModel.velocity = .zero
    }
    
    func setVelocity() {
        velocityModel.velocity = throwState.velocity
    }
    
    
    
    // MARK: Calculations
    
    /// Calculates the velocity of the drag gesture.
    func calculateDragVelocity(value: DragGesture.Value) -> CGSize {
        if throwState.time == nil {
            return .zero
        } else {
            let deltaX = value.translation.width-throwState.translation.width
            let deltaY = value.translation.height-throwState.translation.height
            let deltaT = CGFloat(throwState.time!.timeIntervalSince(value.time))
            
            let vX = -vScale*deltaX/deltaT
            let vY = -vScale*deltaY/deltaT
            
            return CGSize(width: vX, height: vY)
        }
    }
    
    
    // MARK: Throw Gesture
    
    #if os(macOS)
        var throwGesture: some Gesture {
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { (value) in
                    self.reset()
                    
                    let velocity = self.calculateDragVelocity(value: value)
                    let translation = CGSize(width: value.translation.width, height: -value.translation.height)
                    self.throwState = .active(time: value.time,
                                                    translation: translation,
                                                    velocity: velocity)
            }
            .onEnded { (value) in
                
                self.offset.width += value.translation.width
                self.offset.height -= value.translation.height
                if self.throwState.velocityMagnitude > self.threshold {
                    
                    self.start()
                    self.setVelocity()
                    
                }
                self.throwState = .inactive
            }
        }
    
    #else
    var throwGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { (value) in
                self.reset()
                let velocity = self.calculateDragVelocity(value: value)
                self.throwState = .active(time: value.time,
                                                translation: value.translation,
                                                velocity: velocity)
        }
        .onEnded { (value) in
            
            self.offset.width += value.translation.width
            self.offset.height += value.translation.height
            if self.throwState.velocityMagnitude > self.threshold {
                
                self.start()
                self.setVelocity()
                
            }
            self.throwState = .inactive
        }
    }
    
    #endif
    
    
    // MARK: Init
    
    /// Default model is `Velocity`
    public init(offset: Binding<CGSize>, model: VelocityModel = Velocity(), threshold: CGFloat = 0) {
        self._offset = offset
        self.velocityModel = model
        self.threshold = threshold
    }
    
    
}
