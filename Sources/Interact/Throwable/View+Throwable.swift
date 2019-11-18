//
//  View+Throwable..swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI


@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public extension View {
    
    /// Use this modifier to be able to drag and throw a view.
    ///
    /// -   note:
    ///     If you want to resize or rotate you view as well make sure to this modifier last in the chain.  Not doing so will have unintended effects. The order draggable and throwable modifiers will always come last.
    ///
    ///
    /// - parameters:
    ///
    ///     - model: A type conforming to the `VelocityModel` protocol, the default value is `Velocity()` which provides the most basic velocity animation.
    ///     - threshold: The magnitude required to throw the view upon release of the drag gesture. **default value** = 0
    ///
    ///
    ///
    func throwable(model: VelocityModel = Velocity(), threshold: CGFloat = 0) -> some View {
        self.dependencyBuffer(initialSize: .zero) { (offset, _, _, _)  in
            ThrowableModifier(offset: offset, model: model, threshold: threshold)
        }
    }
}
