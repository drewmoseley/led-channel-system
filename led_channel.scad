/* Parametric straight LED channel - Customizer ready */

/* [Output] */
part = "assembly"; // [assembly,body,diffuser,diffuser2]

/* [Channel] */
length = 150; // [20:1:1000]
strip_width = 10; // [6:0.5:20]
strip_clearance = 1.0; // [0:0.1:2]
strip_thickness = 2.2; // [0.5:0.1:5]
wall = 1.6; // [0.8:0.1:4]
base = 1.6; // [0.8:0.1:4]
air_gap = 5; // [1:0.5:20]
outer_corner_radius = 1.2; // [0:0.2:4]

/* [Strip retention] */
// Lips over the strip PCB edges that hold it down if the adhesive fails
strip_lip = "both"; // [both,left,right,none]
// How far each lip covers the strip edge; must fit in the margin between the LED and the strip edge
strip_lip_overlap = 0.8; // [0.3:0.1:2]
// Lip thickness (printed as a 2-layer-plus bridge over the strip)
strip_lip_thickness = 0.8; // [0.4:0.1:2]
// Gap between the strip PCB top and the lip underside; must clear solder joints and let the strip slide in
strip_lip_clearance = 1.0; // [0:0.05:1.5]
// Width of the LED package across the strip; limits the lip overlap
strip_led_width = 3.5; // [2:0.1:6]

/* [Diffuser] */
diffuser_thickness = 0.8; // [0.4:0.1:2.5]
diffuser_overlap = 0.8; // [0.2:0.1:2]
// Diffuser slides into a groove cut into each wall; this is how far it reaches into the wall
diffuser_clearance = 0.2; // [0:0.05:0.5]
// Total diffuser width reduction for a sliding fit (split evenly between both sides)
diffuser_width_clearance = 0.1; // [0:0.05:0.5]
// Material above the groove that holds the diffuser in
top_lip = 0.8; // [0.4:0.1:2]
// Extra wall thickness added outward around the groove (45 degree underside, no support needed)
rim_extra = 1.0; // [0:0.1:3]
preview_gap = 0; // [0:0.5:10]

/* [Second diffuser] */
// 2 stacks a second diffuser in its own groove above the first
diffuser_count = 1; // [1,2]
// Air between the top of diffuser 1 and the bottom of diffuser 2
diffuser2_gap = 3; // [1.8:0.1:10]
diffuser2_thickness = 1.2; // [0.4:0.1:2.5]

/* [Mounting] */
mount_style = "single"; // [none,single,double,alternating,flange]
mount_side = "left"; // [left,right]
mount_count = 3; // [1:1:12]
ear_width = 8; // [3:0.5:20]
ear_length = 14; // [6:1:30]
ear_thickness = 2.4; // [1:0.2:5]
flange_width = 10; // [3:0.5:25]
flange_thickness = 2.4; // [1:0.2:5]
screw_diameter = 3.4; // [1.5:0.1:8]
screw_edge_offset = 4; // [2:0.5:12]

/* [Advanced] */
$fn = 64;

// Evenly spaced: equal gaps between plates, half a gap at each end
mount_positions = [for (i=[0:mount_count-1]) (i+0.5)*length/mount_count];
inside_width = strip_width + strip_clearance;
outside_width = inside_width + 2*wall;
inside_height = strip_thickness + air_gap;
groove_height = diffuser_thickness + diffuser_clearance;
groove_floor = base + inside_height;
groove2_height = diffuser2_thickness + diffuser_clearance;
groove2_floor = groove_floor + diffuser_thickness + diffuser2_gap;
// groove roof slopes up 45 degrees toward the cavity (self-supporting), so add its rise to the height
top_floor = diffuser_count > 1 ? groove2_floor : groove_floor;
top_groove_height = diffuser_count > 1 ? groove2_height : groove_height;
body_height = top_floor + top_groove_height + diffuser_overlap + top_lip;
selected_side = mount_side == "right" ? 1 : -1;

assert(wall + rim_extra - diffuser_overlap >= 0.8, "wall behind the diffuser groove is under 0.8 mm; raise rim_extra or lower diffuser_overlap");
assert(diffuser_count < 2 || groove2_floor >= groove_floor + groove_height + diffuser_overlap + 0.8, "diffuser2_gap too small: less than 0.8 mm of wall between the two grooves");
assert(strip_lip == "none" || strip_lip_overlap <= (strip_width - strip_led_width)/2 - strip_clearance/2 + 0.001, "strip_lip_overlap reaches the LED package; lower it or the strip_led_width");
assert(strip_lip == "none" || strip_thickness + strip_lip_clearance + strip_lip_thickness + 0.8 <= inside_height, "strip lip leaves under 0.8 mm below the diffuser groove; raise air_gap");
assert(screw_edge_offset < max(ear_width,flange_width), "screw hole must remain inside mount");

module rounded_rect_2d(x,y,r) {
    rr = min(r,min(x,y)/2);
    if (rr <= 0) square([x,y]);
    else offset(r=rr) offset(delta=-rr) square([x,y]);
}

module rounded_box(size=[10,10,10],r=1) {
    linear_extrude(height=size[2]) rounded_rect_2d(size[0],size[1],r);
}

