//
//  SpinnableModifier.swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI

@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public struct Spinnable<Handle: View>: ViewModifier {
    @ObservedObject var spinModel: SpinnableModel<Handle>
    @ObservedObject var rotationGestureModel: RotationGestureModel
    
    public init(angle: Binding<CGFloat>, isSelected: Binding<Bool>, model: AngularVelocityModel = AngularVelocity(), threshold: CGFloat = 0, @ViewBuilder handle: @escaping (Bool, Bool) -> Handle) {
        self.spinModel = SpinnableModel(angle: angle, isSelected: isSelected, model: model, threshold: threshold, handle: handle)
        self.rotationGestureModel = RotationGestureModel(angle: angle)
        
    }
    
    var currentAngle: CGFloat {
        spinModel.angle + spinModel.gestureState.deltaTheta + rotationGestureModel.rotationState
    }
    
    public func body(content: Content) -> some View  {
        content
            .rotationEffect(Angle(radians: Double(currentAngle)))
            .gesture(rotationGestureModel.rotationGesture)
            .overlay(
                GeometryReader { proxy in
                    ZStack {
                        self.spinModel.getOverlay(proxy: proxy)
                    }
            })
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.2)) {
                    self.spinModel.isSelected.toggle()
                }
        }
    }
}
