/* Parametric straight LED channel - Customizer ready */

/* [Output] */
part = "assembly"; // [assembly,body,diffuser]

/* [Channel] */
length = 150; // [20:1:1000]
strip_width = 10; // [6:0.5:20]
strip_clearance = 0.5; // [0:0.1:2]
strip_thickness = 2.2; // [0.5:0.1:5]
wall = 1.6; // [0.8:0.1:4]
base = 1.6; // [0.8:0.1:4]
air_gap = 5; // [1:0.5:20]
outer_corner_radius = 1.2; // [0:0.2:4]

/* [Diffuser] */
diffuser_thickness = 0.8; // [0.4:0.1:2.5]
diffuser_overlap = 0.8; // [0.2:0.1:2]
// Diffuser slides into a groove cut into each wall; this is how far it reaches into the wall
diffuser_clearance = 0.2; // [0:0.05:0.5]
// Material above the groove that holds the diffuser in
top_lip = 0.8; // [0.4:0.1:2]
// Extra wall thickness added outward around the groove (45 degree underside, no support needed)
rim_extra = 1.0; // [0:0.1:3]
preview_gap = 0; // [0:0.5:10]

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
// groove roof slopes up 45 degrees toward the cavity (self-supporting), so add its rise to the height
body_height = groove_floor + groove_height + diffuser_overlap + top_lip;
selected_side = mount_side == "right" ? 1 : -1;

assert(wall + rim_extra - diffuser_overlap >= 0.8, "wall behind the diffuser groove is under 0.8 mm; raise rim_extra or lower diffuser_overlap");
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
            // diffuser groove, open at both ends so the diffuser slides in
            // roof is lowest at the groove back and rises 45 degrees toward the cavity
            translate([-0.1,0,0]) rotate([90,0,90]) linear_extrude(height=length+0.2)
                polygon([
                    [wall-diffuser_overlap,                groove_floor],
                    [wall+inside_width+diffuser_overlap,   groove_floor],
                    [wall+inside_width+diffuser_overlap,   groove_floor+groove_height],
                    [wall+inside_width,                    groove_floor+groove_height+diffuser_overlap],
                    [wall,                                 groove_floor+groove_height+diffuser_overlap],
                    [wall-diffuser_overlap,                groove_floor+groove_height]
                ]);
        }

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

module diffuser() {
    w = inside_width + 2*(diffuser_overlap - diffuser_clearance);
    translate([0,wall-(diffuser_overlap-diffuser_clearance),groove_floor+diffuser_clearance/2+preview_gap])
        cube([length,w,diffuser_thickness]);
}

if (part == "body") body();
else if (part == "diffuser") diffuser();
else { color("dimgray") body(); color([1,1,1,0.55]) diffuser(); }
