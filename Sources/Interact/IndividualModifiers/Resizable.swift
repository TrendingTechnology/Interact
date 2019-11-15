//
//  Resizable.swift
//  
//
//  Created by Kieran Brown on 11/15/19.
//

import Foundation
import SwiftUI

/// # Resizable View
///
/// Provides the ability to resize the view with either a magnification gesture or using the corner handles overlay
/// - requires: A  Bindable CGSize, Also dont use the `.frame` modifier just put the size of the view in the binding.
@available(iOS 13.0, watchOS 6.0 , tvOS 13.0, *)
public struct Resizable: ViewModifier {
    
    @State private var viewOffset: CGSize = .zero
    @Binding var viewSize: CGSize
    @State private var isSelected: Bool = false
    
    @State private var magnification: CGFloat = 1
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
        .onChanged({ (value) in
            self.magnification = value
        })
        .onEnded({ (value) in
            self.magnification = 1
            self.viewSize.width *= value
            self.viewSize.height *= value
            
        })
    }
    
    var handleSize: CGSize = CGSize(width: 30, height: 30)
    @GestureState private var topLeadState: DragState = .inactive
    @GestureState private var topTrailState: DragState = .inactive
    @GestureState private var bottomLeadState: DragState = .inactive
    @GestureState private var bottomTrailState: DragState = .inactive
    
    enum DragState {
        case inactive
        case active(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .active(translation: let translation):
                return translation
            default:
                return .zero
            }
        }
    }
    
    private var handle: some View {
        Circle()
            .frame(width: handleSize.width, height: handleSize.height)
            .foregroundColor(.blue)
    }
    
    private func getTopLeading(proxy: GeometryProxy) -> some View{
        self.handle
            .position(x: proxy.frame(in: .local).minX + self.topLeadState.translation.width + bottomLeadState.translation.width,
                      y: proxy.frame(in: .local).minY + self.topLeadState.translation.height + topTrailState.translation.height)
            .gesture(
                DragGesture()
                    .updating(self.$topLeadState) { (value, state, _) in
                        state = .active(translation: value.translation)
                }
                .onEnded { (value) in
                    self.viewOffset.width += value.translation.width/2
                    self.viewOffset.height += value.translation.height/2
                    self.viewSize.width -= value.translation.width
                    self.viewSize.height -= value.translation.height
            }).offset(x: -viewSize.width*(magnification-1)/2,
                      y: -viewSize.height*(magnification-1)/2)
    }
    
    private func getBottomLead(proxy: GeometryProxy) -> some View {
        self.handle
            .position(x: proxy.frame(in: .local).minX + self.topLeadState.translation.width + self.bottomLeadState.translation.width,
                      y: proxy.frame(in: .local).maxY + self.bottomTrailState.translation.height + self.bottomLeadState.translation.height )
            .gesture(
                DragGesture()
                    .updating(self.$bottomLeadState) { (value, state, _) in
                        state = .active(translation: value.translation)
                }
                .onEnded { (value) in
                    self.viewOffset.width += value.translation.width/2
                    self.viewOffset.height += value.translation.height/2
                    self.viewSize.width -= value.translation.width
                    self.viewSize.height += value.translation.height
            }).offset(x: -viewSize.width*(magnification-1)/2,
                      y: viewSize.height*(magnification-1)/2)
    }
    
    private func getTopTrail(proxy: GeometryProxy) -> some View {
        self.handle
            .position(x: proxy.frame(in: .local).maxX + self.bottomTrailState.translation.width + self.topTrailState.translation.width,
                      y: proxy.frame(in: .local).minY + self.topLeadState.translation.height + topTrailState.translation.height)
            .gesture(
                DragGesture()
                    .updating(self.$topTrailState) { (value, state, _) in
                        state = .active(translation: value.translation)
                }
                .onEnded { (value) in
                    self.viewOffset.width += value.translation.width/2
                    self.viewOffset.height += value.translation.height/2
                    self.viewSize.width += value.translation.width
                    self.viewSize.height -= value.translation.height
            }).offset(x: viewSize.width*(magnification-1)/2,
                      y: -viewSize.height*(magnification-1)/2)
    }
    
    private func getBottomTrail(proxy: GeometryProxy) -> some View {
        self.handle
            .position(x: proxy.frame(in: .local).maxX + topTrailState.translation.width + bottomTrailState.translation.width ,
                      y: proxy.frame(in: .local).maxY + bottomLeadState.translation.height + bottomTrailState.translation.height )
            .gesture(
                DragGesture()
                    .updating(self.$bottomTrailState) { (value, state, _) in
                        state = .active(translation: value.translation)
                }
                .onEnded { (value) in
                    self.viewOffset.width += value.translation.width/2
                    self.viewOffset.height += value.translation.height/2
                    self.viewSize.width += value.translation.width
                    self.viewSize.height += value.translation.height
            }).offset(x: viewSize.width*(magnification-1)/2,
                      y: viewSize.height*(magnification-1)/2)
        
    }
    
    private var handleOverlay: some View {
        GeometryReader { (proxy: GeometryProxy) in
            self.getTopLeading(proxy: proxy)
            
            self.getBottomLead(proxy: proxy)
            
            self.getTopTrail(proxy: proxy)
            
            self.getBottomTrail(proxy: proxy)
        }.opacity(isSelected ? 1 : 0)
    }
    
    // Convienence so that the body function doesnt look absolutely disgusting .
    private func applyScales(_ view: AnyView) -> some View {
        view
        // Magnification Gesture
        .scaleEffect(magnification)
        // Top Leading Drag Gesture
        .scaleEffect(CGSize(width: (viewSize.width - topLeadState.translation.width)/viewSize.width,
                            height: (viewSize.height - topLeadState.translation.height)/viewSize.height),
                     anchor: .bottomTrailing)
        // Bottom Leading Drag Gesture
        .scaleEffect(CGSize(width: (viewSize.width - bottomLeadState.translation.width)/viewSize.width,
                            height: (viewSize.height + bottomLeadState.translation.height)/viewSize.height),
                     anchor: .topTrailing)
        // Top Trailing Drag Gesture
        .scaleEffect(CGSize(width: (viewSize.width + topTrailState.translation.width)/viewSize.width,
                            height: (viewSize.height - topTrailState.translation.height)/viewSize.height),
                     anchor: .bottomLeading)
        // Bottom Trailing Drag Gesture
        .scaleEffect(CGSize(width: (viewSize.width + bottomTrailState.translation.width)/viewSize.width,
                            height: (viewSize.height + bottomTrailState.translation.height)/viewSize.height),
                     anchor: .topLeading)
    }
    
    public func body(content: Content) -> some View {
        applyScales(
            AnyView(content.frame(width: viewSize.width, height: viewSize.height, alignment: .center)))
            .simultaneousGesture(magnificationGesture)
            .overlay(handleOverlay)
            .offset(x: viewOffset.width,
                    y: viewOffset.height )
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.2)) { ()  in
                    self.isSelected.toggle()
                }
        }
    }
}

