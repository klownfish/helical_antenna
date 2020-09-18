use <dot/helix.scad>;
use <dot/hull_polyline3d.scad>;
use <dot/polyline3d.scad>;
use <dot/arc.scad>;
use <dot/hexagons.scad>;

//USER VARIABLES
//################################################################
frequency = 1550;  //in MHz
turns = 4.75;  //total amount of turns
wire_width = 3;  //diameter of wire
RHCP = true;  //left or right hand polarized
wall_width = 5; //thickness of the wall
//vvvvvvvvvv either or vvvvvvvvvvv
pitch_angle = 13;  //angle of the helix
turn_spacing = 0;  //spacing between turns
//################################################################
//screw sizes, default works for m3
screw_size = 3;     //radius of the screw
nut_radius = 3.4;   //"radius" of the nut, some trial and error required
//####################################


//comment this to lower the quality. Good for debugging
$fa = 1.8;
$fs = 1.8;

wave_length = 299792458000 / (frequency * 1000000);
circumference = wave_length;
radius = circumference / PI / 2 + wire_width;
spacing = turn_spacing ? turn_spacing : 
          tan(pitch_angle) * circumference;
length = spacing * turns;

echo("length=", length);
echo("diameter=", radius*2);

points = helix(
    radius = radius,
    levels = turns,
    level_dist = spacing,
    vt_dir = "SPI_UP", 
    rt_dir = "CLW"
);

scale([RHCP ? -1 : 1, 1, 1])
difference() {
    union() {
        //main tube
        cylinder(length + wire_width + 1, radius, radius);
        
        //bottom
        translate([0, 0, -1])
        cylinder(1, radius, radius);
    }
    
    //helix
    translate([0,0,wire_width])
    hull_polyline3d(points, wire_width * 2);
    
    //hollow the tube
    translate([0,0,13])
    cylinder(length + 2, radius - wall_width - wire_width, radius - wall_width - wire_width);
    
    //impedance match
    angle = wave_length /circumference / 4 * 360;
    linear_extrude(height = wire_width * 2)
    arc(radius = radius, angle = [0, angle], width = wire_width * 2);
    
    //screw
    translate([0, 0, -2])
    cylinder(23, screw_size / 2, screw_size / 2);
    
    //nut
    translate([0,0,8])
    linear_extrude(6)
    hexagons(radius = nut_radius, levels = 1, spacing = 0);
};