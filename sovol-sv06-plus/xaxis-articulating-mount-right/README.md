# Articulating Camera X-Axis Right-Side Mount for Sovol SV06 (Plus)

[![Available on Printables][printables-badge]][printables-model]
[![CC-BY-4.0 license][license-badge]][license]

Articulating camera mount that press-fits into the right-side X-axis linear rod
housing on the Sovol SV06 and SV06 Plus

![Photo of printed model in use](images/readme/photo-assembled.jpg)
![Model render](images/readme/demo.png)
![Photo of printed model](images/readme/photo1.jpg)
![Photo of printed model](images/readme/photo2.jpg)
![Photo of printed model](images/readme/photo3.jpg)
![Photo of printed model](images/readme/photo4.jpg)

# Description

Mount a camera to move with your Sovol SV06 or SV06 Plus' Z-axis with this
press-fit mount! This part slides into the right side X-axis linear rod housing,
and provides an attachment base for
[Sneaks' articulating camera mount system][original-model-url].

The X-axis linear rod housing on the SV06 and SV06 Plus are different, and
models for both printers are included. Plus, models for both male and female
articulated camera mount bases are provided.

## Printing and installation

These parts print as oriented in the model files with no supports and no special
instructions. Once printed, simply slide the part into the right side X-axis
housing and attach something to the articulated camera mount!

## Remixing

For further remixing, I've also included blank and bare press-fit pieces for the
SV06 and SV06 Plus X-axis housing. I used [OpenSCAD][openscad] to glue these
parts together. That model file is included as well. With all of the source
files in the same directory, open `sv06-xaxis-mount-right.scad` in OpenSCAD.

The included SV06 and SV06 Plus tensioning mount slice STL files are reduced
copies of Sovol's original parts (also included). I did the initial slicing of
the original parts in TinkerCAD as OpenSCAD produced CGAL errors while
subtracting from the original parts.

Sovol original part links:
[SV06][original-part-link-sv06] and [SV06 Plus][original-part-link-sv06-plus]

## See also

I also have a [SV06 (Plus) X-axis left side mount!][x-axis-mount-left]

I used
[Zach's remixed articulating camera mount thumb bolt heads][zach-steel-m5-bolt-model]
with steel M5x20 bolts.

I used
[areyouferretti's articulated mount tripod bolt][areyouferretti-tripod-bolt]
to mount a Logitech C920 webcam to my articulated mount.

## Attribution and License

This is a remix of:

* [**Articulating Raspberry Pi Camera Mount for Prusa MK3 and MK2** by
  **Sneaks**][original-model-url]
* Original [Sovol SV06][sovol-sv06] and [Sovol SV06 Plus][sovol-sv06-plus] model parts

Both the original model and this remix are licensed under
[Creative Commons (4.0 International License) Attribution][license].

[areyouferretti-tripod-bolt]: https://www.printables.com/model/354264-14-inch-standard-tripod-thumb-bolt-for-articulatin
[license-badge]: /_static/license-badge-cc-by-4.0.svg
[license]: http://creativecommons.org/licenses/by/4.0/
[openscad]: https://openscad.org
[original-model-url]: https://www.printables.com/model/3407-articulating-raspberry-pi-camera-mount-for-prusa-m
[original-part-link-sv06-plus]: https://github.com/Sovol3d/SV06-PLUS/blob/master/SV06%20PLUS%203D/STL/JXHSV06P-03000%20X-axis%20component/JXHSV06P-03004-d%20X-axis%20tensioning%20mounting%20seat.STL
[original-part-link-sv06]: https://github.com/Sovol3d/SV06-Fully-Open-Source/blob/main/Molded%20Parts%20STL/JXHSV06-03004-d%20X-axis%20tensioning%20mount.STL
[printables-badge]: /_static/printables-badge.png
[printables-model]: https://www.printables.com/model/647686
[sovol-sv06-plus]: https://github.com/Sovol3d/SV06-PLUS
[sovol-sv06]: https://github.com/Sovol3d/SV06-Fully-Open-Source
[x-axis-mount-left]: /sovol-sv06-plus/xaxis-articulating-mount-left
[zach-steel-m5-bolt-model]: https://www.printables.com/model/424253-steel-thumb-bolt
