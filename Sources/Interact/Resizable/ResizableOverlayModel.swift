//
//  ResizableOverlayModel.swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI

/// Data Model that provides all needed components for a resizable overlay
/// Uses a generic type `Handle` to create the views in each of the four corners of the overlay.
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public class ResizableOverlayModel<Handle: View>: ObservableObject {
    
    
    // MARK: State
    
    @Published var topLeadState: CGSize = .zero
    @Published var bottomLeadState: CGSize = .zero
    @Published var topTrailState: CGSize = .zero
    @Published var bottomTrailState: CGSize = .zero
    @Binding var offset: CGSize
    @Binding var size: CGSize
    @Binding var isSelected: Bool
    
    

    // MARK: Overlay
    
    var handle: (Bool, Bool) -> Handle
    
    
    func getTopLeading(proxy: GeometryProxy, angle: CGFloat = 0, magnification: CGFloat = 1) -> some View{
        
        
        let pX = proxy.frame(in: .local).minX + topLeadState.width + bottomLeadState.width
        let pY = proxy.frame(in: .local).minY + topLeadState.height + topTrailState.height
        
        let oX = -size.width*(magnification-1)/2
        let oY = -size.height*(magnification-1)/2
        
        let dragGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged({ (value) in
                self.topLeadState = value.translation
            })
            .onEnded { (value) in
                let x = cos(angle)*value.translation.width - sin(angle)*value.translation.height
                let y = cos(angle)*value.translation.height + sin(angle)*value.translation.width
                
                self.offset.width += x/2
                self.offset.height += y/2
                
                self.size.width -= value.translation.width
                self.size.height -= value.translation.height
                
                self.topLeadState = .zero
        }
        
        return ZStack {
            handle(isSelected, topLeadState != .zero)
        }
        .position(x: pX, y: pY)
        .gesture(dragGesture)
        .offset(x: oX, y: oY)
    }
    
    func getBottomLead(proxy: GeometryProxy, angle: CGFloat = 0, magnification: CGFloat = 1) -> some View {
        
        
        let pX = proxy.frame(in: .local).minX + topLeadState.width + bottomLeadState.width
        let pY = proxy.frame(in: .local).maxY + bottomTrailState.height + bottomLeadState.height
        
        let oX = -size.width*(magnification-1)/2
        let oY = size.height*(magnification-1)/2
        
        
        let dragGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged({ (value) in
                self.bottomLeadState = value.translation
            })
            .onEnded { (value) in
                let x = cos(angle)*value.translation.width - sin(angle)*value.translation.height
                let y = cos(angle)*value.translation.height + sin(angle)*value.translation.width
                
                self.offset.width += x/2
                self.offset.height += y/2
                
                self.size.width -= value.translation.width
                self.size.height += value.translation.height
                
                self.bottomLeadState = .zero
        }
        
        return ZStack {
            handle(isSelected, bottomLeadState != .zero)
        }
        .position(x: pX, y: pY)
        .gesture(dragGesture)
        .offset(x: oX, y: oY)
    }
    
    func getTopTrail(proxy: GeometryProxy, angle: CGFloat = 0, magnification: CGFloat = 1) -> some View {
        
        
        let pX = proxy.frame(in: .local).maxX + bottomTrailState.width + topTrailState.width
        let pY = proxy.frame(in: .local).minY + topLeadState.height + topTrailState.height
        
        let oX = size.width*(magnification-1)/2
        let oY = -size.height*(magnification-1)/2
        
        let dragGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged({ (value) in
                self.topTrailState = value.translation
            })
            .onEnded { (value) in
                let x = cos(angle)*value.translation.width - sin(angle)*value.translation.height
                let y = cos(angle)*value.translation.height + sin(angle)*value.translation.width
                
                self.offset.width += x/2
                self.offset.height += y/2
                
                self.size.width += value.translation.width
                self.size.height -= value.translation.height
                
                self.topTrailState = .zero
        }
        
        return ZStack {
            handle(isSelected, topTrailState != .zero )
        }
        .position(x: pX, y: pY)
        .gesture(dragGesture)
        .offset(x: oX, y: oY)
    }
    
    func getBottomTrail(proxy: GeometryProxy, angle: CGFloat = 0, magnification: CGFloat = 1) -> some View {
        
        let pX = proxy.frame(in: .local).maxX + topTrailState.width + bottomTrailState.width
        let pY = proxy.frame(in: .local).maxY + bottomLeadState.height + bottomTrailState.height
        
        let oX = size.width*(magnification-1)/2
        let oY = size.height*(magnification-1)/2
        
        let dragGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged({ (value) in
                self.bottomTrailState = value.translation
            })
            .onEnded { (value) in
                let x = cos(angle)*value.translation.width - sin(angle)*value.translation.height
                let y = cos(angle)*value.translation.height + sin(angle)*value.translation.width
                
                self.offset.width += x/2
                self.offset.height += y/2
                self.size.width += value.translation.width
                self.size.height += value.translation.height
                
                self.bottomTrailState = .zero
        }
        
        return ZStack {
            handle(isSelected, bottomTrailState != .zero)
        }
        .position(x: pX, y: pY)
        .gesture(dragGesture)
        .offset(x: oX, y: oY)
        
    }
    
    public func getOverlay(proxy: GeometryProxy, angle: CGFloat = 0, magnification: CGFloat = 1) -> some View {
        ZStack {
            self.getTopTrail(proxy: proxy, angle: angle, magnification: magnification)
            
            self.getBottomTrail(proxy: proxy, angle: angle, magnification: magnification)
            
            self.getTopLeading(proxy: proxy, angle: angle, magnification: magnification)
            
            self.getBottomLead(proxy: proxy, angle: angle, magnification: magnification)
        }
    }
    
    
    // MARK: Scaling
    
    func calculateScaleWidth(value: CGFloat) -> CGFloat {
        return (size.width + value)/size.width
    }
    
    func calculateScaleHeight(value: CGFloat) -> CGFloat {
        return (size.height + value)/size.height
    }
    
    // Applies the maginification scale effects on the view
    public func applyScales(view: AnyView, magnification: CGFloat = 1) -> some View {
        // basically to make the animations for dragging the
        // corners work properly, specific scale effects are applied
        // during the individual hold's drag gesture.
        return view
            .frame(width: size.width, height: size.height, alignment: .center)
            .scaleEffect(magnification)
            // Top Leading Drag Gesture
            .scaleEffect(CGSize(width: calculateScaleWidth(value: -topLeadState.width),
                                height: calculateScaleHeight(value: -topLeadState.height)),
                         anchor: .bottomTrailing)
            // Bottom Leading Drag Gesture
            .scaleEffect(CGSize(width: calculateScaleWidth(value: -bottomLeadState.width),
                                height: calculateScaleHeight(value: bottomLeadState.height)),
                         anchor: .topTrailing)
            // Top Trailing Drag Gesture
            .scaleEffect(CGSize(width: calculateScaleWidth(value: topTrailState.width),
                                height: calculateScaleHeight(value: -topTrailState.height)),
                         anchor: .bottomLeading)
            // Bottom Trailing Drag Gesture
            .scaleEffect(CGSize(width: calculateScaleWidth(value: bottomTrailState.width),
                                height: calculateScaleHeight(value: bottomTrailState.height)),
                         anchor: .topLeading)
    }
    
    
    
    // MARK: Init
    
    public init(initialSize: CGSize = CGSize(width: 100, height: 200), offset: Binding<CGSize>, size: Binding<CGSize>, isSelected: Binding<Bool>, handle: @escaping (Bool, Bool) -> Handle) {
        self._size = size
        self._offset = offset
        self._isSelected = isSelected
        self.handle = handle
    }
    
    
}

