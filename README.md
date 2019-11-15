# Interact

![Interact Example](InteractExample.gif)

Interact is a library for easily adding dynamic interactions with any SwiftUI View. Have you ever wanted to just move one of you views while inside the app? What about adding physics to SwiftUI? Well guess what, its all here ready for you to grab. 

Drag, rotate, resize, throw,  and spin to your hearts content!



## Requirements 

Interact as a default requires the SwiftUI Framework to be operational, as such only these platforms are supported:

* iOS 13 or Greater 
* tvOS 13 or Greater 
* watchOS 6 or Greater 

**Important** - macOS will be supported shortly. I need to update some stuff for mac because not everything was working properly.


## How To Add To Your Project

1. Snag that URL from the github repo 
2. In Xcode -> File -> Swift Packages -> Add Package Dependencies 
3. Paste the URL Into the box
4. Specify the minimum version number (This is new so 1.0.0 and greater will work).



## How To Use 


1. Pick a view that you would like to add dynamic interaction too. 
2. Pick one of 5 interactive modifiers 
3. Profit!!!



## Examples 

### Draggable And Throwable 

The draggable and throwable modifiers are used for moving views around the screen, with the main difference being that the throwable modifier adds velocity to the view upon release. 

You should use one or the other, **Not** both. 

**Usage Example**

```Swift
struct DraggableAndThrowableExamples: View {
    
    
    var body: some View {
    ZStack {
        Rectangle()
        .frame(width: 100, height: 200)
        .overlay(Text("Draggable"))
        .draggable()
        
        Ellipse()
        .frame(width: 200, height: 100)
        .overlay(Text("Throwable"))
        .throwable()
        }

    }
}


```

### Rotatable And Spinnable

Just like before with the draggable and throwable modifiers, the rotatable stops when release while the spinnable keeps rotating with the angular velocity of the release. 

SwiftUI's `RotationGesture` is built into these as well as an overlay handle that can be dragged in a circular motion.

These two modifiers can be initiallized with a drag or throw gesture. For Example 

```Swift

struct RotatableAndSpinnableExamples: View {
    
    
    var body: some View {
    ZStack {
        Rectangle()
        .frame(width: 100, height: 200)
        .overlay(Text("Rotatable"))
        .rotatable()
        
        Ellipse()
        .frame(width: 100, height: 200)
        .overlay(Text("Spinnable"))
        .spinnable()
        
        
        Rectangle()
        .frame(width: 200, height: 100)
        .overlay(Text("Rotatable And Draggable"))
        .rotatable(drag: .normal)
        
        Ellipse()
        .frame(width: 200, height: 100)
        .overlay(Text("Spinnable and Throwable"))
        .spinnable(drag: .throwable)
        }

    }
}


```

The possible drag types are housed in an enum `DragType` and the rotation types are housed in `RotationType`. 

```Swift
    enum DragType {
        case normal
        case throwable
    }


    enum RotationType {
        case normal
        case spinnable
    }
```

### Resizable 
Unlike the last few modifiers, the resizable modifier has no velocity based equavelent. Regardless resizable modifier allows for the most interactive experience. A resizable view can also be either draggable or throwable, and it can also be rotatable or spinnable. Since their are alot of combinations I will only  show a few here.



```Swift
struct ResizableExamples: View {
    @State var exampleSize1: CGSize = CGSize(width: 100, height: 200)
    @State var exampleSize2: CGSize = CGSize(width: 300, height: 250)
    @State var exampleSize3: CGSize = CGSize(width: 200, height: 120)
    @State var exampleSize4: CGSize = CGSize(width: 100, height: 250)
    
    var body: some View {
        ZStack {
        
        Rectangle()
        .overlay(Text("Resizable"))
        .resizable(size: $exampleSize1)
        
        Ellipse()
        .overlay(Text("Resizable And Draggable"))
        .resizable(size: $exampleSize2, drag: .normal)
        
        
        Rectangle()
        .overlay(Text("Resizable And Spinnable"))
        .resizable(size: $exampleSize3, rotate: .spinnable)
        
        Ellipse()
        .overlay(Text("Resizable, Throwable And Spinnable"))
        .resizable(size: $exampleSize3, drag: .throwable, rotate: .spinnable)
        }

    }


}



```

### Important Caveats

* If using a resizable modifiers do not use `.frame` or that will mess up the geometry of the view. Instead place your frame size in a `Bindable<CGSize>` and use that value for the input of the `resizable` modifier 
    **Example of What To Do** 
    
```Swift
    struct MyCoolResizableView: View {
        @State var viewSize: CGSize = CGSize(width: 150, height: 180)
        
        var body: some View {
            Rectangle().resizable(size: $viewSize)
        }
    }
    
```

**Don't Do This!!!** 
```Swift
        struct MyStupidBrokenView: View {
            @State var viewSize: CGSize = CGSize(width: 150, height: 180)
            
            var body: some View {
            Rectangle().frame(width: 100, height: 200).resizable(size: $viewSize)
            }
        }
        
```

This only applies to `resizable` modifiers. 

* Do not chain any of these modifiers together, that will result in unforseen occurences. All of the combinations of modifiers have been pre-combined already. You just need to use the one specific to your use case. The math and also state can be issues so the combinations need to be made in advanced. 



