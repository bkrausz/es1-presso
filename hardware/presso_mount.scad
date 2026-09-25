// ============================================================
//  Fellow Espresso Series 1 — piano-key servo presser (MG996R)
//  Two printed parts: BASE (sits on the warming mat behind the keys,
//  clamps to the raised side lip) and ARM (bolts to the servo horn).
//
//  Coordinates:  X = front/back (+X toward the FRONT of the machine)
//                Y = left/right (0 = inner face of the raised side lip,
//                    +Y across the keys: espresso, steam, hot water)
//                Z = up, Z=0 = top of the warming mat (base sits here)
//  Units: mm.  Everything you might need to tune is in the block below.
// ============================================================

part = "assembly";   // "base" | "arm" | "assembly"   (set via -D on the CLI)

// ---------- machine measurements (yours) ----------
key_len          = 63;     // front-to-back length of a key (pivot at rear)
key_w            = 25;     // width of one key
key_gap          = 0.7;    // gap between keys (you said <1mm)
lip_to_first_key = 1;      // raised side lip -> hot-water key
lip_thick        = 4;      // raised side lip thickness
lip_above_key    = 11;     // lip height above key top
mat_above_key    = 1;      // warming mat sits ~1mm above key top
key_travel       = 3;      // key front dips this much for a press
press_from_front = 18;     // where the pad lands, measured from key FRONT edge

// ---------- clearances / tuning ----------
key_rear_clear   = 2;      // base front edge sits this far behind the key rear
rest_clear       = 3;      // pad bottom above key at rest
overtravel       = 0.5;    // extra beyond full key travel the stop allows
lip_slot_clear   = 0.3;    // slot = lip_thick + this   (tighten if it rocks)
sv_riser         = 4;      // servo sits this high off the plate (lets the arm hub clear it)

// ---------- MG996R (standard-size servo footprint; check with calipers) ----------
sv_len      = 40.5;   // body length (ear direction)
sv_w        = 20.0;   // body width
sv_h        = 38.0;   // body bottom -> top of case (shaft face)
sv_ear_z    = 28.0;   // bottom -> underside of ears
sv_ear_t    = 2.5;    // ear thickness
sv_ear_ext  = 7.0;    // ears stick out past each body end
sv_hole_dx  = 49.0;   // hole spacing along length
sv_hole_dy  = 10.0;   // hole spacing across width
sv_hole_d   = 3.4;    // M3 clearance (ear holes are ~4mm)
sv_shaft_off= 10.0;   // shaft center from the shaft-end of the body
sv_horn_h   = 4.0;    // case top -> underside of the horn disc

// ---------- horn disc (measure the round horn in your MG996R bag) ----------
horn_d      = 21.0;   // round horn diameter
horn_t      = 2.0;    // horn thickness
horn_bc_r   = 7.0;    // radius of the 4 screw holes on the horn
horn_screw_d= 1.8;    // self-tap hole for the M2 horn screws
horn_center_d = 6.5;  // clearance for the center retaining-screw head

// ---------- printed part sizes ----------
base_t      = 4;      // base plate thickness
wall        = 3;      // general wall thickness
arm_t       = 4;      // arm thickness (lateral)
arm_h       = 10;     // arm beam height
pad_w       = 8;      // pad footprint front/back
stop_screw_d= 2.6;    // M3 self-tap hole for the adjustable stop screw

$fn = 48;

// ============================================================
//  Derived geometry
// ============================================================
key_pitch   = key_w + key_gap;
esp_y0      = lip_to_first_key;                 // espresso key is the one next to the lip
esp_yc      = esp_y0 + key_w/2;                 // espresso key centerline
key_top_z   = -mat_above_key;                   // key surface (mat = 0)
lip_top_z   = key_top_z + lip_above_key;

// servo lies on its side: shaft axis along +Y, body bottom face at sv_y0
arm_yc      = esp_yc;                             // arm plane on key centerline
sv_ytop     = arm_yc + arm_t/2 + sv_horn_h;       // shaft face of the case (faces the lip)
sv_ybot     = sv_ytop + sv_h;                     // bottom face of the case (away from lip)
ear_y1      = sv_ybot - sv_ear_z;                 // ear plate, shaft-side face
ear_y0      = ear_y1 - sv_ear_t;
tab_y0      = ear_y1;                             // tab sits on the BODY side of the ear (ear between tab and horn)
tab_y1      = tab_y0 + wall;

