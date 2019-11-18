//
//  DependencyBuffer.swift
//  
//
//  Created by Kieran Brown on 11/18/19.
//

import Foundation
import SwiftUI



@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public struct GestureDependencyBuffer<Modifier: ViewModifier>: ViewModifier {
    @State var offset: CGSize = .zero
    @State var size: CGSize = CGSize(width: 100, height: 100)
    @State var angle: CGFloat = 0
    @State var isSelected: Bool = false
    
    var modifier: (Binding<CGSize>, Binding<CGSize>, Binding<CGFloat>, Binding<Bool>) -> Modifier
    
    public init(initialSize: CGSize, modifier: @escaping (Binding<CGSize>, Binding<CGSize>, Binding<CGFloat>, Binding<Bool>) -> Modifier) {
        
        self.modifier = modifier
        self.size = initialSize
        
    }
    
    public func body(content: Content) -> some View {
         content
        .modifier(modifier($offset, $size, $angle, $isSelected))
    }
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
extension View {
    func dependencyBuffer<Modifier: ViewModifier>(initialSize: CGSize, modifier: @escaping (Binding<CGSize>, Binding<CGSize>, Binding<CGFloat>, Binding<Bool>) -> Modifier) -> some View {
        self.modifier(GestureDependencyBuffer(initialSize: initialSize, modifier: modifier))
    }
}
