//
//  View+Resizable.swift
//  
//
//  Created by Kieran Brown on 11/17/19.
//

import Foundation
import SwiftUI


@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public struct ResizableRotatable<ResizingHandle: View, RotationHandle: View>: ViewModifier {
    
    @ObservedObject var resizableModel: ResizableOverlayModel<ResizingHandle>
    @ObservedObject var rotationModel: RotationOverlayModel<RotationHandle>
    
    var dragWidths: CGFloat {
        return resizableModel.topLeadState.width + resizableModel.topTrailState.width + resizableModel.bottomLeadState.width + resizableModel.bottomTrailState.width
    }
    
    var dragTopHeights: CGFloat {
        return resizableModel.topLeadState.height + resizableModel.topTrailState.height
    }
    
    
    
    public func body(content: Content) -> some View  {
        resizableModel.applyScales(view: AnyView(
            content
                .frame(width: resizableModel.size.width, height: resizableModel.size.height)
        ))
            .overlay(GeometryReader { proxy in
                self.resizableModel.getOverlay(proxy: proxy, angle: self.rotationModel.angle + self.rotationModel.rotationHandleState.deltaTheta)
            })
            .rotationEffect(Angle(radians: Double(self.rotationModel.angle + self.rotationModel.rotationHandleState.deltaTheta)))
            .overlay(GeometryReader { proxy in
                self.rotationModel.getOverlay(proxy: proxy,
                                              dragWidths: self.dragWidths,
                                              dragTopHeights: self.dragTopHeights)
            })
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.2)) {
                    self.rotationModel.isSelected.toggle()
                    self.resizableModel.isSelected.toggle()
                }
        }
        .offset(self.resizableModel.offset)
    }
    
    
    public init(initialSize: CGSize, @ViewBuilder resizingHandle: @escaping (_ isSelected: Bool, _ isActive: Bool) -> ResizingHandle, @ViewBuilder rotationHandle: @escaping (_ isSelected: Bool, _ isActive: Bool) -> RotationHandle) {
        
        self.resizableModel = ResizableOverlayModel(initialSize: initialSize, handle: resizingHandle)
        self.rotationModel = RotationOverlayModel(handle: rotationHandle)
    }
    
    
}


@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public struct ResizableSpinnable<ResizingHandle: View, RotationHandle: View>: ViewModifier {
    
    @ObservedObject var resizableModel: ResizableOverlayModel<ResizingHandle>
    @ObservedObject var rotationModel: SpinnableModel<RotationHandle>
    
    var dragWidths: CGFloat {
        return resizableModel.topLeadState.width + resizableModel.topTrailState.width + resizableModel.bottomLeadState.width + resizableModel.bottomTrailState.width
    }
    
    var dragTopHeights: CGFloat {
        return resizableModel.topLeadState.height + resizableModel.topTrailState.height
    }
    
    
    public func body(content: Content) -> some View  {
        resizableModel.applyScales(view: AnyView(
            content
                .frame(width: resizableModel.size.width, height: resizableModel.size.height)
        ))
            .overlay(GeometryReader { proxy in
                self.resizableModel.getOverlay(proxy: proxy, angle: self.rotationModel.angle + self.rotationModel.spinState.deltaTheta)
            })
            .rotationEffect(Angle(radians: Double(self.rotationModel.angle + self.rotationModel.spinState.deltaTheta)))
            .overlay(GeometryReader { proxy in
                self.rotationModel.getOverlay(proxy: proxy,
                                              dragWidths: self.dragWidths,
                                              dragTopHeights: self.dragTopHeights)
            })
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.2)) {
                    self.rotationModel.isSelected.toggle()
                    self.resizableModel.isSelected.toggle()
                }
        }
        .offset(self.resizableModel.offset)
    }
    
    
    
    
    public init(initialSize: CGSize, @ViewBuilder resizingHandle: @escaping (_ isSelected: Bool, _ isActive: Bool) -> ResizingHandle,
                model: AngularVelocityModel = AngularVelocity(), threshold: CGFloat = 0 , @ViewBuilder rotationHandle: @escaping (_ isSelected: Bool, _ isActive: Bool) -> RotationHandle) {
        
        self.resizableModel = ResizableOverlayModel(initialSize: initialSize, handle: resizingHandle)
        self.rotationModel = SpinnableModel(model: model, threshold: threshold, handle: rotationHandle)
    }
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
        self.modifier(Resizable(initialSize: initialSize, handle: handle))
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
                   RotationHandle: View>(initialSize: CGSize ,
                              @ViewBuilder resizingHandle: @escaping (_ isSelected: Bool, _ isActive: Bool) -> ResizingHandle, rotation: RotationType<RotationHandle>) -> some View  {
        switch rotation {
            
        case .normal(let handle):
            return AnyView(self.modifier(ResizableRotatable(initialSize: initialSize, resizingHandle: resizingHandle, rotationHandle: handle)))
            
        case .spinnable(let model, let threshold, let handle):
            return AnyView(self.modifier(ResizableSpinnable(initialSize: initialSize, resizingHandle: resizingHandle, model: model, threshold: threshold, rotationHandle: handle)))
        }
    }
}