sv_xfront   = -key_rear_clear - wall;             // shaft-end of body
sv_xback    = sv_xfront - sv_len;
shaft_x     = sv_xfront - sv_shaft_off;
shaft_z     = base_t + sv_riser + sv_w/2;
body_xc     = (sv_xfront + sv_xback)/2;

press_x     = key_len - press_from_front;         // pad lands here (X)
arm_L       = press_x - shaft_x;                  // shaft -> pad, horizontal
press_dip   = key_travel * press_x / key_len;     // key dips this much at pad
press_angle = asin((rest_clear + press_dip + overtravel) / arm_L);

base_x0     = sv_xback - sv_ear_ext - wall - 2;   // rear edge of base
base_x1     = -key_rear_clear;                    // front edge of base
base_y0     = -(lip_thick + lip_slot_clear) - 6;  // outboard wall of lip clamp
base_y1     = sv_ybot + wall + 2;                 // just past the servo fence

stop_x      = base_x1 - 1;                        // stop screw in the arm lands on plate here
hub_r       = horn_d/2 + 2;                       // arm hub radius
stop_pad_z  = 8;                                  // landing pad height for the stop screw

echo(str("arm length shaft->pad = ", arm_L, " mm"));
echo(str("press angle (rest -> full press) = ", press_angle, " deg"));
echo(str("key dip at pad = ", press_dip, " mm"));
echo(str("hub lowest point above plate top = ", (shaft_z - hub_r) - base_t, " mm"));
echo(str("stop screw tip below arm beam at full press = ", (shaft_z - arm_h/2) - stop_pad_z - (stop_x - shaft_x) * sin(press_angle), " mm"));

// ============================================================
//  BASE
// ============================================================
module base() {
    difference() {
        union() {
            // plate
            translate([base_x0, base_y0, 0])
                cube([base_x1 - base_x0, base_y1 - base_y0, base_t]);

            // lip clamp block (straddles the raised side lip)
            translate([base_x0, base_y0, 0])
                cube([base_x1 - base_x0, -base_y0 + 4, lip_top_z + wall]);

            // riser pad under the servo
            translate([sv_xback - 1, sv_ytop - 1, 0])
                cube([sv_len + 2, sv_h + 2, base_t + sv_riser]);

            // fence at the servo's bottom face (keeps body from sliding away from the lip)
            translate([sv_xback, sv_ybot, 0])
                cube([sv_len, wall, base_t + sv_riser + 12]);

            // ear tabs (front and rear), plates in XZ on the body side of the ears
            // inner faces must clear the servo body (gap = sv_len + 0.6)
            for (sgn = [1, -1]) {
                xc = body_xc + sgn * sv_hole_dx/2;
                x_in  = body_xc + sgn * (sv_len/2 + 0.3);   // inner face
                x_out = xc + sgn * 8;                         // outer face
                translate([min(x_in, x_out), tab_y0, 0])
                    cube([abs(x_out - x_in), wall, base_t + sv_riser + sv_w + 2]);
            }

            // landing pad for the arm's stop screw
            translate([stop_x - 3, arm_yc - 3, 0])
                cube([6, 6, stop_pad_z]);

        }

        // slot for the raised lip (open at the bottom)
        translate([base_x0 - 1, -(lip_thick + lip_slot_clear), -1])
            cube([base_x1 - base_x0 + 2, lip_thick + lip_slot_clear, lip_top_z - mat_above_key + 0.5 + 1 + mat_above_key]);

        // clamp screw (M4) through the outboard wall, with nut trap
        translate([body_xc, base_y0 - 1, (lip_top_z)/2 + 1])
            rotate([-90, 0, 0]) {
                cylinder(d = 4.3, h = 20);
                // hex nut slot, open to the top of the block
                translate([0, 0, 1.5]) hull() {
                    cylinder(d = 7.4, h = 3.4, $fn = 6);
                    translate([0, -20, 0]) cylinder(d = 7.4, h = 3.4, $fn = 6);
                }
            }

        // ear screw holes (M3), through the tabs along Y
        for (xc = [body_xc + sv_hole_dx/2, body_xc - sv_hole_dx/2])
            for (dz = [-sv_hole_dy/2, sv_hole_dy/2])
                translate([xc, tab_y0 - 1, shaft_z + dz])
                    rotate([-90, 0, 0]) cylinder(d = sv_hole_d, h = wall + 2);

        // nothing may hang over the keys lower than 6mm above them
        translate([base_x1, -20, -20])
            cube([100, 200, 20 + key_top_z + 6]);

    }
}

