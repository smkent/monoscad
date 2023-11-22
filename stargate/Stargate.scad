
use <Chevrons.scad>
use <Highlights.scad>
use <OuterRing.scad>
use <Symbols.scad>
use <InnerRing.scad>



Stargate(approximateRadius__inches=3);

module Stargate(approximateRadius__inches=8.5)
{
	assign(scaleFactor = approximateRadius__inches/8.5)
	scale([scaleFactor,scaleFactor,scaleFactor*25.4/2/10])
	{
		scale([1,1,1])
		{
			innerRing();
		}

		scale([1,1,1.2])
		{
			symbols();
		}

		scale([1,1,1.4])
		{
			outerRing();
		}

		scale([1,1,1.8])
		{
			translate([0,2,0])
			highlights();
		}

		scale([1,1,1.6])
		{
			chevrons();
		}
	}

}
