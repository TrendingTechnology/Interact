//
//  ResizableModifier.swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI



@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public struct Resizable<Handle: View>: ViewModifier {
    
    @ObservedObject var resizableModel: ResizableOverlayModel<Handle>
    
    public init(initialSize: CGSize, offset: Binding<CGSize>, size: Binding<CGSize>, isSelected: Binding<Bool>, @ViewBuilder handle: @escaping (Bool, Bool) -> Handle) {
        self.resizableModel = ResizableOverlayModel(initialSize: initialSize, offset: offset, size: size, isSelected: isSelected, handle: handle)
    }
    
    
    public func body(content: Content) -> some View  {
        resizableModel.applyScales(view: AnyView(content))
            .overlay(
                GeometryReader { proxy in
                    self.resizableModel.getOverlay(proxy: proxy)
                }
        )
            .offset(self.resizableModel.offset)
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.2)) {
                    self.resizableModel.isSelected = !self.resizableModel.isSelected
                }
        }
    }
}
