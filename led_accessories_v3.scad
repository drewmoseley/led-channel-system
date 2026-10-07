/* Modular LED channel accessories - Customizer ready */

/* [Output] */
part = "electrical_t_assembly"; // [rounded_corner_assembly,rounded_corner_body,rounded_corner_diffuser,square_corner_assembly,square_corner_body,square_corner_diffuser,t_connector_assembly,t_connector_body,t_connector_diffuser,electrical_t_assembly,electrical_t_body,electrical_t_diffuser,electrical_t_box,electrical_t_cover,end_cap,cable_end_cap,bridge_clip,mounting_clip]

/* [Shared Channel Profile] */
strip_width = 10; // [6:0.5:20]
strip_clearance = 1.0; // [0:0.1:2]
strip_thickness = 2.2; // [0.5:0.1:5]
wall = 1.6; // [0.8:0.1:4]
base = 1.6; // [0.8:0.1:4]
air_gap = 5; // [1:0.5:20]
diffuser_thickness = 0.8; // [0.4:0.1:2.5]
diffuser_overlap = 0.8; // [0.2:0.1:2]
// Clearance around the diffuser in its pocket
diffuser_clearance = 0.2; // [0:0.05:0.5]
// Total diffuser width reduction for a sliding fit (split evenly between both sides)
diffuser_width_clearance = 0.1; // [0:0.05:0.5]
// Material above the diffuser groove (straight channel only; end cap plate covers it)
top_lip = 0.8; // [0.4:0.1:2]
// Extra wall thickness added outward around the diffuser pocket (45 degree underside)
rim_extra = 1.0; // [0:0.1:3]
preview_gap = 0; // [0:0.5:10]

/* [Corner and Tee Dimensions] */
corner_centerline_radius = 25; // [12:1:100]
corner_arm_length = 25; // [5:1:100]
square_corner_arm_length = 30; // [15:1:100]
t_main_half_length = 35; // [15:1:100]
t_branch_length = 35; // [15:1:100]
corner_segments = 48; // [12:1:120]


/* [Electrical T Junction Box] */

// Box width along the main run
junction_box_length = 32; // [20:1:60]

// Box width across the main run
junction_box_width = 28; // [18:1:60]

// Internal box depth below the channel
junction_box_depth = 8; // [4:0.5:20]

// Junction-box wall thickness
junction_box_wall = 1.6; // [0.8:0.1:4]

// Clearance between the box and its cover
junction_cover_clearance = 0.25; // [0:0.05:0.8]

// Cover thickness
junction_cover_thickness = 1.6; // [0.8:0.1:4]

// Wire pass-through width in each channel branch
junction_wire_slot_width = 6; // [2:0.5:14]

// Wire pass-through length along each channel branch
junction_wire_slot_length = 8; // [3:0.5:20]

// Distance that the cover lip enters the box
junction_cover_lip_depth = 3; // [1:0.5:8]

// Optional screw hole through the cover
junction_cover_screw = false;

// Cover screw diameter
junction_cover_screw_diameter = 3; // [1.5:0.1:6]

/* [End Caps] */
end_cap_thickness = 2; // [1:0.2:5]
collar_depth = 5; // [2:0.5:12]
cap_clearance = 0.25; // [0:0.05:0.8]
cable_hole_diameter = 5; // [2:0.5:15]

/* [External Clips] */
clip_length = 20; // [8:1:60]
clip_wall = 1.6; // [0.8:0.1:4]
clip_clearance = 0.25; // [0:0.05:0.8]
clip_side_height = 5; // [2:0.5:12]
retention_lip = 0.6; // [0:0.1:1.5]
screw_diameter = 3.4; // [1.5:0.1:8]
screw_head_diameter = 6.5; // [3:0.1:15]

/* [Advanced] */
$fn = 64;

inside_width = strip_width + strip_clearance;
outside_width = inside_width + 2*wall;
inside_height = strip_thickness + air_gap;
groove_height = diffuser_thickness + diffuser_clearance;
groove_floor = base + inside_height;
// matches led_channel.scad so parts join flush: groove + 45 degree roof rise + top lip
body_height = groove_floor + groove_height + diffuser_overlap + top_lip;
// slice height used to build 45 degree slopes from 2D offsets
slope_step = 0.1;

