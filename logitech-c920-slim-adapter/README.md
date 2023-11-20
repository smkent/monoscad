# Logitech C920 low profile articulating camera mount adapter

[![CC-BY-4.0 license][license-badge]][license]

Low profile articulating camera mount adapter base for the Logitech C920

![Model render](images/readme/demo.png)

# Description

Use this mount to attach a Logitech C920 webcam to
[Sneaks' articulating camera mount system][original-model-url]!
This mount provides an articulating link attachment and/or a ball joint
attachment, and replaces the built-in mount. Plus, the mount can be further
customized in [OpenSCAD][openscad]!

## Camera disassembly preparation

As this mount replaces the built-in mount on the Logitech C920, some disassembly
of the camera is needed to remove the built-in mount.
I read [this guide][c920-disassembly-guide] and watched
[this video][c920-disassembly-video] to disassemble my camera.

Save the metal hinge inserts to use with the new printed adapter.

![Photo of hinge inserts from original mount](images/readme/photo-c920-hinge-inserts-1.jpg)
![Photo of hinge inserts attached to printed adapter](images/readme/photo-c920-hinge-inserts-2.jpg)
![Photo of printed adapter installed on camera](images/readme/photo-c920-hinge-inserts-3.jpg)

## Printing

Several model variants are included, and you can further customize your specific
adapter using the included OpenSCAD model.

For all adapter variations, I recommend:

* Print with something other than PLA (I used PETG). The hinge housings are
  small to fit on the camera, and PLA is more brittle than other materials.
* Print at slower speeds, especially for adapters with ball mounts. I limited my
  printer to 60mm/sec for this print.

Adapters with an articulated link and no ball mount are straightforward to
print, and require no supports.

![Slicer screenshot of adapter with articulated link](images/readme/slicer-screenshot-link.png)

Adapters with a ball mount can be printed without supports, but are trickier as
the contact area with the bed is small. I had a few false starts printing these
until I cleaned my print bed. Adapters with a ball mount and no shroud are
especially tricky as the bed contact area is even smaller.

![Slicer screenshot of adapter with ball mount](images/readme/slicer-screenshot-ball.png)
![Slicer screenshot of adapter with ball mount and no shroud](images/readme/slicer-screenshot-ball-noshroud.png)

Adapters with both a ball mount and articulated link attachment are provided.
These models need supports on the articulated link to print as the ball mount
raises the rest of the model off of the print bed.

![Slicer screenshot of adapter with ball mount, no shroud, and articulated link](images/readme/slicer-screenshot-ball-noshroud-link.png)

![Photo of printed adapter with ball mount, no shroud, and articulated link](images/readme/photo-printed-ball-noshroud-link-1.jpg)
![Photo of printed adapter with ball mount, no shroud, and articulated link](images/readme/photo-printed-ball-noshroud-link-2.jpg)

## Installation

Insert the metal hinge clips from the original Logitech C920 mount into the
hinge base on your printed adapter. Then, screw it onto the camera like the
original mount and reassemble the rest of the camera.

## Remixing

For further remixing, the included OpenSCAD model can create blank mount bases.
You can also extend the code with your own parts. The included articulated mount
STL file used in the OpenSCAD model is from
[Sneaks' original model][original-model-url]. To use the OpenSCAD model, ensure
all the source files are in the same directory and then open
`logitech-c920-slim-adapter.scad` in OpenSCAD.

## Attribution and License

This is a remix of
[**Articulating Raspberry Pi Camera Mount for Prusa MK3 and MK2** by **Sneaks**][original-model-url].

Both the original model and this remix are licensed under
[Creative Commons (4.0 International License) Attribution][license].

[license-badge]: /_static/license-badge-cc-by-4.0.svg
[license]: http://creativecommons.org/licenses/by/4.0/
[openscad]: https://openscad.org
[original-model-url]: https://www.printables.com/model/3407-articulating-raspberry-pi-camera-mount-for-prusa-m
[c920-disassembly-video]: https://www.youtube.com/watch?v=a39iWgSwaBk
[c920-disassembly-guide]: https://www.ifixit.com/Guide/Logitech+C920+Webcam+Disassembly/115077
