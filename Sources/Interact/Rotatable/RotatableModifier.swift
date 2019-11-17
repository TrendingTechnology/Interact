//
//  RotatableModifier.swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI


@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public struct Rotatable<Handle: View>: ViewModifier {
    @ObservedObject var rotationModel: RotationOverlayModel<Handle>

    
    /// The first boolean gives access to the isSelected property of the rotationModel, while the second boolean represents the drag state of the rotation overlay handle .
    public init(@ViewBuilder handle: @escaping (_ isSelected: Bool, _ isActive: Bool) -> Handle) {
        self.rotationModel = RotationOverlayModel(handle: handle)
    }
    
    
    public func body(content: Content) -> some View  {
        content
            .rotationEffect(Angle(radians: Double(rotationModel.angle + rotationModel.rotationHandleState.deltaTheta)))
            .overlay(
                GeometryReader { proxy in
                    self.rotationModel.getOverlay(proxy: proxy)
                }
        )
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.2)) {
                    self.rotationModel.isSelected = !self.rotationModel.isSelected
                }
        }
    }
}