assert(wall + rim_extra - diffuser_overlap >= 0.8, "wall behind the diffuser pocket is under 0.8 mm; raise rim_extra or lower diffuser_overlap");
assert(corner_centerline_radius > outside_width/2 + rim_extra, "corner radius is too small for the rim");
assert(square_corner_arm_length > outside_width, "square corner arms are too short");
assert(t_main_half_length > outside_width/2, "T main run is too short");
assert(t_branch_length > outside_width, "T branch is too short");
assert(junction_box_length > outside_width, "junction box length must exceed channel width");
assert(junction_box_width > outside_width, "junction box width must exceed channel width");
assert(junction_box_wall*2 < junction_box_length, "junction box walls are too thick");
assert(junction_box_wall*2 < junction_box_width, "junction box walls are too thick");
assert(junction_wire_slot_width < inside_width, "wire slot must fit inside the LED cavity");

function arc_points(r,a1,a2,n) =
    [for(i=[0:n]) [r*cos(a1+(a2-a1)*i/n), r*sin(a1+(a2-a1)*i/n)]];

module annular_sector_2d(r_inner,r_outer,a1=0,a2=90,n=48) {
    polygon(points=concat(
        arc_points(r_outer,a1,a2,n),
        [for(i=[n:-1:0]) arc_points(r_inner,a1,a2,n)[i]]
    ));
}

// Channel footprints. g grows (+) or insets (-) the outline on every side while the
// arm ends stay put; ext lengthens the arm ends so cuts run out through them.
module rounded_path_2d(g=0,ext=0) {
    w = outside_width + 2*g;
    r1 = corner_centerline_radius-w/2;
    r2 = corner_centerline_radius+w/2;

    union() {
        annular_sector_2d(r1,r2,0,90,corner_segments);
        translate([r1,-(corner_arm_length+ext)])
            square([w,corner_arm_length+ext+0.02]);
        translate([-(corner_arm_length+ext),r1])
            square([corner_arm_length+ext+0.02,w]);
    }
}

module square_corner_path_2d(g=0,ext=0) {
    w = outside_width + 2*g;
    union() {
        translate([-g,-g]) square([square_corner_arm_length+ext+g,w]);
        translate([-g,-g]) square([w,square_corner_arm_length+ext+g]);
    }
}

module t_path_2d(g=0,ext=0) {
    w = outside_width + 2*g;
    union() {
        translate([-t_main_half_length-ext,-g])
            square([2*(t_main_half_length+ext),w]);
        translate([-w/2,-g])
            square([w,t_branch_length+ext+g]);
    }
}

module selected_path_2d(kind,g=0,ext=0) {
    if (kind == "rounded")
        rounded_path_2d(g,ext);
    else if (kind == "square")
        square_corner_path_2d(g,ext);
    else
        t_path_2d(g,ext);
}

// Outward thickening around the pocket, 45 degree underside so it prints without support
module rim_solid(kind) {
    n = ceil(rim_extra/slope_step);
    dz = rim_extra/n;
    if (rim_extra > 0) {
        for (k=[0:n-1])
            translate([0,0,groove_floor-rim_extra+k*dz])
                linear_extrude(height=dz+0.01) selected_path_2d(kind,(k+1)*dz);
        translate([0,0,groove_floor])
            linear_extrude(height=body_height-groove_floor) selected_path_2d(kind,rim_extra);
    }
}

// Corners and tees cannot take a diffuser that slides in along a straight groove, so the
// pocket is open at the top and the diffuser drops in from above.
module diffuser_pocket(kind) {
    translate([0,0,groove_floor])
        linear_extrude(height=body_height-groove_floor+1)
            selected_path_2d(kind,-(wall-diffuser_overlap),1);
}

