//
//  View+Resizable.swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI

/// Here I combined the rotation and resizable modifiers into one. I tried my best since the last version to simplify and reuse code that had been repeated again and again
/// It may not be 100% perfect but I needed to make some compromises in the end about what I was really trying to accomplish. I would love to have the ability to combine modifiers, arbitrarily throught the dot syntax but its just not so easy. I tried implementing preference keys with data for all the different types of modifiers I created, but the overall design wasn't sound. I quickly realized that It was going to be way more work and labor intensive then this project itself.
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public struct ResizableRotatable<ResizingHandle: View, RotationHandle: View, R: RotationModel>: ViewModifier {
    
    // MARK: State
    
    @ObservedObject var resizableModel: ResizableOverlayModel<ResizingHandle>
    @ObservedObject var magnificationGestureModel: MagnificationGestureModel
    @ObservedObject var rotationModel: R
    @ObservedObject var rotationGestureModel: RotationGestureModel
    @ObservedObject var dragGestureModel: DragGestureModel
    
    
    
    
    // MARK: Convienence Values
    var dragWidths: CGFloat {
        return resizableModel.topLeadState.width + resizableModel.topTrailState.width + resizableModel.bottomLeadState.width + resizableModel.bottomTrailState.width
    }
    
    var dragTopHeights: CGFloat {
        return resizableModel.topLeadState.height + resizableModel.topTrailState.height
    }
    
    var currentAngle: CGFloat {
        rotationModel.angle + rotationModel.gestureState.deltaTheta + rotationGestureModel.rotationState
    }
    
    
    
    public func body(content: Content) -> some View  {
        resizableModel.applyScales(view: AnyView(
            content
                .frame(width: resizableModel.size.width, height: resizableModel.size.height)
        ), magnification: magnificationGestureModel.magnification)
            .onTapGesture {
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.rotationModel.isSelected = !self.rotationModel.isSelected
                    }
            }
        .simultaneousGesture(dragGestureModel.dragGesture)
            .simultaneousGesture(magnificationGestureModel.magnificationGesture)
            .overlay(GeometryReader { proxy in
                self.resizableModel.getOverlay(proxy: proxy, angle: self.currentAngle, magnification: self.magnificationGestureModel.magnification)
            })
            .rotationEffect(Angle(radians: Double(currentAngle)))
            .simultaneousGesture(rotationGestureModel.rotationGesture)
            .overlay(GeometryReader { proxy in
                self.rotationModel.getOverlay(proxy: proxy,
                                              rotationGestureState: self.rotationGestureModel.rotationState,
                                              magnification: self.magnificationGestureModel.magnification,
                                              dragWidths: self.dragWidths,
                                              dragTopHeights: self.dragTopHeights)
            })
            .offset(x: self.resizableModel.offset.width + dragGestureModel.dragState.width,
                y: self.resizableModel.offset.height + dragGestureModel.dragState.height)
    }
    
    
    public init(initialSize: CGSize, offset: Binding<CGSize>, size: Binding<CGSize>, angle: Binding<CGFloat>, isSelected: Binding<Bool>, @ViewBuilder resizingHandle: @escaping (_ isSelected: Bool, _ isActive: Bool) -> ResizingHandle, rotationModel: R) {
        
        self.resizableModel = ResizableOverlayModel(initialSize: initialSize, offset: offset, size: size, isSelected: isSelected, handle: resizingHandle)
        self.magnificationGestureModel = MagnificationGestureModel(size: size)
        self.rotationModel = rotationModel
        self.rotationGestureModel = RotationGestureModel(angle: angle)
        self.dragGestureModel = DragGestureModel(offset: offset)
        
    }
    
    
}


