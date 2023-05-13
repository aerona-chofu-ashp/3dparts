// Grant hot water cylinder mount for 80mm x 4mm thermistor probe
//
// Copyright (c) 2022 A. Theodore Markettos
// CC BY-SA 4.0

//
// Comprises three pieces:
// 1.  a boss which inserts into a 20mm thermostat pocket on the cylinder, into which
// 1b. an M5 stainless steel screw which holds the probe in place
// 2.  a base piece which presses into the boss, on which
// 2b. an RJ11 connector is mounted, and the probe soldered to the middle
//     pins of the RJ11 (so that a standard twisted pair telephone cable can be used)
// 3.  a cover to slide over piece (2) to protect the wiring

// The Grant/Chofu ASHP uses an NTC 10K thermistor, beta=3435, 1% tolerance
// These can be found on Aliexpress - sellers and listings vary, but
// a sample description might be:
// "NTC B3435 10K Thermistor Temperature Sensor NTC 10K Probe 4mm * 80mm
// 150 C for STC-1000 STC-3008"

// To enable the hot water thermistor, wire it to terminals 7/8 on the
// Aerona3 heat pump and set setting 51 07 to 1.  The temperature can then
// be read via Modbus or from setting 01 31 on the room controller.

// The RJ11 connector used was this one:
// "JIUYUANCHUNJJ 15 Pcs RJ11 PCB Jacks Universal RJ11 Socket Female Jacks
// 6P4PCB RJ11 Telephone Female Connectors for Landline Phones Home
// Appliances Digital Products"
// https://www.amazon.co.uk/JIUYUANCHUNJJ-Universal-Telephone-Connectors-Appliances/dp/B0BFXHWNCM/
// which is a no-brand Chinese type - the pin arrangement may need adjusting
// for other types



diam_boss = 19.7;
boss_taper = 2;
diam_handle = diam_boss+boss_taper+6;
diam_hole = 4.9;
length_boss = 65;
length_handle = 3;
boss_recess = 30;

cable_slot=1.5;

fb_thickness = 3;
fb_width = 58;
fb_height = 29;
fb_hole_offset = 5;
fb_hole_diam = 3.5;

$fn = 100;

fixing_peg_length = 25;
fixing_peg_outer = 3.5;
fixing_peg_inner = 2;
fixing_peg_base_height = 10;
fixing_peg_base_diam = 11;
delta = 0.4;

module Boss() {
    difference() {
        union() {
            cylinder(h=length_handle*3, r=diam_boss/2);
            translate([0,0,length_handle*3]) cylinder(h=length_boss, r1=(diam_boss)/2, r2=(diam_boss-boss_taper)/2);
            cylinder(h=length_handle, r=diam_handle/2);
            translate([0,0,length_handle*2]) {
                cylinder(h=length_handle, r1=diam_handle/2-3, r2=(diam_handle/2));
            }
        }
        union() {
           translate([0,0,-10]) cylinder(h=length_boss+20, r=diam_hole/2);
        translate([0,0,-delta]) cylinder(h=boss_recess+delta*2, d=fixing_peg_base_diam+delta);
        translate([0,0,-10]) cube([cable_slot,diam_boss,length_boss+20]);
        }
    }
}



module hole(diam) {
    hole_height = 999;
    translate([0,0,-hole_height/2]) cylinder(h=hole_height, r=diam/2);
}

rj11_base_width = diam_handle;
rj11_base_length = 30;
rj11_base_thickness = 2;

hole_tolerance = 1;

rj11_peg_diam = 2.3+hole_tolerance/2;
rj11_pin_diam = 0.79+hole_tolerance;

module rj11_footprint() {
        translate([-6, 0, 0]) hole(rj11_peg_diam);
        translate([6, 0, 0]) hole(rj11_peg_diam);
        translate([-3.06/2, -4.84+2.54, 0]) hole(rj11_pin_diam);
        translate([3.06/2, -4.84, 0]) hole(rj11_pin_diam);
        translate([-1.02/2, -4.84, 0]) hole(rj11_pin_diam);
        translate([1.02/2, -4.84+2.54, 0]) hole(rj11_pin_diam);

}

module rj11_footprint_centred() {
    rotate([180,0,0]) translate([0,0,0]) rj11_footprint();
}

slot_depth = 1;
slot_tolerance = 0.75;
slot_height = rj11_base_thickness + slot_tolerance;
slot_lip = slot_depth*2;

module RJ11() {
    difference() {
        union() {
            translate([slot_depth+slot_tolerance,0,0]) cube([rj11_base_width-2*slot_depth-2*slot_tolerance, rj11_base_length-2*slot_depth-2*slot_tolerance, rj11_base_thickness]);
        }
        translate([rj11_base_width/2,6,0]) 
        rj11_footprint_centred();
    }
}


module fixing_peg() {
    difference() {
        difference() {
            union() {
                 cylinder(h=fixing_peg_base_height, d=fixing_peg_base_diam);
            }
            translate([0,0,-5]) cylinder(h=fixing_peg_length+10, d=fixing_peg_inner);
        }
        translate([0,0,-1]) rotate([0,0,45]) cube ([fixing_peg_base_diam,fixing_peg_base_diam,15+fixing_peg_length]);
    }
}


module rj11_mount_piece() {
    rotate([0,0,180]) translate([0,-diam_handle/2,0]) RJ11();
    translate([-rj11_base_width/2,-rj11_base_length+diam_handle/2,0*rj11_base_thickness])
    union() {
        fixing_peg();
        cylinder(h=rj11_base_thickness, d=rj11_base_width-2*slot_depth-2*slot_tolerance);
    };

}

wall_thickness = 3;
lid_depth = slot_lip+slot_height+slot_tolerance*3;
case_height = 16+lid_depth+wall_thickness;
rj11_depth = 13;
rj11_height = 15.5+lid_depth-slot_tolerance*3;
rj11_width = 14+slot_tolerance*2;


module rj11_case() {
    difference() {
        union() {
            cylinder(h=case_height, d=rj11_base_width);
            translate([-rj11_base_width/2,0,0])             cube([rj11_base_width, rj11_base_length, case_height]);
        }
        translate([0,0,-hole_tolerance/2]) union() {
            cylinder(h=case_height-wall_thickness, d=rj11_base_width-wall_thickness*2);
            translate([-rj11_base_width/2+wall_thickness,0,0])             cube([rj11_base_width-wall_thickness*2, rj11_base_length-wall_thickness, case_height-wall_thickness]);
            translate([-((rj11_base_width+wall_thickness)/2)+(rj11_width/2),rj11_base_length-10,0]) 
                cube([rj11_width, rj11_depth, rj11_height]);
            translate([0,slot_depth,slot_lip]) cylinder(h=slot_height, d=rj11_base_width-wall_thickness*2+2*slot_depth+2*slot_tolerance /*rj11_base_width-slot_depth+slot_tolerance*/);
            translate([-rj11_base_width/2+wall_thickness-slot_depth-slot_tolerance,slot_depth+slot_tolerance,slot_lip])             cube([rj11_base_width-wall_thickness*2+2*slot_depth+2*slot_tolerance, rj11_base_length-wall_thickness+2*slot_depth+2*slot_tolerance, slot_height]);
            translate([-(rj11_base_width+wall_thickness)/2,rj11_base_length-wall_thickness-slot_tolerance,0]) cube([rj11_base_width+wall_thickness,10,lid_depth-slot_height+slot_tolerance]);
        }
        
    }
            



}

translate([15,0,0]) rj11_mount_piece();
translate([50,0,0]) Boss();
translate([-30,0,0]) rj11_case();