module open_channel_body(kind="rounded") {
    difference() {
        union() {
            linear_extrude(height=body_height)
                selected_path_2d(kind);
            rim_solid(kind);
        }

        translate([0,0,base])
            linear_extrude(height=body_height)
                selected_path_2d(kind,-wall,1);

        diffuser_pocket(kind);
    }
}

module path_diffuser(kind="rounded") {
    translate([0,0,groove_floor+diffuser_clearance/2+preview_gap])
        linear_extrude(height=diffuser_thickness)
            selected_path_2d(kind,-(wall-(diffuser_overlap-diffuser_clearance))-diffuser_width_clearance/2);
}

// Cross-section of the straight channel profile, extruded along +x.
module channel_profile_extrude(h) {
    e = rim_extra;
    rotate([90,0,90]) linear_extrude(height=h)
        polygon([
            [0,0],[outside_width,0],
            [outside_width,groove_floor-e],[outside_width+e,groove_floor],
            [outside_width+e,body_height],[-e,body_height],
            [-e,groove_floor],[0,groove_floor-e]
        ]);
}

module end_cap(cable=false) {
    collar_outer_w = outside_width + 2*(wall-cap_clearance);
    collar_inner_w = outside_width + 2*cap_clearance;
    // keep the sleeve below the rim chamfer
    collar_h = min(groove_floor-rim_extra,base+5);

    difference() {
        union() {
            // plate matches the channel profile, so it also closes the diffuser groove
            channel_profile_extrude(end_cap_thickness);

            translate([end_cap_thickness,-(wall-cap_clearance),0])
                difference() {
                    cube([collar_depth,collar_outer_w,collar_h]);
                    translate([-0.1,wall,base])
                        cube([collar_depth+0.2,collar_inner_w,collar_h+0.2]);
                }
        }

        if (cable)
            translate([-0.1,outside_width/2,base+strip_thickness/2])
                rotate([0,90,0])
                    cylinder(h=end_cap_thickness+0.3,d=cable_hole_diameter);
    }
}

module external_clip(with_screw=false) {
    assert(clip_wall+clip_side_height <= groove_floor-rim_extra, "clip sides would hit the rim chamfer; lower clip_side_height");
    inner_w = outside_width + 2*clip_clearance;
    outer_w = inner_w + 2*clip_wall;

    difference() {
        union() {
            cube([clip_length,outer_w,clip_wall]);
            translate([0,0,clip_wall])
                cube([clip_length,clip_wall,clip_side_height]);
            translate([0,outer_w-clip_wall,clip_wall])
                cube([clip_length,clip_wall,clip_side_height]);

            if (retention_lip > 0) {
                translate([0,clip_wall,clip_wall+clip_side_height-retention_lip])
                    cube([clip_length,retention_lip,retention_lip]);
                translate([0,outer_w-clip_wall-retention_lip,clip_wall+clip_side_height-retention_lip])
                    cube([clip_length,retention_lip,retention_lip]);
            }
        }

        translate([-0.1,clip_wall,clip_wall])
            cube([clip_length+0.2,inner_w,body_height+2]);

        if (with_screw) {
            translate([clip_length/2,outer_w/2,-0.1])
                cylinder(h=clip_wall+0.3,d=screw_diameter);
            translate([clip_length/2,outer_w/2,max(0,clip_wall-1.2)])
                cylinder(h=1.4,d1=screw_diameter,d2=screw_head_diameter);
        }
    }
}


module electrical_t_wire_slots() {
    slot_w = junction_wire_slot_width;
    slot_l = junction_wire_slot_length;

    // Left branch.
    translate([-slot_l, (outside_width-slot_w)/2, -0.2])
        cube([slot_l, slot_w, base+0.4]);

    // Right branch.
    translate([0, (outside_width-slot_w)/2, -0.2])
        cube([slot_l, slot_w, base+0.4]);

    // Perpendicular branch.
    translate([-slot_w/2, 0, -0.2])
        cube([slot_w, slot_l, base+0.4]);
}

module electrical_t_body() {
    difference() {
        open_channel_body("tee");
        electrical_t_wire_slots();
    }
}

module electrical_t_box() {
    outer_l = junction_box_length;
    outer_w = junction_box_width;
    outer_h = junction_box_depth + junction_box_wall;