@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public struct ResizableSpinnable<ResizingHandle: View, RotationHandle: View>: ViewModifier {
    
    @ObservedObject var resizableModel: ResizableOverlayModel<ResizingHandle>
    @ObservedObject var magnificationGestureModel: MagnificationGestureModel
    @ObservedObject var rotationModel: SpinnableModel<RotationHandle>
    @ObservedObject var rotationGestureModel: RotationGestureModel
    @ObservedObject var dragGestureModel: DragGestureModel
    
    
    public func body(content: Content) -> some View  {
        resizableModel.applyScales(view: AnyView(
            content
                .frame(width: resizableModel.size.width, height: resizableModel.size.height)
        ), magnification: magnificationGestureModel.magnification)
            .onTapGesture {
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.rotationModel.isSelected.toggle()
                    }
            }
            .simultaneousGesture(dragGestureModel.dragGesture)
            .simultaneousGesture(magnificationGestureModel.magnificationGesture)
            .overlay(GeometryReader { proxy in
                self.resizableModel.getOverlay(proxy: proxy, angle: self.currentAngle, magnification: self.magnificationGestureModel.magnification)
            })
            .rotationEffect(Angle(radians: Double(currentAngle)))
            .simultaneousGesture(rotationGestureModel.rotationGesture)
            .overlay(GeometryReader { proxy in
                self.rotationModel.getOverlay(proxy: proxy,
                                              rotationGestureState: self.rotationGestureModel.rotationState,
                                              magnification: self.magnificationGestureModel.magnification,
                                              dragWidths: self.dragWidths,
                                              dragTopHeights: self.dragTopHeights)
            })
            .offset(x: self.resizableModel.offset.width + dragGestureModel.dragState.width,
                y: self.resizableModel.offset.height + dragGestureModel.dragState.height)
    }
    
    
    // MARK: Convienence Values
    var dragWidths: CGFloat {
        return resizableModel.topLeadState.width + resizableModel.topTrailState.width + resizableModel.bottomLeadState.width + resizableModel.bottomTrailState.width
    }
    
    var dragTopHeights: CGFloat {
        return resizableModel.topLeadState.height + resizableModel.topTrailState.height
    }
    
    var currentAngle: CGFloat {
        rotationModel.angle + rotationModel.gestureState.deltaTheta + rotationGestureModel.rotationState
    }
    
    
    
    // MARK: Init
    
    public init(initialSize: CGSize, offset: Binding<CGSize>, size: Binding<CGSize>, angle: Binding<CGFloat>, isSelected: Binding<Bool>, @ViewBuilder resizingHandle: @escaping (_ isSelected: Bool, _ isActive: Bool) -> ResizingHandle,
                model: AngularVelocityModel = AngularVelocity(), threshold: CGFloat = 0 , @ViewBuilder rotationHandle: @escaping (_ isSelected: Bool, _ isActive: Bool) -> RotationHandle) {
        
        
        self.resizableModel = ResizableOverlayModel(initialSize: initialSize, offset: offset, size: size, isSelected: isSelected, handle: resizingHandle)
        self.magnificationGestureModel = MagnificationGestureModel(size: size)
        self.rotationModel = SpinnableModel(angle: angle, isSelected: isSelected, model: model, threshold: threshold, handle: rotationHandle)
        self.rotationGestureModel = RotationGestureModel(angle: angle)
        self.dragGestureModel = DragGestureModel(offset: offset)
        
    }
}


