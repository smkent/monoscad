/*
 * Filament runout sensor extruder mount for Sovol SV06 Plus
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Render_Mode = "print"; // [print: Print Orientation, normal: Upright installed orientation, model_preview: Preview of model installed on extruder]

/* [Options] */
Runout_Sensor_Orientation = "rear"; // [rear: Connector facing rear of extruder, right: Connector facing right side of extruder, front: Connector facing front of extruder, left: Connector facing left side of extruder]

/* [Development Toggles] */
// Round all edges on the finished model. This uses minkowski() and may be very slow to render.
Round_Edges = false;

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

runout_exit_pos = [3.4972, 8.0042, 0.005936];
runout_foot_height = 6.8;
runout_connector_x = 30.209;
runout_connector_coords = [
    [5.5045, 18.688],
    [9.5045, 18.688],
    [9.505, 25.688],
    [5.505, 25.688],
];

extruder_assembly_width = 69.405;
extruder_assembly_height = 53.794;
extruder_corner_chamfer = 2.8;
extruder_inlet_pos = [33.352, -11.578, 42.6502];
extruder_hole_1_pos = [3.405, 46.394];
extruder_hole_2_pos = [65.405, 46.394];

screw_diameter = 3;
screw_hole_diameter = screw_diameter + 0.4;

mount_base_path_height = 8 + extruder_corner_chamfer;
mount_base_thick = 2;
mount_height = 30;
mount_thick = 3;
mount_top_thick = mount_thick * 1.5;

edge_radius = Round_Edges ? 0.5 : 0;
adj_height = extruder_assembly_height - mount_base_path_height;

base_y_add = 8;
base_y = abs(extruder_inlet_pos[1]) + base_y_add;

$curve_cut_top = 0;

// Modules //

module orient_sensor() {
    if (Runout_Sensor_Orientation == "rear") {
        rotate(90)
        children();
    } else if (Runout_Sensor_Orientation == "front") {
        rotate(270)
        children();
    } else if (Runout_Sensor_Orientation == "right") {
        children();
    } else if (Runout_Sensor_Orientation == "left") {
        rotate(180)
        children();
    }
}

module runout_sensor() {
    orient_sensor()
    color("#ccc", 0.7)
    translate(-runout_exit_pos)
    import("sovol-sv06plus-runout-sensor-rotated.stl", convexity=4);
}

module runout_sensor_wire_harness() {
    orient_sensor()
    rotate(-90)
    translate([runout_exit_pos[1], -runout_exit_pos[0], runout_exit_pos[2]])
    translate([0, runout_connector_x, 0])
    mirror([1, 0, 0])
    mirror([0, 1, 0])
    rotate([90, 0, 0])
    union() {
        color("mintcream", 0.6)
        linear_extrude(height=4) {
            difference() {
                polygon(points=[for (c = runout_connector_coords) c]);
                offset(delta=-0.5)
                polygon(points=[for (c = runout_connector_coords) c]);
            }
        }
        runout_x = (runout_connector_coords[2][0] - runout_connector_coords[0][0]);
        runout_z = (runout_connector_coords[2][1] - runout_connector_coords[0][1]);
        translate(runout_connector_coords[0])
        translate([runout_x / 2, runout_z / 2])
        for (vec = [[-1, "silver"], [0, "gray"], [1, "slategray"]]) {
            color(vec[1], 0.5)
            linear_extrude(height=20)
            translate([0, runout_z / 3 * vec[0]])
            circle(d=1.5, $fn=15);
        }
    }
}

module sensor_foot_shape() {
    hull()
    projection(cut=true)
    translate([0, 0, -1])
    runout_sensor();
}

module extruder_assembly() {
    color("#aaa", 0.5)
    import("sovol-sv06-JXHSV06-08000-extruder-parts.stl", convexity=4);
}

module filament() {
    color("lemonchiffon", 1.0)
    cylinder(h=70, d=1.75, $fn=15);
}

module extruder_top_outline_shape() {
    extra = $curve_size_extension;
    polygon(points=[
        [-extra, -extra],
        [extra + extruder_assembly_width, -extra],
        [extra + extruder_assembly_width, mount_base_path_height - extruder_corner_chamfer],
        [extra + extruder_assembly_width - extruder_corner_chamfer, mount_base_path_height],
        [-extra + extruder_corner_chamfer, mount_base_path_height],
        [-extra, mount_base_path_height - extruder_corner_chamfer],
    ]);

}