    difference() {
        // Box is shown below the channel in assembly preview.
        translate([-outer_l/2, (outside_width-outer_w)/2, -outer_h])
            cube([outer_l, outer_w, outer_h]);

        translate([
            -outer_l/2 + junction_box_wall,
            (outside_width-outer_w)/2 + junction_box_wall,
            -junction_box_depth
        ])
            cube([
                outer_l - 2*junction_box_wall,
                outer_w - 2*junction_box_wall,
                junction_box_depth + 0.2
            ]);

        // Three openings align with the pass-through slots in the T body.
        translate([
            -junction_wire_slot_length,
            (outside_width-junction_wire_slot_width)/2,
            -junction_box_wall-0.2
        ])
            cube([
                2*junction_wire_slot_length,
                junction_wire_slot_width,
                junction_box_wall+0.4
            ]);

        translate([
            -junction_wire_slot_width/2,
            0,
            -junction_box_wall-0.2
        ])
            cube([
                junction_wire_slot_width,
                junction_wire_slot_length,
                junction_box_wall+0.4
            ]);
    }
}

module electrical_t_cover() {
    outer_l = junction_box_length;
    outer_w = junction_box_width;
    lip_l = outer_l - 2*(junction_box_wall + junction_cover_clearance);
    lip_w = outer_w - 2*(junction_box_wall + junction_cover_clearance);

    difference() {
        union() {
            cube([outer_l, outer_w, junction_cover_thickness]);

            translate([
                junction_box_wall + junction_cover_clearance,
                junction_box_wall + junction_cover_clearance,
                junction_cover_thickness
            ])
                difference() {
                    cube([lip_l, lip_w, junction_cover_lip_depth]);

                    translate([junction_box_wall, junction_box_wall, -0.1])
                        cube([
                            max(0.1, lip_l-2*junction_box_wall),
                            max(0.1, lip_w-2*junction_box_wall),
                            junction_cover_lip_depth+0.2
                        ]);
                }
        }

        if (junction_cover_screw)
            translate([outer_l/2, outer_w/2, -0.1])
                cylinder(
                    h=junction_cover_thickness+junction_cover_lip_depth+0.3,
                    d=junction_cover_screw_diameter
                );
    }
}

module electrical_t_assembly() {
    color("dimgray") electrical_t_body();
    color([1,1,1,0.55]) path_diffuser("tee");
    color("slategray") electrical_t_box();

    // Cover shown beside the assembly so its fit is visible.
    color("gray")
        translate([
            junction_box_length/2 + 8,
            (outside_width-junction_box_width)/2,
            -junction_box_depth-junction_box_wall
        ])
            electrical_t_cover();
}

module assembly(kind) {
    color("dimgray") open_channel_body(kind);
    color([1,1,1,0.55]) path_diffuser(kind);
}

if (part == "rounded_corner_body")
    open_channel_body("rounded");
else if (part == "rounded_corner_diffuser")
    path_diffuser("rounded");
else if (part == "rounded_corner_assembly")
    assembly("rounded");
else if (part == "square_corner_body")
    open_channel_body("square");
else if (part == "square_corner_diffuser")
    path_diffuser("square");
else if (part == "square_corner_assembly")
    assembly("square");
else if (part == "electrical_t_body")
    electrical_t_body();
else if (part == "electrical_t_diffuser")
    path_diffuser("tee");
else if (part == "electrical_t_box")
    electrical_t_box();
else if (part == "electrical_t_cover")
    electrical_t_cover();
else if (part == "electrical_t_assembly")
    electrical_t_assembly();
else if (part == "t_connector_body")
    open_channel_body("tee");
else if (part == "t_connector_diffuser")
    path_diffuser("tee");
else if (part == "t_connector_assembly")
    assembly("tee");
else if (part == "end_cap")
    end_cap(false);
else if (part == "cable_end_cap")
    end_cap(true);
else if (part == "bridge_clip")
    external_clip(false);
else if (part == "mounting_clip")
    external_clip(true);
