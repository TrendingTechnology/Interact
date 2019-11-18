//
//  View+Rotatable.swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI


@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public extension View {
    
    /// Use this modifier to create an overlay with a handle that can be dragged in a circular motion to rotate the view.
    ///
    ///
    /// - parameters:
    ///
    ///     - handle: A view that will be used as the handle of the overlay, the `Bool` values in the closuregive access to the `isSelected` and `isActive`properties  of the modified view and handle respectively.
    ///     - isSelected: `Bool `value that is toggled on or off when the view is tapped.
    ///     - isActive: `Bool` value that is true while the individual handle view is dragging and false otherwise.
    ///
    /// - important: Tap view to select or deselect. 
    ///
    /// - note: @ViewBuilder is used here because each of the handles will be wrapping
    ///          in a container ZStack,this way its one less Grouping to write in the final
    ///          syntax.  
    ///
    ///   - **Example**:  Here an orange rotatable ellipse  is created with a handle that becomes visible upon selected and that changes from green to purple when dragged.
    ///
    ///              Ellipse()
    ///              .foregroundColor(.orange)
    ///              .frame(width: 200, height: 100)
    ///              .rotatable { (isSelected, isActive)  in
    ///                   Rectangle()
    ///                   .foregroundColor(isActive ? .purple : .green) // Changes from green to purple while the handle is dragging.
    ///                   .frame(width: 30, height: 30)
    ///                   .opacity(isSelected ? 1 : 0) // The hangle becomes visible when selected. Tap to select.
    ///             }
    ///
    func rotatable<Handle: View>(@ViewBuilder handle: @escaping (_ isSelected: Bool, _ isActive: Bool) -> Handle) -> some View  {
        self.modifier(Rotatable(handle: handle))
    }
}

