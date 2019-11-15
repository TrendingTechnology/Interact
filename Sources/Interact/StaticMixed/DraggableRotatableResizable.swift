//
//  DraggableRotatableResizable.swift
//  
//
//  Created by Kieran Brown on 11/15/19.
//

import Foundation
import SwiftUI


/// # Draggable, Rotatable and Resizable
///  Provides the ability to drag, scale, rotate, and resize the view.
///  If the view is  selected an overlay with handles in the four corners of the frame plus the rotation handle above are displayed.
///  The handles in the corners resize the view while the handle above rotates the view about its center.
///
///  - parameter viewSize, a binding to a CGSize value.
///
///  - important:
///     1. Use on views that reside in a container which does not affect layout (*ex*:  `ZStack`).
///     2. This is the final modifier to be applied to the view, applying other gestures or geometric effects will result in unforseen occurences.
///  - bug: When grabbing and dragging next neighbor corner holds, The pependicular axis gets double the input.
///
///  - ToDo: Give the ability to define custom handles for resizing and rotating.
///
@available(iOS 13.0, watchOS 6.0 , tvOS 13.0, *)
public struct DraggableRotatableResizable: ViewModifier {
    
    // MARK: Main View Dragging And Size
    @Binding var viewSize: CGSize
    @State private var viewOffset: CGSize = .zero
    @State private var dragState: CGSize = .zero
    @State private var isSelected: Bool = false
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onChanged({ (value) in
                
                self.dragState = value.translation
                
            })
            .onEnded { (value) in
                self.dragState = .zero
                
                self.viewOffset.width += value.translation.width
                self.viewOffset.height += value.translation.height
                
                
        }
    }
    
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
        
        
        var isActive: Bool {
            switch self {
            case .active(_):
                return true
            default:
                return false
            }
        }
    }
    
    
    // MARK: Resizing
    var handleSize: CGSize = CGSize(width: 40, height: 40)
    @GestureState private var topLeadState: DragState = .inactive
    @GestureState private var topTrailState: DragState = .inactive
    @GestureState private var bottomLeadState: DragState = .inactive
    @GestureState private var bottomTrailState: DragState = .inactive
    
    private var handle: some View {
        Circle()
            .frame(width: handleSize.width, height: handleSize.height)
            .foregroundColor(.blue)
            .opacity(isSelected ? 1 : 0)
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
                    self.viewOffset.width += cos(self.angle)*value.translation.width/2 - sin(self.angle)*value.translation.height/2
                    self.viewOffset.height += cos(self.angle)*value.translation.height/2 + sin(self.angle)*value.translation.width/2
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
                    self.viewOffset.width += cos(self.angle)*value.translation.width/2 - sin(self.angle)*value.translation.height/2
                    self.viewOffset.height += cos(self.angle)*value.translation.height/2 + sin(self.angle)*value.translation.width/2
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
                    self.viewOffset.width += cos(self.angle)*value.translation.width/2 - sin(self.angle)*value.translation.height/2
                    self.viewOffset.height += cos(self.angle)*value.translation.height/2 + sin(self.angle)*value.translation.width/2
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
                    self.viewOffset.width += cos(self.angle)*value.translation.width/2 - sin(self.angle)*value.translation.height/2
                    self.viewOffset.height += cos(self.angle)*value.translation.height/2 + sin(self.angle)*value.translation.width/2
                    self.viewSize.width += value.translation.width
                    self.viewSize.height += value.translation.height
            }).offset(x: viewSize.width*(magnification-1)/2,
                      y: viewSize.height*(magnification-1)/2)
        
    }
    
    // Overlay of corner handles which can resize the view when dragged
    private var resizingOverlay: some View {
        GeometryReader { (proxy: GeometryProxy) in
            self.getTopLeading(proxy: proxy)
            
            self.getBottomLead(proxy: proxy)
            
            self.getTopTrail(proxy: proxy)
            
            self.getBottomTrail(proxy: proxy)
            
        }
    }
    
    
    // MARK: Rotation
    
    // distance from the top of the view to the rotation handle
    var radialOffset: CGFloat = 50
    @State private var angle: CGFloat = 0
    @State private var rotationHandleState: RotateState = .inactive
    @State private var rotationState: CGFloat = 0
    private var rotationGesture: some Gesture {
        RotationGesture()
            .onChanged({ (value) in
                self.rotationState = CGFloat(value.radians)
            })
            .onEnded({ (value) in
                self.angle += CGFloat(value.radians)
                self.rotationState = 0
            })
    }
    
    enum RotateState {
        case inactive
        case active(translation: CGSize, deltaTheta: CGFloat)
        
        var translation: CGSize {
            switch self {
            case .active(translation: let translation, _):
                return translation
            default:
                return .zero
            }
        }
        
        var deltaTheta: CGFloat {
            switch self {
            case .active(translation: _, deltaTheta: let angle):
                return angle
            default:
                return .zero
            }
        }
    }
    
    // Calculates the radius of the circle that the rotation handle is constrained to.
    private func calculateRadius(proxy: GeometryProxy) -> CGFloat {
        return proxy.size.height/2 + radialOffset
    }
    
    // Calculates the change in angle when the rotational handle is dragged
    private func calculateDeltaTheta(proxy: GeometryProxy, translation: CGSize) -> CGFloat {
        let radius = calculateRadius(proxy: proxy)
        
        let lastX = radius*sin(self.angle)
        let lastY = -radius*cos(self.angle)
        
        let newX = lastX + translation.width
        let newY = lastY + translation.height
        let newAngle = atan2(newY, newX) + .pi/2
        
        return (newAngle-self.angle)
        
    }
    
    // The Y component of the bottom handles should not affect the offset of the rotation handle
    // The Y component of the top handles are doubled to compensate.
    // All X components contribute half of their value.
    private func calculateRotationalOffset(proxy: GeometryProxy) -> CGSize {
        
        let angles = self.angle + self.rotationHandleState.deltaTheta + self.rotationState
        let dragWidths = topLeadState.translation.width + topTrailState.translation.width + bottomLeadState.translation.width + bottomTrailState.translation.width
        let topHeights = topLeadState.translation.height + topTrailState.translation.height
        
        let rX = sin(angles)*(self.calculateRadius(proxy: proxy) - (1-magnification)*proxy.size.width/2)
        let rY = -cos(angles)*(self.calculateRadius(proxy: proxy) - (1-magnification)*proxy.size.height/2)
        let x =   rX + cos(self.angle)*dragWidths/2 - sin(self.angle)*topHeights
        let y =   rY + cos(self.angle)*topHeights + sin(self.angle)*dragWidths/2
        
        
        return CGSize(width: x, height: y)
    }
    
    // Rotation handle overlay
    private var rotationOverlay: some View {
        GeometryReader { (proxy: GeometryProxy) in
            self.handle
                .offset(self.calculateRotationalOffset(proxy: proxy))
                .gesture(
                    DragGesture()
                        .onChanged({ (value) in
                            let deltaTheta = self.calculateDeltaTheta(proxy: proxy, translation: value.translation)
                            self.rotationHandleState = .active(translation: value.translation, deltaTheta: deltaTheta)
                        })
                        .onEnded({ (value) in
                            self.angle += self.calculateDeltaTheta(proxy: proxy, translation: value.translation)
                            self.rotationHandleState = .inactive
                        })
            )
        }
    }
    
    
    // MARK: Magnification
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
    
    // Not really need just makes the body easier to read
    private func applyScales(view: AnyView) -> some View {
        // basiclly to make the animations for dragging the
        // corners work properly, specific scale effects are applied
        // during the individual holds drag gesture.
        view
            .scaleEffect(magnification)
            // Top Leading
            .scaleEffect(CGSize(width: (viewSize.width - topLeadState.translation.width)/viewSize.width,
                                height: (viewSize.height - topLeadState.translation.height)/viewSize.height),
                         anchor: .bottomTrailing)
            // Bottom Leading
            .scaleEffect(CGSize(width: (viewSize.width - bottomLeadState.translation.width)/viewSize.width,
                                height: (viewSize.height + bottomLeadState.translation.height)/viewSize.height),
                         anchor: .topTrailing)
            // Top Trailing
            .scaleEffect(CGSize(width: (viewSize.width + topTrailState.translation.width)/viewSize.width,
                                height: (viewSize.height - topTrailState.translation.height)/viewSize.height),
                         anchor: .bottomLeading)
            // Bottom Trailing
            .scaleEffect(CGSize(width: (viewSize.width + bottomTrailState.translation.width)/viewSize.width,
                                height: (viewSize.height + bottomTrailState.translation.height)/viewSize.height),
                         anchor: .topLeading)
    }
    
    
    // MARK: Body
    public func body(content: Content) -> some View {
        ZStack {
            applyScales(view: AnyView(content
                .frame(width: viewSize.width, height: viewSize.height, alignment: .center)
                .shadow(color: .gray, radius: dragState != .zero ? 5 : 0)))
                .simultaneousGesture(dragGesture)
                .simultaneousGesture(magnificationGesture)
                .overlay(resizingOverlay)
                .rotationEffect(Angle(radians: Double(self.angle + rotationHandleState.deltaTheta + rotationState)))
                .simultaneousGesture(rotationGesture)
            
        }.overlay(rotationOverlay)
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.2)) {
                    self.isSelected.toggle()
                }
        }
        .offset(x: viewOffset.width + dragState.width,
                y: viewOffset.height + dragState.height )
    }
    
}

