# Interact - SwiftUI Library For Dynamic Interaction

Interact is a library for easily adding dynamic interactions with any SwiftUI View. 

Have you ever wanted to move one of the views while inside the app? What about adding physics to SwiftUI? Well guess what, its all here ready for you to grab. Drag, rotate, resize, throw,  and spin to your hearts content!

**Important** - This library just underwent a major refactoring storm, I trimmed a lot of the fat while adding a ton of new features 


If you like this library then check out [PartitionKit](https://github.com/kieranb662/PartitionKit).

I am currently for hire and have a huge library of responsive components not released anywhere, hire me and you get access. If interested send an email to kb6627500@gmail.com .


 <p align="center"><img src="https://github.com/kieranb662/Interact/blob/master/InteractExample.gif" width="200"> </p>



## Requirements 

Interact as a default requires the SwiftUI Framework to be operational, as such only these platforms are supported:

* iOS 13 or Greater 
* tvOS 13 or Greater 
* watchOS 6 or Greater
* macOS 10.15 or Greater


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


**Latest Features** 

* macOS is now officially supported 
* Customize resizing and rotation handles with easy access to the i`sSelected` and `isActive` properties.
* Add in any custom physics environment for both the `spinnable` and `throwable` modifiers. 
* Specify a threshold value for both the `spinnable` and `throwable` modifiers that prevents small velocities from being registered upon gesture end. 
 


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




```Swift

struct RotatableAndSpinnableExamples: View {
    
    
    var body: some View {
    ZStack {
        Ellipse()
            .foregroundColor(.yellow)
            .frame(width: 100, height: 200)
            .overlay(Text("Rotatable"))
            .rotatable { (isSelected, isActive) in
                Circle()
                .foregroundColor(isActive ? .purple : .blue)
                .frame(width: 30, height: 30)
                .opacity(isSelected ? 1 : 0)
        }
        
        
        Rectangle()
            .foregroundColor(.blue)
            .frame(width: 150, height: 100)
            .overlay(Text("Spinnable"))
            .spinnable { (isSelected, isActive) in
                    Rectangle()
                    .foregroundColor(isActive ? .orange : .red)
                    .frame(width: 30, height: 30)
                    .opacity(isSelected ? 1 : 0)
            }
        }

    }
}


```


### Resizable 
Unlike the last few modifiers, the resizable modifier has no velocity based equavelent. Regardless resizable modifier allows for the most interactive experience. A resizable view can also be either rotatable or spinnable. 




```Swift

struct ResizableExamples: View {
    
    
    var body: some View {
        ZStack {
        
        Rectangle()
        .foregroundColor(.green)
        .overlay(Text("Resizable"))
        .resizable(initialSize: CGSize(width: 200, height: 350),
                   resizingHandle: { (isSelected, isActive) in
                        Rectangle()
                        .foregroundColor(isActive ? .orange : .blue)
                        .frame(width: 30, height: 30)
                        .opacity(isSelected ? 1 : 0)
                    })
        
        Rectangle()
        .foregroundColor(.green)
        .overlay(Text("Resizable and Spinnable"))
        .resizable(initialSize: CGSize(width: 300, height: 250),
                   resizingHandle: { (isSelected, isActive) in
                        Rectangle()
                        .foregroundColor(isActive ? .orange : .blue)
                        .frame(width: 30, height: 30)
                        .opacity(isSelected ? 1 : 0)
                 },
                   rotation: .spinnable(handle: { (isSelected, isActive) in
                        Rectangle()
                        .foregroundColor(isActive ? .purple : .yellow)
                        .frame(width: 30, height: 30)
                        .opacity(isSelected ? 1 : 0)
                   }))
        }

    }


}



```

### Important Caveats

* If using a resizable modifiers do not use `.frame` or that will mess up the geometry of the view. Instead place your frame size within the `initialSize` parameter of `resizable`. 
* Do not add a `rotatable` or `spinnable` modifier with a `resizable` modifier, instead use the `resizable` modifier with built in support for rotation and spinning. 
* If you need to add dragging or throwing functionallity add this **after** you have added the resizing modifier.

This only applies to `resizable` modifiers. 


**Available Rotation Types**

```Swift 
    public enum RotationType<Handle: View>  {
        case normal(handle: (Bool, Bool) -> Handle)
        /// Default Values `model = AngularVelocity()`, `threshold = 0` .
        /// *Threshold* is the angular velocity required to start spinning the view upon release of the drag gesture
        case spinnable(model: AngularVelocityModel = AngularVelocity(), threshold: CGFloat = 0, handle: (Bool, Bool) -> Handle)
        
    }

```


**Example of What To Do** 
    
```Swift
    struct MyCoolResizableAndDraggableView: View {
       
        var body: some View {
            Rectangle()
            .foregroundColor(.green)
            .overlay(Text("Resizable and Spinnable"))
            .resizable(initialSize: CGSize(width: 300, height: 250),
                       resizingHandle: { (isSelected, isActive) in
                            Rectangle()
                            .foregroundColor(isActive ? .orange : .blue)
                            .frame(width: 30, height: 30)
                            .opacity(isSelected ? 1 : 0)
                     },
                       rotation: .spinnable(handle: { (isSelected, isActive) in
                            Rectangle()
                            .foregroundColor(isActive ? .purple : .yellow)
                            .frame(width: 30, height: 30)
                            .opacity(isSelected ? 1 : 0)
                       }))
            .draggable()
        }
    }
    
```

**Don't Do This!!!** 

```Swift
        struct MyStupidBrokenView: View {
            
            
            var body: some View {
                Rectangle()
                .frame(width: 100, height: 200)
                .draggable
                .resizable(initialSize: CGSize(width: 300, height: 250),
                resizingHandle: { (isSelected, isActive) in
                    Rectangle()
                    .foregroundColor(isActive ? .orange : .blue)
                    .frame(width: 30, height: 30)
                    .opacity(isSelected ? 1 : 0)
            },
                rotation: .spinnable(handle: { (isSelected, isActive) in
                    Rectangle()
                    .foregroundColor(isActive ? .purple : .yellow)
                    .frame(width: 30, height: 30)
                    .opacity(isSelected ? 1 : 0)
                }))
            }
        }
        
```




## TODO 

* Add in more customizations such as limiting dragging to a single dimension or to a single path. 
* Add in more advanced physics, I have multiple models ready but just need to run more tests before they can be included.
  * gravity
  * Air resistance 
  * boundary collisions
  * Custom force fields
* Add preference keys to get the bounds of each view to take part in collisions 





