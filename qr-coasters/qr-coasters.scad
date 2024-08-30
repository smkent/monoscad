/*
 * qr-coasters
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Part = "coaster"; // [coaster: Coaster, holder: Holder]
Top_Color = "steelblue"; // [mintcream, lightsteelblue, steelblue, darkseagreen, black]
Bottom_Color = "mintcream"; // [mintcream, lightsteelblue, steelblue, darkseagreen, black]
Preview_Coasters_in_Holder = false;

/* [Model Options] */
QR_Code = "rick-roll"; // [doge: Doge, bouncing-dvd-logo: DVD Logo, nyan-cat: Nyan Cat, one-square-minesweeper: One Square Minesweeper, potato-tomato: Potato or Tomato, rick-roll: Rick Roll, rotating-sandwiches: Rotating Sandwiches, zombo: Zombo.com]
Style = "raised"; // [raised: Raised, inset: Inset]

/* [Coaster Size] */
Size = 101.6; // [88.9: 3.5 inch, 101.6: 4 inch]
Base_Height = 5;
QR_Height = 1;
Raised_Border_Size = 3;
Edge_Radius = 1; // [0:0.1:5]

/* [Holder Size] */
Holder_Base_Height = 8;
Holder_Side_Width = 5;
Holder_Coaster_Fit = 3;

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

size = Size;
imported_qr_base_size = 280;
border_width = (Style == "raised" ? Raised_Border_Size : 0);
border_margin = (2 + border_width / 10);
rr = 10;
edge_radius = Edge_Radius;
coaster_height = Base_Height + (Style == "raised" ? QR_Height : 0);

slop = 0.001;

// Modules //

module round_3d(radius = edge_radius) {
    if (radius == 0) {
        children();
    } else {
        render()
        minkowski() {
            children();
            for (mz = [0, 1])
            mirror([0, 0, mz])
            cylinder(r1=radius, r2=0, h=radius);
        }
    }
}

module qr_code() {
    ratio = (size - border_width * 2 - border_margin * 2) / imported_qr_base_size;
    scale([ratio, ratio])
    import(str("qr-", QR_Code, ".svg"), center=true);
}

module qr_border() {
    difference() {
        offset(r=rr)
        offset(r=-rr)
        square(size, center=true);
        offset(r=rr)
        offset(r=-rr)
        square(size - border_width * 2, center=true);
    }
}

module rounded_square(size, radius) {
    offset(r=radius)
    offset(r=-radius)
    square(size, center=true);
}

module rounded_square_3d(xy, z) {
    round_3d(edge_radius)
    translate([0, 0, edge_radius])
    linear_extrude(height=z - edge_radius * 2)
    rounded_square(xy - edge_radius * 2, radius=rr);
}

module coaster_base() {
    extra_ht = (
        (Style == "raised" && Raised_Border_Size > 0)
        ? QR_Height
        : 0
    );
    difference() {
        rounded_square_3d(xy=size, z=Base_Height + extra_ht);
        if (extra_ht > 0) {
            my_rr = rr - border_width;
            translate([0, 0, Base_Height])
            linear_extrude(height=extra_ht + slop)
            offset(r=my_rr)
            offset(r=-my_rr)
            square(size - border_width * 2, center=true);
        }
    }
}

module coaster() {
    if (Style == "raised") {
        color("mintcream", 0.8)
        coaster_base();
        translate([0, 0, Base_Height])
        linear_extrude(height=QR_Height)
        qr_code();
    } else if (Style == "inset") {
        color("mintcream", 0.8)
        difference() {
            coaster_base();
            translate([0, 0, Base_Height + slop])
            mirror([0, 0, 1])
            linear_extrude(height=QR_Height)
            qr_code();
        }
    }
}

module coaster_color() {
    base_ht = (Style == "raised" ? Base_Height : Base_Height - QR_Height + slop);
    color(Bottom_Color, 0.8)
    render()
    intersection() {
        coaster();
        linear_extrude(height=base_ht - slop)
        square(size * 2, center=true);
    }
    color(Top_Color, 0.8)
    render()
    intersection() {
        coaster();
        translate([0, 0, base_ht])
        linear_extrude(height=QR_Height)
        square(size * 2, center=true);
    }
}

module holder() {
    round_3d(edge_radius)
    difference() {
        translate([0, 0, edge_radius])
        linear_extrude(
            height=Holder_Base_Height + coaster_height * 8 - edge_radius * 2
        )
        difference() {
            rounded_square(
                size + (Holder_Coaster_Fit + Holder_Side_Width - edge_radius) * 2,
                radius=rr
            );
            rounded_square(
                size - (Holder_Coaster_Fit * 8) - (edge_radius) * 2,
                radius=rr
            );
        }
        translate([0, 0, Holder_Base_Height - edge_radius])
        linear_extrude(height=Holder_Base_Height + coaster_height * 8)
        union() {
            rounded_square(
                size + (Holder_Coaster_Fit - edge_radius) * 2,
                radius=rr
            );
            for (rz = [0, 90])
            rotate(rz)
            square([size * 0.6, size + Holder_Side_Width * 4], center=true);
        }
    }
}

module main() {
    if (Part == "coaster") {
        coaster_color();
    } else if (Part == "holder") {
        color("white", 0.9)
        holder();
        if ($preview && Preview_Coasters_in_Holder)
        for (i = [0:1:7])
        translate([0, 0, Holder_Base_Height + coaster_height * i])
        coaster_color();
    }
}

main();
