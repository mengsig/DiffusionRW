This is a repository to model 2D diffusion for large systems.

-----------------------
TO DO:
-----------------------
1. Multithread this model to reduce runtime
2. Make user friendly inputs for color, location, and amount of solution(s).
3. Implement for 3D.

-----------------------
FEATURES:
-----------------------
1. 2D diffusion with high-resolution and many particles!
2. Real-time display!
3. Ability to drop different coloured solutions.

-----------------------
How to use!
-----------------------
Please download Zig! It is a great language after all!

If you have a debian distribution, install Zig via the following command:

$ sudo snap install zig

If you do not have the snap package manager, you can install it via:

$ sudo apt-get update

$ sudo apt-get install snapd

And then of course running the command to install zig.

$ sudo snap install zig


If you have a MacOS, you can install Zig via Brew with the following command:

$ brew install zig

Otherwise, you have to do a manual installation of Zig (see https://github.com/ziglang/zig).


In order to run and build the script, please ensure you have zig installed, and run the following command in your zig environment / directory.

$ zig build run -Doptimize=ReleaseFast -Dcpu=<<your_cpu_architecture_here>> 

Note, that if you do not know your cpu architecture, you can just delete the -flag (I personally use a tigerlake).

![Model](https://github.com/mengsig/DiffusionRW/blob/main/fig1.png?raw=true)

![Model](https://github.com/mengsig/DiffusionRW/blob/main/fig2.png?raw=true)

![Model](https://github.com/mengsig/DiffusionRW/blob/main/fig3.png?raw=true)

Please enjoy, and share!

By: Marcus Engsig.
