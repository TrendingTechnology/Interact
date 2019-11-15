//
//  ThrowableResizable.swift
//  
//
//  Created by Kieran Brown on 11/15/19.
//

import Foundation
import SwiftUI


/// # Throwable And Resizable
///
/// Provides the ability to resize the view with either a magnification gesture or using the corner handles overlay.
///  Also drag and release to throw the view to the great beyond.
///
///
/// - requires: A  Bindable CGSize, Also dont use the `.frame` modifier just put the size of the view in the binding.
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
struct ThrowableResizable: ViewModifier {
    
    @Binding var viewSize: CGSize
    @State var throwState = VelocityState.inactive
    @ObservedObject var velocityModel: VelocityModel = VelocityModel()
    @State private var isSelected: Bool = false
    let vScale: CGFloat = 0.5
    
    enum VelocityState {
        case inactive
        case active(time: Date,
            translation: CGSize,
            location: CGPoint,
            velocity: CGSize)
        
        var time: Date? {
            switch self {
            case .active(let time, _, _, _):
                return time
            default:
                return nil
            }
        }
        
        var translation: CGSize {
            switch self {
            case .active(_, let translation, _ , _):
                return translation
            default:
                return .zero
            }
        }
        
        var velocity: CGSize {
            switch self {
            case .active(_, _, _, let velocity):
                return velocity
            default:
                return .zero
            }
        }
        
        var location: CGPoint {
            switch self {
            case .active(_, _, let location ,_):
                return location
            default:
                return .zero
            }
        }
        
        var isActive: Bool {
            switch self {
            case .active(_, _, _ ,_):
                return true
            default:
                return false
            }
        }
    }

    
    var shadowColor: Color
    var shadowRadius: CGFloat
    
    var throwGesture: some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .global)
            .onChanged({ (value) in
                if self.throwState.time == nil {
                    self.velocityModel.reset()
                }
                let v = self.calculateVelocity(state: self.throwState, value: value)
                self.throwState = .active(time: value.time,
                                         translation: value.translation,
                                         location: value.location,
                                         velocity: v)
                
            })
            .onEnded { (value) in
                self.velocityModel.velocity = self.throwState.velocity
                self.velocityModel.offset.width += value.translation.width
                self.velocityModel.offset.height += value.translation.height
                self.throwState = .inactive
                self.velocityModel.start()
                
        }
    }
    
    init(viewSize: Binding<CGSize> ,shadowColor: Color? = .gray, radius: CGFloat? = 5) {
        self._viewSize = viewSize
        self.shadowColor = shadowColor!
        self.shadowRadius = radius!
    }
    
    func calculateVelocity(state: VelocityState, value: DragGesture.Value) -> CGSize {
        if state.time == nil {
            return .zero
        }
        
        let deltaX = value.translation.width-state.translation.width
        let deltaY = value.translation.height-state.translation.height
        let deltaT = CGFloat((state.time?.timeIntervalSince(value.time) ?? 1))
        
        let vX = -vScale*deltaX/deltaT
        let vY = -vScale*deltaY/deltaT
        
        return CGSize(width: vX, height: vY)
    }
    
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
                    self.velocityModel.offset.width += value.translation.width/2
                    self.velocityModel.offset.height += value.translation.height/2
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
                    self.velocityModel.offset.width += value.translation.width/2
                    self.velocityModel.offset.height += value.translation.height/2
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
                    self.velocityModel.offset.width += value.translation.width/2
                    self.velocityModel.offset.height += value.translation.height/2
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
                    self.velocityModel.offset.width += value.translation.width/2
                    self.velocityModel.offset.height += value.translation.height/2
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
    
    func body(content: Content) -> some View {
        applyScales(
            AnyView(content
                .frame(width: viewSize.width, height: viewSize.height, alignment: .center)
                .shadow(color: shadowColor, radius: throwState.isActive ? shadowRadius : 0)
        ))
            .simultaneousGesture(magnificationGesture)
        .simultaneousGesture(throwGesture)
            .overlay(handleOverlay)
            .offset(x: velocityModel.offset.width + throwState.translation.width,
                    y: velocityModel.offset.height + throwState.translation.height )
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.2)) { ()  in
                    self.isSelected.toggle()
                }
        }
    }
}

