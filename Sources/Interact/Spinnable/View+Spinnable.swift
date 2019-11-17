//
//  File.swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI


@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public extension View {
    
    
    /// Use this modifier to provide an overlay handle for rotating and spinning a view.
    /// - parameters:
    ///
    ///     - model : A type conforming to the `AngularVelocityModel` protocol, **Default Value**: `AngularVelocity()`
    ///     - threshold: The angular velocity required to spin the view upon release of the gesture. **Default Value**: 0
    ///     - handle: The view to be overlayed and dragged to perform the rotation and spin. The `Bool` values in the closure are isSelected and isActive respectively.
    ///
    /// **Example** - Here a spinnable yellow rectangle  is created with a handle that becomes visible upon becoming selected and changes color from green to purple while dragging.
    ///
    ///        Rectangle()
    ///         .foregroundColor(.yellow)
    ///         .frame(width: 200, height: 150)
    ///         .spinnable(handle: { (isSelected, isActive) in
    ///                     Circle()
    ///                     .foregroundColor(isActive ? .purple : .green)
    ///                     .frame(width: 30, height: 30)
    ///                     .opacity(isSelected ? 1 : 0)
    ///                   })
    ///
    ///
    func spinnable<Handle: View>(model: AngularVelocityModel = AngularVelocity(), threshold: CGFloat = 0, @ViewBuilder handle: @escaping (Bool, Bool) -> Handle) -> some View {
        self.modifier(Spinnable(model: model, threshold: threshold, handle: handle))
    }
}