module mount_curve_shape_base(extra_size=0) {
    $curve_size_extension = extra_size;
    difference() {
        union() {
            extruder_top_outline_shape();
            translate([extruder_inlet_pos[0], 0])
            hull()
            for (mx = [0:1:1])
            mirror([mx, 0])
            for (ox = [0:1:1])
            translate(ox ? [$curve_x_offset, mount_height - mount_base_path_height / 2] : [15 + $curve_x_offset, mount_base_path_height / 2])
            circle(d=mount_base_path_height);
        }
        if ($curve_cut_top > 0) {
            color("blue");
            translate([0, mount_height - $curve_cut_top])
            square([extruder_assembly_width, $curve_cut_top * 2]);
        }
    }
}

module mount_curve_shape_solid(x_offset=5, custom_r=0) {
    r = (custom_r == 0 ? (10.0 - (5 - x_offset) * 2) : custom_r);
    $curve_x_offset = x_offset;
    $curve_size_extension = 0;
    intersection() {
        offset(r=-r)
        offset(r=r * 2)
        offset(r=-r)
        mount_curve_shape_base(extra_size=50);
        union() {
            extruder_top_outline_shape();
            translate([extruder_corner_chamfer, 0])
            square([extruder_assembly_width - extruder_corner_chamfer * 2, mount_height * 2]);
        }
    }
}

module mount_curve_shape(cut_top=0) {
    $curve_cut_top = cut_top;
    offset(delta=-edge_radius)
    difference() {
        color("lightblue", 0.5)
        mount_curve_shape_solid();
        translate([0, -mount_base_path_height])
        mount_curve_shape_solid(2.5);
    }
}

module screw_holes_shape_cut() {
    difference() {
        children();
        for (hole_pos = [extruder_hole_1_pos, extruder_hole_2_pos])
        translate([hole_pos[0], hole_pos[1] - adj_height])
        circle(d=screw_hole_diameter + edge_radius * 2);
    }
}

module screw_holes_chamfer_cut() {
    difference() {
        children();
        color("#94c5db", 0.8)
        for (hole_pos = [extruder_hole_1_pos, extruder_hole_2_pos])
        translate([hole_pos[0], hole_pos[1] - adj_height])
        translate([0, 0, mount_thick / 2])
        cylinder(h=mount_thick / 2 + 0.1, r2=screw_hole_diameter + edge_radius, r1=screw_hole_diameter / 2 + edge_radius);
    }
}

module mount_height_intersect() {
    intersection() {
        children();

        color("lemonchiffon", 0.5)
        mirror([0, 1, 0])
        rotate([90, 0, 0])
        linear_extrude(height=mount_height)
        offset(delta=-edge_radius)
        union() {
            translate([0, -mount_base_path_height + mount_thick])
            mount_curve_shape_solid(4, custom_r = 18.5);
            square([extruder_assembly_width, mount_thick]);
        }
    }
}

module sensor_foot_cut() {
    extra_factor = 1.2;
    difference() {
        children();
        rotate([270, 0, 0])
        translate([extruder_inlet_pos[0], extruder_inlet_pos[1], 0] + [0, 0, mount_height - mount_top_thick * extra_factor - 0.1])
        linear_extrude(height=mount_top_thick * extra_factor + 1 + 0.1 * 2, scale=1.05)
        offset(delta=edge_radius)
        sensor_foot_shape();
    }
}

module mount_assembled_shape() {
    translate([0, 0, edge_radius])
    linear_extrude(height=mount_thick - edge_radius * 2)
    screw_holes_shape_cut()
    mount_curve_shape();

    translate([0, 0, edge_radius])
    linear_extrude(height=base_y - edge_radius * 2)
    difference() {
        mount_curve_shape();
        translate([0, -mount_thick])
        mount_curve_shape(cut_top=mount_top_thick - mount_thick);
    }
}

module round_all_edges() {
    if (Round_Edges && edge_radius > 0) {
        color("#94c5db", 0.8)
        minkowski() {
            children();
            sphere(r=edge_radius);
        }
    } else {
        children();
    }
}

module extruder_runout_mount() {
    round_all_edges()
    color("#94c5db", 0.8)
    render(convexity=2)
    screw_holes_chamfer_cut()
    sensor_foot_cut()
    mount_height_intersect()
    mount_assembled_shape();
}

module position_model() {
    if (Render_Mode == "print") {
        children();
    } else if (Render_Mode == "normal") {
        rotate([90, 0, 0])
        children();
    } else {
        rotate([90, 0, 0])
        translate([0, adj_height, 0])
        children();

        if ($preview) {
            translate(extruder_inlet_pos - [0, 0, 5])
            filament();
            translate(extruder_inlet_pos + [0, 0, mount_height - runout_foot_height])
            union() {
                runout_sensor();
                runout_sensor_wire_harness();
            }
            extruder_assembly();
        }
    }
}

module main() {
    position_model()
    extruder_runout_mount();
}

main();
