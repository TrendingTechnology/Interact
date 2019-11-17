//
//  VelocityModels.swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI


/// Protocol used in `ThrowableModel` to give more customizability to the forces exerted on the view after it has been thrown
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public protocol VelocityModel {
    func getVelocity(offset: CGSize) -> CGSize
    var velocity: CGSize { get set }
}


/// The simplest `VelocityModel` possible.
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public class Velocity: VelocityModel {
    public var velocity: CGSize = .zero
    public func getVelocity(offset: CGSize) -> CGSize {
        return velocity
    }
    
    
    
    public init(velocity: CGSize = .zero) {
        self.velocity = velocity
    }
}

