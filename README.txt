LED CHANNEL SYSTEM V3
=====================

Parametric 3D-printed LED strip channel with a separate diffuser. Written for
OpenSCAD; every dimension is a Customizer parameter.

FILES
-----
led_channel.scad          Straight channel (body, diffuser, assembly) with mounting ears or flange
led_channel.json          Customizer parameter set for the straight channel
led_accessories_v3.scad   Corners, T junctions, electrical T, end caps, clips
led_accessories_v3.json   Customizer parameter set for the accessories (matches led_channel.json)

Select what to render with the "part" parameter, then export STL.

DESIGN
------
The body is an open-top channel. The diffuser is a separate flat part that is
not fused to the body (no multi-material printing).

Straight channel: slide-in diffuser
  - A groove is cut into the inside of each wall near the top. The diffuser
    slides into it from either end. The wall above the groove holds it in; the
    wall below carries it.
  - The wall thickness stays at "wall". A rim that is thicker outward by
    "rim_extra" surrounds the groove, so the groove has enough material behind it.
    The rim's underside is a 45 degree chamfer, so it prints without supports.
  - The groove roof also slopes at 45 degrees (lowest at the groove back, rising
    toward the cavity), so it prints without supports or sagging.
  - The LED cavity itself is not narrowed, so the strip drops in from the top.
  - "diffuser_overlap" is how far the diffuser reaches into each wall (groove
    depth). "diffuser_clearance" is the slide fit. "top_lip" is the material
    above the groove at the cavity edge.
  - "diffuser_width_clearance" narrows the diffuser by that total amount (split
    evenly between both sides) so it does not bind in the groove. It also
    applies to the corner and T diffusers.
  - "diffuser_count" 2 (straight channel only) cuts a second groove above the
    first for a stacked second diffuser. "diffuser2_gap" is the air between the
    two diffusers (minimum 1.8 mm), "diffuser2_thickness" the second plate.
    Use part=diffuser2 for the second plate. Two layers diffuse better but are
    taller and dimmer.
  - "strip_lip" (both/left/right/none) adds a ledge over each strip PCB edge so
    the strip stays put if its adhesive fails. "strip_lip_overlap" is how far
    the ledge covers the edge (must stay clear of the LED package, see
    "strip_led_width"), "strip_lip_thickness" its thickness, and
    "strip_lip_clearance" the gap between the PCB top and the ledge underside.
    Size that gap to clear solder joints and let the strip slide in from the
    end. The ledges are anchored to the walls, so with a loose strip the
    overlap varies by up to "strip_clearance" from side to side. Corners and
    T junctions have no lip.
  - "air_gap" is the distance from the strip to the underside of the diffuser.
    The finished body is taller than strip + air_gap by the groove, roof rise
    and top lip.
  - "mount_count" sets how many mounting ears (or flange screw holes) the
    channel gets. They are spaced evenly along "length": equal gaps between
    them, and half a gap at each end. Centers are at (i+0.5)*length/mount_count.
    Example at length 200: count 3 gives 33.3, 100 and 166.7 mm. Keep the
    pitch (length/mount_count) larger than "ear_length" or the ears touch.
  - Mounting ears are square where they meet the body; only the two outer
    corners are rounded.
  - "outer_corner_radius" rounds the channel ends in plan view. The rim follows it.
  - An end cap or other stop at the far end keeps the diffuser from sliding out.

Corners and T junctions: drop-in diffuser
  - A diffuser cannot slide around a bend or into a branch, so these parts have
    the same rim and ledge but the pocket is open at the top. Drop the diffuser
    in from above and hold it with a dab of glue, tape, or a clip.
  - Bodies are built to the same height as the straight channel, so parts join
    flush.

End caps
  - The plate follows the full channel profile, including the rim, so it closes
    the diffuser groove and retains a slide-in diffuser. The sleeve stops below
    the rim chamfer.

Clips
  - The clip sides must stay below the rim chamfer. An assert fails if
    clip_side_height is too tall for the current dimensions.

PARAMETER SETS
--------------
led_channel.json holds a set named "Bar Shelf Lighting": 187.5 mm units for an
8 mm wide, 0.8 mm thick strip with strip lips (wall 1, base 1, air_gap 5.5,
strip_clearance 1.0). led_accessories_v3.json holds a matching set named
"New set 1". In OpenSCAD, pick the set in the Customizer parameter set
dropdown, or from the command line:

  openscad -o body.stl -p led_channel.json -P "Bar Shelf Lighting" -D 'part="body"' led_channel.scad

A set loaded with -P overrides -D on the same parameter, so to change one value
(for example length) pass every set value with -D instead of using -P.

Export the body and the diffuser as separate STL files. Do not reuse one export
for both.

STRAIGHT CHANNEL PARTS
----------------------
- body
- diffuser
- assembly (preview)

SLIM T
------
- t_connector_body
- t_connector_diffuser
- t_connector_assembly

ELECTRICAL T
------------
- electrical_t_body
- electrical_t_diffuser
- electrical_t_box
- electrical_t_cover
- electrical_t_assembly

The electrical T has three slots through the channel floor at the junction.
Short jumper wires pass through those slots into a separate box beneath the
channel. The soldered branch connections are therefore outside the illuminated
channel and remain accessible by removing the cover.

PRINTING AND ASSEMBLY
---------------------
1. Print the channel body upright with the base on the build plate. Run a short
   test piece first (30-40 mm) and check that the diffuser slides in without
   binding. Adjust diffuser_clearance if it is tight or loose.
2. Print the diffuser flat. Translucent filament works well.
3. Install the LED strip in the cavity, then slide the diffuser into the groove.
4. For corners and T parts, drop the diffuser into the open pocket and secure it.

Electrical T:
1. Print electrical_t_body normally, channel base on the build plate.
2. Print electrical_t_box with its closed bottom on the build plate.
3. Print electrical_t_cover flat.
4. Solder the input strip to two branch strips in parallel.
5. Route the jumper wires through the three slots.
6. Attach the box beneath the T with adhesive, small screws, or solvent/CA
   appropriate to the filament.
7. Press the cover into the box.

The box is intentionally a separate part. Making it integral below the channel
would leave the channel arms suspended during printing and require substantial
supports.

ELECTRICAL NOTES
----------------
For single-color, CCT, or analog RGB/RGBW strips, connect corresponding pads
in parallel.

For addressable strips, power and ground may branch, but one data signal sent
to both branches makes both branches mirror each other. Independent branch
effects require separate controller data outputs.

Size the feed wire and power supply for the combined current of both branches.

STATUS
------
The straight channel with strip lips has been test printed and fits. The
corner, T and electrical T accessories render clean but are not yet test
printed.
