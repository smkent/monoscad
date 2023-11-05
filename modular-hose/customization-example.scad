/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Customization example from the model documentation
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

// Create this new model file in the same directory as modular-hose-library.scad
include <modular-hose-library.scad>;

// Initialize a modular hose part with an inner diameter of 50mm
modular_hose(inner_diameter=50) {

    // Create a male connector.
    // For a female connector, use modular_hose_connector_female().
    modular_hose_connector_male();

    // Since connectors render centered at the origin, attach our new part by
    // facing it downwards instead of upwards. Mirroring along the Z-axis flips
    // the parts to face down.
    mirror([0, 0, 1]) {

        // Let's create a square attachment base with a hole matching the hose
        // diameter (50mm). We can do this by creating a square with a hole
        // removed from the center, followed by extruding that to a 3D shape.
        color("lemonchiffon", 0.8)
        linear_extrude(height=10) // Make the attachment part 10mm thick
        difference() {
            // Create the 100x100mm square
            square(100, center=true);
            // Subtract a circle matching the hose diameter
            circle(50 / 2);
        }

    }
}
