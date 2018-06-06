Playground and demo app from the 

## AR+SceneKit Tips and Tricks talk at Altconf 2018

The script:

Hi, my name is Erwin. I’ve been crafting iOS apps for about 9 years. I had my own apps, then consulted for a number years, worked at a giant corporation, and some startups. I’m now at a company called InspiringApps, where we Design, Develop, and Inspire.

Since I only have 10 minutes and tons of stuff to go over, I’m just going to demonstrate some points but I won’t have time to go into much explanation about how they work. But don’t worry, all that I’m going to show you today is on github.

So I guess tip zero is: don’t use the macbook pro’s keyboard. I’m using a logitech wireless solar powered one

Ok, **Tip 1:** develop in a playground ! Yeah, obviously you don’t get the AR integration, but for iterating on scene kit, you can’t beat the speed of a playground.

**Tip 2:** set the playground to use the mac platform, and set it to execute manually. Mac because then you’re not invoking the simulator, and manual so it’s not churning and trying to run with every code edit. With these two changes, you can actually get through a whole day of development without restarting Xcode. Really! I’ve done it. Now a huge caveat: mac isn’t iOS, and you won’t be able to copy-paste your work between your playground and your app by default. There are ways around that, and the demo code uses a few techniques in some places, but you will have to decide where and when to make those tradeoffs.

So here’s the playground I’m using. It’s part of the workspace for my app for easy access. You can specify the mac platform when you create a new playground, or you can change it after the fact in it’s settings here. To set it for manual execution, you have to long-click the run button down here. Tip 2a: set a keyboard shortcut to execute the playground. But be aware you can’t run the playground unless the main code document has focus, so learn that shortcut too.

Another Tip: don’t do as I’m doing for this demo, with just the demo driving code in the main document, and all the meat in the sources folder. For one, “Sources” is compiled as a separate module, so you run into access control issues you normally don’t have to deal with. But way worse: autocomplete is very limited! It’s just a pain to do it this way, 

Before I go on, I’m going to show you a few basic concepts so if you’re not familiar with scene kit, you’re not completly lost by what follows. 

If you’ve played with Xcode’s AR app templates, you know your first decision is: do you use scene kit or spritekit? 

**Tip 3:** use scene kit. Scenekit is for 3D objects, like the reality you’re going to augment, while spritekit is 2D. But even better: you can use sprite kit constructs in scene kit! You’ll see how in a little while.

```
let node = SCNNode()
sceneView.scene?.rootNode.addChildNode(node)
```
Here I’m adding a basic node to my scene, but you won’t see anything, the node will have no shape, until you give a geometry

```
let box = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.25)
node.geometry = box
```
Ok so let’s create a geometry and use it for my node. 

Scenekit includes 9 built-in geometry shapes, plus 2 where you supply text or a bezier path which is then extruded into a 3d shape. Right now I’m going to make this a box. Here it is.

Is it a box? If I move the camera you can see that yes, it’s a box with equal sides. 

**Tip 4:** configure your SCNView to allow camera access like this, this is a huge time saver. Here I’ve subclassed it to add that plus a few other helpful features.

Kinda ugly and featureless, don’t you think? That’s because I haven’t added any visual features to it yet. 

```
box.materials = [
    SCNMaterial.green,
    SCNMaterial.blue,
    SCNMaterial.yellow
]
```
You do that by assigning material objects to the geometry, like so.

**Tip 5:** create SCNMaterial extensions that return colored materials from static methods like so. This is not built in, but is in this playground on GitHub

**Tip 6:** keep the documentation handy. Things like the order of materials in the array are super important, so you need quick access to the details. I use Dash, so I can highlight a word, do a special keystroke, and go right where I need to be, and then quickly command-tab back to Xcode.

```
let ball = SCNNode(geometry: SCNSphere(radius: 1))
ball.geometry?.materials = [SCNMaterial.blue]
ball.position = SCNVector3(1, 1, 1)
sceneView.scene?.rootNode.addChildNode(ball)
```
now I’m adding a ball to the scene so you can see it’s the camera that moves in the scene, not the node. Note how the objects remain fixed relative to each other

```
let ball2 = SCNNode(geometry: SCNSphere(radius: 0.5))
ball2.geometry?.materials = [SCNMaterial.white]
ball2.position = SCNVector3(1, 2, -2)
sceneView.scene?.rootNode.addChildNode(ball2)
```
And a second ball for reference. The blue ball has a Z coordinate of plus 1, which puts it in front of the cube. If I set it to minus one, it will be behind the cube, and smaller, since it’s farther away, and now you can see the second ball

```
let container = SCNNode()
container.addChildNode(node)
container.addChildNode(ball)
sceneView.scene?.rootNode.addChildNode(container)

sceneView.debugOptions = [.showCameras, .showBoundingBoxes]

sceneView.makeRotatable(container)
```
Now I’ve grouped the cube and the first ball into a container node, and made the container rotatable independent of the scene. This allows me to inspect all sides to make sure it’s as I expect.

**Tip 7:** add ability to rotate selected nodes in the scene, super important when creating compound nodes.

Time for an AR demo! 

