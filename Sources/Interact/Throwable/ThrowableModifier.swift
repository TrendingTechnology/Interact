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
    @ObservedObject var throwModel: ThrowableModel
    
    
    init(offset: Binding<CGSize>, model: VelocityModel = Velocity(), threshold: CGFloat = 30) {
        
        self.throwModel = ThrowableModel(offset: offset, model: model, threshold: threshold)
        
    }
    
    public func body(content: Content) -> some View {
        content
            .gesture(throwModel.throwGesture)
            .offset(x: throwModel.offset.width + throwModel.throwState.translation.width,
                    y: throwModel.offset.height + throwModel.throwState.translation.height)
        
    }
}

