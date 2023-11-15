Part = "female"; // [female: Female, male: Male, blank: Blank]

color("cyan", 0.8)
render()
if (Part == "male") {
    translate([-4.13, -0.815, 0.001])
    import("x-axis-left-mount-block-articulated-camera-male.stl");
} else if (Part == "female") {
    translate([0.325, -2.245, 0])
    import("x-axis-left-mount-block-articulated-camera-female.stl");
} else if (Part == "blank") {
    translate([-1.44, -1.475, 0])
    import("x-axis-left-mount-block-blank.stl");
}