One use case for AR is to measure things. The demo app has a mode to measure between points in the world, using horizontal and vertical plane detection to find corners. Then it covers the wall you measured. Here it is in action.

```let currentDemo = DemoDriver.measure(mode: .one)```

To develop this, I used a playground to iterate and tweak the solution. These are the actual tests I used, an array of points to measure to from the origin. Here we see one rendered, and it shows 2 more tips.

**Tip 8:** write an SCNNode extension to show the pivot point of any node. I don’t have time to tell you how or why, it’s all in the code behind this, but trust me, rendering the pivot point can save a lot of grief. The pivot point of the image is shown here as a red sphere.

**Tip 9:** write an SCNNode extension to show the node’s axis orientation. Also super helpful to show you how your node is oriented. The X Y and Z are one unit away from the node’s center where the O (rigin) is

By the way, that image is rendered by making it the material for an SCNPlane geometry. Materials don’t have to be just colors.

**Tip 10:** use your right hand. The 3D coordinate system used by scenekit follows the right hand rule. With your right palm representing the origin, your outstretched fingers point along positive X. Bending your fingers point them along positive Y, and your thumb points to positive Z. Also, if you grip any axis with your right hand so you thumb points away from the origin, your fingers curl to describe a positive rotation amount.

```let currentDemo = DemoDriver.measure(mode: .random)```

So as I vary the endpoints, I can see that my rotation and positioning math is right. The image node’s pivot point is at the bottom left corner, and X extends towards the other side The edges are aligned and the hill is nearest the origin.

```let currentDemo = DemoDriver.measure(mode: .many)```

**Tip 11:** Take the time to set up multiple use cases and render them at once. Let’s see what that looks like here.

I mentioned pivot points earlier. They define the local origin of the node’s coordinate grid. This means translations, scaling, and rotations occur around these points. By default most nodes have their pivots at their geometric centers, so they behave as you would expect. But text nodes, not so much. 

```let currentDemo = DemoDriver.text(mode: .oneBottomLeft)```

Here we see a panel with a white text node, both showing their default pivot points. Knowing a text node’s pivot location makes it a lot easier to position properly.

```let currentDemo = DemoDriver.text(mode: .oneCentered)```

**Tip 12:** write SCNNode extensions to properly align text to other nodes

```let currentDemo = DemoDriver.text(mode: .manyCentered)```

This is another example where rendering multiple use cases at once saves a lot of time. It took quite a few iterations to get this to work in all cases, so seeing multiple variations like this is huge.

```let currentDemo = DemoDriver.text(mode: .manyBottomLeft)```

**Tip 13:** Extend your multiple-case rendering code from tip 11 to be able to quickly change variations, such as I’m doing here with this enum

You’ll notice the green header text looks a bit different than the white text, besides color and hover distance from the panel. It’s actually rendered using Spritekit. So far I’ve used solid colors and an image as materials for my node geometries. Turns out you can also use a spritekit scene as a material. The project code shows you how to render text into a an SKLabel node, add that label to an SKScene, use that scene as a material for a new SCNPlane geometry, that is then aligned with another node so the text is placed where you want it.

So there are 2 distinct ways to render text in your AR world, each with pros and cons. For example, with text as a material, you can apply it to different geometry shapes.

```let currentDemo = DemoDriver.text(mode: .sphericalTitle)```

**Tip 14:** leverage Spritekit when appropriate

So far I’ve rendered all this in code. But just like working with UIkit, you can do that or use the Xcode visual editor, called scene editor.

```let currentDemo = DemoDriver.image(mode: .one)```

**Tip 15:** absolutely use the scene editor for more complex node structures, especially when working with lighting!

Yeah, unless you’ve blueprinted you scene already, do not try to position spotlights by working in code. The tweaks will take you forever. However, scene editor doesn’t connect to your code like interface builder does via IBOutlets and IBActions. The code in this demo project shows you how to do that manually, and I wish I had time to show you now.

(Build and Run)
Let’s see this in action in the app.

Wait, who invited those guys? They seem to be just randomly milling about. But it’s cool, they’re just there to demonstrate how to use Core Animation to add some randomness to your scene. You know, just for fun.

Ok, you’l notice the text stays fixed in front of us as we move the phone around. This can’t be worked on in the playgoing, so 

**Tip 16 is:** use a real device for AR integration Ok, that’s really obvious, so let’s pretend I never said that.

**Tip 16:** use the visual debuger to see your SceneKit nodes. Yep. It works. Just have to click the scene in the hierarchy

```let currentDemo = DemoDriver.video(mode: .one)```

**Tip 17:** use the Scene editor for complex animations, called actions, but in your code, remove the actions from the nodes so you can control when they play. For example, in response to user interaction.

In Scene editor you can add one action on each node, for example the “open” action, then as you grab a reference to it in code, you can create the corresponding “close” action by reversing it.

I’ve listed 17 tips in this talk. This scene also demonstrates the one trick: the invisible box. There are 3 parts to this trick: double sided walls, and “almost” transparent outer wall, and an inner wall the is rendered “after” the outer wall.

Ok, I think my time is up. So just for fun, let’s look at that last tab in the demo app, where I took that one trick and went a little nuts with it