@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public protocol RotationOverlayState {
    
    var deltaTheta: CGFloat { get }
    
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public protocol RotationModel: ObservableObject {
    var angle: CGFloat { get set }
    var gestureState: RotationOverlayState { get set }
    var isSelected: Bool { get set }
    func getOverlay(proxy: GeometryProxy, rotationGestureState: CGFloat, magnification: CGFloat, dragWidths: CGFloat, dragTopHeights: CGFloat) -> AnyView
}




@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public enum RotationType<Handle: View>  {
    case normal(handle: (Bool, Bool) -> Handle)
    /// Default Values `model = AngularVelocity()`, `threshold = 0` .
    /// *Threshold* is the angular velocity required to start spinning the view upon release of the drag gesture
    case spinnable(model: AngularVelocityModel = AngularVelocity(), threshold: CGFloat = 0, handle: (Bool, Bool) -> Handle)
    
}


@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public extension View {
    /// Use this modifier to create a resizing overlay for your view, The handle parameter allows you to create a custom view to be used as the handles in each corner of the resizable view.
    /// The two `Bool`s provided in the closure give access to the isSelected and isActive properties of the modified view and handle respectively.
    ///
    /// **Example** Here a Resizable green rectangle is created whose handles all change from blue to orange when active, and become visible when selected.
    ///
    ///         Rectangle()
    ///                 .foregroundColor(.green)
    ///                 .resizable(initialSize: CGSize(width: 200, height: 350),
    ///                             resizingHandle: { (isSelected, isActive) in
    ///                                     Rectangle()
    ///                                     .foregroundColor(isActive ? .orange : .blue)
    ///                                     .frame(width: 30, height: 30)
    ///                                     .opacity(isSelected ? 1 : 0)
    ///               })
    ///
    ///
    func resizable<Handle: View>(initialSize: CGSize, @ViewBuilder handle: @escaping (_ isSelected: Bool, _ isActive: Bool) -> Handle) -> some View {
        self.dependencyBuffer(initialSize: initialSize) { (offset, size, _, isSelected)  in
            Resizable(initialSize: initialSize, offset: offset, size: size, isSelected: isSelected, handle: handle)
        }
    }
    
    
    
    /// # Resizable and Rotatable
    ///
    ///     Use this modifier for creating resizable and rotatable views. Similar to the normal
    ///     resizable modifier but with an additional parameter to specify the type of rotation
    ///     (normal or spinnable).
    ///
    ///     The two boolean values in the handle closure give access to the `isSelected`
    ///     and `isActive` values of the modified view and handle respectively.
    ///
    ///
    ///     - parameters:
    ///
    ///     - handle: A view that will be used as the handle of the overlay, the `Bool` values in the closure give access to the `isSelected` and `isActive`properties  of the modified view and handle respectively.
    ///     -  isSelected: `Bool `value that is toggled on or off when the view is tapped.
    ///     -  isActive: `Bool` value that is true while the individual handle view is dragging and false otherwise.
    ///
    ///  - note: @ViewBuilder is used here because each of the handles will be wrapping
    ///          in a container ZStack,this way its one less Grouping to write in the final
    ///          syntax.  
    ///
    ///
    /// **Example**   Here a resizable and  spinnable  rectangle is created. both the resizing and rotation handles become visible when the view is selected,
    ///             The resizing handles change from  blue to orange when dragged while the rotation handle changes from yellow to purple when dragged.
    ///
    ///         Rectangle()
    ///         .foregroundColor(.green)
    ///         .resizable(initialSize: CGSize(width: 200, height: 350),
    ///                    resizingHandle: { (isSelected, isActive) in
    ///                         Rectangle()
    ///                         .foregroundColor(isActive ? .orange : .blue)     // Color changes from blue to orange while handle is being dragged
    ///                         .frame(width: 30, height: 30)
    ///                         .opacity(isSelected ? 1 : 0)                               //  Handle view  becomes visible while the main view is selected
    ///         },
    ///           rotation: .spinnable(handle: { (isSelected, isActive) in
    ///                         Circle()
    ///                         .foregroundColor(isActive ? .purple : .yellow)
    ///                         .frame(width: 30, height: 30)
    ///                         .opacity(isSelected ? 1 : 0)
    ///           }))
    ///
    ///
    func resizable<ResizingHandle: View,
                   RotationHandle: View,
                    R: RotationModel>(initialSize: CGSize ,
                            @ViewBuilder resizingHandle: @escaping (_ isSelected: Bool, _ isActive: Bool) -> ResizingHandle,
                                         rotation: RotationType<RotationHandle>) -> some View  {
        switch rotation {
            
        case .normal(let handle):
            return AnyView(
                self.dependencyBuffer(initialSize: initialSize, modifier: { (offset, size, angle, isSelected)  in
                    ResizableRotatable<ResizingHandle, RotationHandle, RotationOverlayModel>(initialSize: initialSize, offset: offset, size: size, angle: angle, isSelected: isSelected, resizingHandle: resizingHandle,
                        rotationModel: RotationOverlayModel(angle: angle, isSelected: isSelected, handle: handle))
                })
                )
            
        case .spinnable(let model, let threshold, let handle):
            return AnyView(
                self.dependencyBuffer(initialSize: initialSize, modifier: { (offset, size, angle, isSelected)  in
                    ResizableRotatable<ResizingHandle, RotationHandle, SpinnableModel>(initialSize: initialSize, offset: offset, size: size, angle: angle, isSelected: isSelected, resizingHandle: resizingHandle,
                                       rotationModel: SpinnableModel<RotationHandle>(angle: angle, isSelected: isSelected, model: model, threshold: threshold, handle: handle))
                })
            )
        }
    }
}
