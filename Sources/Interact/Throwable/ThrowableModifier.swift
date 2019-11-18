//
//  ThrowableModifier.swift
//  Interact
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI




@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
    public struct ThrowableModifier: ViewModifier {
        @ObservedObject var model: ThrowableModel = ThrowableModel()
        let threshold: CGFloat
        
        #if os(macOS)
        var throwGesture: some Gesture {
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { (value) in
                    self.model.reset()
                    
                    let velocity = self.model.calculateDragVelocity(value: value)
//                    velocity = CGSize(width: velocity.width, height: -velocity.height)
                    let translation = CGSize(width: value.translation.width, height: -value.translation.height)
                    self.model.throwState = .active(time: value.time,
                                                    translation: translation,
                                                    velocity: velocity)
            }
            .onEnded { (value) in
                
                self.model.offset.width += value.translation.width
                self.model.offset.height -= value.translation.height
                if self.model.throwState.velocityMagnitude > self.threshold {
                    
                    self.model.start()
                    self.model.setVelocity()
                    
                }
                self.model.throwState = .inactive
            }
        }
    
    #else
    var throwGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { (value) in
                self.model.reset()
                let velocity = self.model.calculateDragVelocity(value: value)
                self.model.throwState = .active(time: value.time,
                                                translation: value.translation,
                                                velocity: velocity)
        }
        .onEnded { (value) in
            
            self.model.offset.width += value.translation.width
            self.model.offset.height += value.translation.height
            if self.model.throwState.velocityMagnitude > self.threshold {
                
                self.model.start()
                self.model.setVelocity()
                
            }
            self.model.throwState = .inactive
        }
    }
    
    #endif
        
        
        init(model: VelocityModel = Velocity(), threshold: CGFloat = 30) {
            self.threshold = threshold
            self.model = ThrowableModel(model: model)
        }
        
        public func body(content: Content) -> some View {
            content
                .gesture(throwGesture)
                .offset(x: model.offset.width + model.throwState.translation.width,
                        y: model.offset.height + model.throwState.translation.height)
            
        }
    }