@available(iOS 13.0, watchOS 6.0 , tvOS 13.0, *)
public extension View {
    func resizable(size: Binding<CGSize>) -> some View  {
        self.modifier(Resizable(viewSize: size))
    }
    
    
    func resizable(size: Binding<CGSize>, drag: DragType? = .none , rotate: RotationType? = .none) -> some View {
        switch (drag, rotate) {
        case (.normal, .normal):
            return AnyView(self.modifier(DraggableRotatableResizable(viewSize: size)))
        case (.normal, .spinnable):
            return AnyView(self.modifier(DraggableSpinnableResizable(viewSize: size)))
        case (.normal, .none):
            return AnyView(self.modifier(DraggableResizable(viewSize: size)))
        case (.throwable, .normal):
            return AnyView(self.modifier(ThrowableRotatableResizable(viewSize: size)))
        case (.throwable, .spinnable):
            return AnyView(self.modifier(ThrowableSpinnableResizable(viewSize: size)))
        case (.throwable, .none):
            return AnyView(self.modifier(ThrowableResizable(viewSize: size)))
        case (.none, .normal):
            return AnyView(self.modifier(RotatableResizable(viewSize: size)))
        case (.none, .spinnable):
            return AnyView(self.modifier(SpinnableResizable(viewSize: size)))
        case (.none, .none):
            return AnyView(self.modifier(Resizable(viewSize: size)))
        }
  
    }
}

