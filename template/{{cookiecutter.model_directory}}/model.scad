{%- extends "vars.jinja" -%}
{%- block content -%}
/*
 * {{ cookiecutter.title }}
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under {{ license_title }}
 */

/* [Rendering Options] */
Print_Orientation = true;

/* [Size] */
// All units in millimeters

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

// Modules //

module main() {
}

main();
{% endblock -%}
