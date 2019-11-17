//
//  AngularVelocityModels.swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI


/// Protocol used to describe the angular velocity of a spinnable view
/// Only has two requirements to ensure compatability with the `SpinnableModel`
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public protocol AngularVelocityModel {
    var angularVelocity: CGFloat { get set }
    func getAngularVelocity(angle: CGFloat) -> CGFloat
}



/// The simplest `AngularVelocityModel`
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public class AngularVelocity: AngularVelocityModel {
    public var angularVelocity: CGFloat = 0
    public func getAngularVelocity(angle: CGFloat) -> CGFloat {
        return angularVelocity
    }
    
    public init() {
        
    }
    
    public init(angularVelocity: CGFloat = 0) {
        self.angularVelocity = angularVelocity
    }
}

