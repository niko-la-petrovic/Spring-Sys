# Spring-Sys

A simplistic and interactive spring system simulation.

Made during June 2020 for a Physics course.

# Manual

The app window  **must be in focus.** It's necessary to use lowercase letters for input.

| Button | Functionality |
| --- | --- |
| **p** | **Pause** - toggle whether the simulation is paused. |
| **r** | **Reset** - Resets the simulation - reverts the oscillating mass to its initial position (center of screen). |
| **d** | **Damping** - toggles on/off the damping calculations (on by default). |
| **h** | **Hide** - hides parameter windows for the mass or springs. |
| **n** | **New** – creates a new spring with length equal to the current distance between the oscillating mass and the cursor, also with 0 as the spring constant and damping. Left click to set the fixed end of the newly created spring. To cancel the spring creation, press the button again. |
| **del** | **Delete** – if a spring is selected (left click) and the button is pressed, the spring will be removed from the simulation. |

# Oscillating mass

The simulation contains one  **oscillating mass** of a circular shape whose  **parameters can be changed**. Left clicking on the mass will show a window in the top left hand side of the screen for changing the parameters of the mass, as shown on figure 1.

![image](https://user-images.githubusercontent.com/23142144/124290410-b0358c80-db53-11eb-8b49-6129196e84cc.png)

_Figure 1_

The parameters **Density** and **Radius** relate to the oscillating mass' properties.  The **mass** of the oscillating mass is indirectly calculated by its **density** and **volume**.

Care should be taken when adjusting the density, as for small values ( **less than 4.0** ), the mass will be lost due to large valocities. I.e. due to division when calculating the acceleration and velocity of the mass. **Arrow keys** may be used **inside the input fields**, so small values may be avoided.

The radius of the mass is just **visually scaled 1000** times. Increasing the radius increases the volume and therefore the mass as well.

Large radius values may cause issues with selecting springs in the simulation. This is due to the way the distance of the mouse to the mass is calculated in the code, since the diameter is used rather than the radius. This approach makes it easier to select the mass with a smaller radius.

As the radius affects the mass and the visual size of the mass, it's recommended to alter the density for changing the mass.

# Springs

**The parameters of individual springs** may be seen by **left clicking** (selecting) **the fixed point** of the spring, which is displayed as a small gray circle (figure 2). All parameters are enumerated with the spring number.

![image](https://user-images.githubusercontent.com/23142144/124290511-cba09780-db53-11eb-9cae-ee2b3660e33f.png)

_Figure 2_

**Spring constant** – spring constant according to Hooke's Law:

Setting this value to 0, the spring won't affect the oscillating mass, but it will still deform.

**Resistance constant** – spring resistance constant, i.e. variable lambda from the damping equation:

This value can be set to 0.

**Length** – length of the spring. Determines the number of spring "coils." A spring has a coil every 10 pixels in length.

# Moving the mass and springs

To **change the position** of the oscillating mass, you can **press and hold the left click**  and then **move the mouse around miš**. 

Since the simulation isn't initially paused and the mass is moving, **pausing the simulation** will make it easier to select the mass.

Energy can be added to the system by moving the mass or the springs.

**Changing the position of the springs** is done similarly – **press and hold the left click** at **the fixed end of the spring**. If the simulation isn't paused,  **forced oscillations** will occur while moving the spring.

# Using external settings

The folder **data** contains two files – **settings.json** i **springs.json**

![image](https://user-images.githubusercontent.com/23142144/124291000-60a39080-db54-11eb-8fd2-a5d25ff043c2.png)

_Figure 3_

**Settings.json**

- **width** – with of the app window in pixels. Integer.
- **height** – height of the app window in pixels. Integer.
- **frameRate** – frames per second, i.e. number of simulation calculations per second. Double. Up to a certain point, doubling the frameRate can double the speed of the simulation.
- **dt** – time differential, i.e. time step made with every step of the simulation. Smaller values increase simulation accuracy, but the passage of time is slower.

![image](https://user-images.githubusercontent.com/23142144/124291026-68fbcb80-db54-11eb-9e95-c4d4eccbe07d.png)

_Figure 4_


```js
[

    {

        "x": 160,
        "y": 160,
        "k": 20.0,
        "length": 56.568542,
        "lambda": 3.0
    },
    {
        "x": 320,
        "y": 480,
        "k": 20.0,
        "length": 56.568542,
        "lambda": 3.0
    }
]
```

The **springs.json** file is for **springs settings** which exist as part of the simulation. The spring parameters of the springs can be determined in advance this way. Or, a system can be saved to this file.

**x** i **y** – x and y coordinates of the fixed end of the spring. The **coordinate origin point** is the top left corner of the simulation window. The **positive end** of the x-axis and y-axis are **down and to the right**, respectively.

The other spring parameters are covered in the springs section above.
All spring parameters must be specified for every spring.