module screw_hole(h) { cylinder(h=h+0.4,d=screw_diameter); }

module mounting_ear(xpos,side=-1) {
    y0 = side < 0 ? -ear_width : outside_width;
    hy = side < 0 ? -screw_edge_offset : outside_width+screw_edge_offset;
    difference() {
        translate([xpos-ear_length/2,y0,0]) linear_extrude(height=ear_thickness) {
            // round only the two outer corners; body-side edge stays square
            rounded_rect_2d(ear_length,ear_width,1.5);
            translate([0,side < 0 ? ear_width/2 : -0.02])
                square([ear_length,ear_width/2+0.02]);
        }
        translate([xpos,hy,-0.2]) screw_hole(ear_thickness);
    }
}

module mounting_flange(side=-1) {
    y0 = side < 0 ? -flange_width : outside_width;
    hy = side < 0 ? -screw_edge_offset : outside_width+screw_edge_offset;
    difference() {
        translate([0,y0,0]) cube([length,flange_width,flange_thickness]);
        for (p=mount_positions) if (p > 0 && p < length)
            translate([p,hy,-0.2]) screw_hole(flange_thickness);
    }
}

// Outward thickening around the groove; underside is a 45 degree chamfer so it prints without support
// Clipped to a rounded footprint so the ends follow outer_corner_radius like the body
module groove_rim(side) {
    e = rim_extra;
    // extends into the wall (wall is solid there anyway) so the rim and body share one rounded corner
    pts = [[wall,groove_floor-e],[wall,body_height],[-e,body_height],[-e,groove_floor],[0,groove_floor-e]];
    if (e > 0) {
        intersection() {
            translate([0,-e,0]) rounded_box([length,outside_width+2*e,body_height],outer_corner_radius);
            if (side < 0)
                rotate([90,0,90]) linear_extrude(height=length) polygon(pts);
            else
                translate([0,outside_width,0]) rotate([90,0,90]) linear_extrude(height=length)
                    polygon([for(q=pts) [-q[0],q[1]]]);
        }
    }
}

module diffuser_groove(floor_z,h) {
    translate([-0.1,0,0]) rotate([90,0,90]) linear_extrude(height=length+0.2)
        polygon([
            [wall-diffuser_overlap,                floor_z],
            [wall+inside_width+diffuser_overlap,   floor_z],
            [wall+inside_width+diffuser_overlap,   floor_z+h],
            [wall+inside_width,                    floor_z+h+diffuser_overlap],
            [wall,                                 floor_z+h+diffuser_overlap],
            [wall-diffuser_overlap,                floor_z+h]
        ]);
}

// Ledge over one strip edge; reaches from the wall past the strip clearance
module strip_lip_bar(side) {
    reach = strip_lip_overlap + strip_clearance/2 + 0.02;
    y0 = side < 0 ? wall-0.02 : wall + inside_width - reach + 0.02;
    translate([0,y0,base+strip_thickness+strip_lip_clearance])
        cube([length,reach,strip_lip_thickness]);
}

module body() {
    union() {
        difference() {
            union() {
                rounded_box([length,outside_width,body_height],outer_corner_radius);
                groove_rim(-1);
                groove_rim(1);
            }
            // LED cavity, open at the top
            translate([-0.1,wall,base]) cube([length+0.2,inside_width,body_height]);
            // diffuser groove(s), open at both ends so each diffuser slides in
            // roof is lowest at the groove back and rises 45 degrees toward the cavity
            diffuser_groove(groove_floor,groove_height);
            if (diffuser_count > 1) diffuser_groove(groove2_floor,groove2_height);
        }

        if (strip_lip == "both" || strip_lip == "left") strip_lip_bar(-1);
        if (strip_lip == "both" || strip_lip == "right") strip_lip_bar(1);

        if (mount_style == "single")
            for (p=mount_positions) if (p > 0 && p < length) mounting_ear(p,selected_side);
        else if (mount_style == "double")
            for (p=mount_positions) if (p > 0 && p < length) { mounting_ear(p,-1); mounting_ear(p,1); }
        else if (mount_style == "alternating")
            for (i=[0:len(mount_positions)-1]) if (mount_positions[i] > 0 && mount_positions[i] < length)
                mounting_ear(mount_positions[i],i%2==0?-1:1);
        else if (mount_style == "flange") mounting_flange(selected_side);
    }
}

module diffuser_plate(floor_z,t) {
    w = inside_width + 2*(diffuser_overlap - diffuser_clearance) - diffuser_width_clearance;
    translate([0,wall-(diffuser_overlap-diffuser_clearance)+diffuser_width_clearance/2,floor_z+diffuser_clearance/2])
        cube([length,w,t]);
}

module diffuser() { diffuser_plate(groove_floor+preview_gap,diffuser_thickness); }
module diffuser2() { diffuser_plate(groove2_floor+2*preview_gap,diffuser2_thickness); }

if (part == "body") body();
else if (part == "diffuser") diffuser();
else if (part == "diffuser2") diffuser2();
else {
    color("dimgray") body();
    color([1,1,1,0.55]) diffuser();
    if (diffuser_count > 1) color([1,1,1,0.55]) diffuser2();
}
