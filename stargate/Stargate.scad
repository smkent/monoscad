use <Chevrons.scad>
use <Highlights.scad>
use <OuterRing.scad>
use <Symbols.scad>
use <InnerRing.scad>



Stargate(approximateRadius__inches=3);

module Stargate(approximateRadius__inches=8.5)
{
    scaleFactor = approximateRadius__inches / 8.5;
    scale([scaleFactor,scaleFactor,scaleFactor*25.4/2/10]) {
        color("darkgray", 0.8)
        scale([1,1,1])
        innerRing();

        color("mintcream", 0.8)
        scale([1,1,1.2])
        symbols();

        color("darkgray", 0.8)
        scale([1,1,1.4])
        outerRing();

        color("coral", 0.8)
        scale([1,1,1.8])
        translate([0,2,0])
        highlights();

        color("lightgray", 0.8)
        scale([1,1,1.6])
        chevrons();
    }
}
