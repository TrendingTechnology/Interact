# Interact - SwiftUI Library For Dynamic Interaction

Interact is a library for easily adding dynamic interactions with any SwiftUI View. 

Have you ever wanted to move one of the views while inside the app? What about adding physics to SwiftUI? Well guess what, its all here ready for you to grab. Drag, rotate, resize, throw,  and spin to your hearts content!

I am currently for hire and have a huge library of responsive components not released anywhere, hire me and you get access. If interested send an email to kb6627500@gmail.com .

If you like this library then check out [PartitionKit](https://github.com/kieranb662/PartitionKit).

 <p align="center"><img src="https://github.com/kieranb662/Interact/blob/master/InteractExample.gif" width="200"> </p>



## Requirements 

Interact as a default requires the SwiftUI Framework to be operational, as such only these platforms are supported:

* iOS 13 or Greater 
* tvOS 13 or Greater 
* watchOS 6 or Greater 

**Important** - macOS will be supported shortly. I need to update some stuff for mac because not everything was working properly.

## Who Is Interact For? 

* Users that want control of their app layout from within the app itself.
* Developers that are making photo editing or drawing apps.
* Game Designers that want to make an awesome HUD. 
* Anyone that wants to unlock the full power of SwiftUI Gestures.


## Features

* Drag Views
* Throw Views 
* Rotate Views
* Spin Views 
* Resize Views 
* Approachable and easy to use API
* Access advanced composed gestures with a single `ViewModifier`
* Physics based velocity and angular velocity animations 
* Quickly add to an existing project with swift package manager 
 


## How To Add To Your Project

1. Snag that URL from the github repo 
2. In Xcode -> File -> Swift Packages -> Add Package Dependencies 
3. Paste the URL Into the box
4. Specify the minimum version number (This is new so 1.0.0 and greater will work).



## How To Use 


1. Pick a view that you would like to add dynamic interaction too. 
2. Pick one of 5 interactive modifiers 
3. Profit 💰💰💰



## Examples 

### Draggable And Throwable 

*Throwable* here means that the view can be dragged and thrown, not throwable like an error.

The draggable and throwable modifiers are used for moving views around the screen, with the main difference being that the throwable modifier adds velocity to the view upon release. 

You should use one or the other, **Not** both. 

**Usage Example**

```Swift look
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

**Built In Features**

* SwiftUI's `RotationGesture`
* A draggable "handle" overlay that can be moved in a circular motion to rotate the view.

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

**Built In Features**

* SwiftUI's `MagnificationGesture`
* Draggable "handles" overlayed in each corner of the view for custom resizing. 


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

This only applies to `resizable` modifiers. 

**Example of What To Do** 
    
```Swift
    struct MyCoolResizableView: View {
        @State var size: CGSize = CGSize(width: 150, height: 180)
        
        var body: some View {
            Rectangle().resizable(size: $size)
        }
    }
    
```

**Don't Do This!!!** 

```Swift
        struct MyStupidBrokenView: View {
            @State var size: CGSize = CGSize(width: 150, height: 180)
            
            var body: some View {
            Rectangle().frame(width: 100, height: 200).resizable(size: $size)
            }
        }
        
```



* Do not chain any of these modifiers together, that will result in unforseen occurences. All of the combinations of modifiers have been pre-combined already. You just need to use the one specific to your use case. The math and also state can be issues so the combinations need to be made in advanced. 


## TODO 

* Fix the issues the issues with mac, well not really fix. I just need to invert some geometry and test 
* Add in more customizations such as limiting dragging to a single dimension or to a single path. 
* Add in more advanced physics, I have multiple models ready but just need to run more tests before they can be included.
  * gravity
  * Air resistance 
  * boundary collisions
  * Custom force fields
* Add preference keys to get the bounds of each view to take part in collisions 
* Create a function to only add velocity to a view if the drag release velocity is greater than a specific threshhold . 