// ============================================================
//  ARM  (modelled in place; pocket for the horn faces -Y)
// ============================================================
module arm() {
    y0 = arm_yc - arm_t/2;
    y1 = arm_yc + arm_t/2;
    pad_bottom_z = key_top_z + rest_clear;
    difference() {
        union() {
            // hub
            translate([shaft_x, y0, shaft_z]) rotate([-90, 0, 0])
                cylinder(r = hub_r, h = arm_t);
            // beam
            translate([shaft_x, y0, shaft_z - arm_h/2])
                cube([arm_L + pad_w/2, arm_t, arm_h]);
            // pad hanging down at the tip
            translate([press_x - pad_w/2, y0, pad_bottom_z])
                cube([pad_w, arm_t, shaft_z - pad_bottom_z]);
        }
        // horn pocket (on the +Y face, toward the servo)
        translate([shaft_x, y1 - horn_t, shaft_z]) rotate([-90, 0, 0])
            cylinder(d = horn_d + 0.4, h = horn_t + 1);
        // center screw-head clearance
        translate([shaft_x, y0 - 1, shaft_z]) rotate([-90, 0, 0])
            cylinder(d = horn_center_d, h = arm_t + 2);
        // adjustable stop: M3 threaded vertically through the arm at stop_x,
        // tip lands on the base plate when the key is fully pressed
        translate([stop_x, arm_yc, -5]) cylinder(d = stop_screw_d, h = 40);
        // 4 horn screws
        for (a = [45, 135, 225, 315])
            translate([shaft_x + horn_bc_r*cos(a), y0 - 1, shaft_z + horn_bc_r*sin(a)])
                rotate([-90, 0, 0]) cylinder(d = horn_screw_d, h = arm_t + 2);
    }
}

// ============================================================
//  Reference geometry for the assembly view (not printed)
// ============================================================
module reference() {
    // keys
    color("dimgray") for (i = [0:2])
        translate([0, lip_to_first_key + i*key_pitch, key_top_z - 3])
            cube([key_len, key_w, 3]);
    // raised lip
    color("dimgray") translate([base_x0 - 10, -lip_thick, key_top_z - 3])
        cube([key_len + 10 - base_x0 + 10, lip_thick, lip_above_key + 3]);
    // mat
    color("darkslategray") translate([base_x0 - 10, 0, -1])
        cube([-base_x0 + 10, base_y1 + 10, 1]);
    // servo body + ears + horn
    color("steelblue") {
        translate([sv_xback, sv_ytop, base_t + sv_riser]) cube([sv_len, sv_h, sv_w]);
        translate([sv_xback - sv_ear_ext, ear_y0, base_t + sv_riser])
            cube([sv_len + 2*sv_ear_ext, sv_ear_t, sv_w]);
        translate([shaft_x, sv_ytop - sv_horn_h - horn_t, shaft_z]) rotate([-90, 0, 0])
            cylinder(d = 6, h = sv_horn_h + horn_t);
        translate([shaft_x, sv_ytop - sv_horn_h, shaft_z]) rotate([-90, 0, 0])
            cylinder(d = horn_d, h = horn_t);
    }
}

// ============================================================
if (part == "base") base();
if (part == "arm")  translate([0, 0, -(arm_yc - arm_t/2)]) rotate([90, 0, 0]) arm();    // pocket face up
if (part == "assembly") { color("khaki") base(); color("orange") arm(); reference(); }
