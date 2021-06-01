/**
Collapsible, locking basket.
(For placing things into, like a waste basket,
not really for carrying things around.
Might still work for that, though.)

Run get_deps.sh to clone dependencies into a linked folder in your home directory.
*/

use <deps.link/BOSL/nema_steppers.scad>
use <deps.link/BOSL/joiners.scad>
use <deps.link/BOSL/shapes.scad>
use <deps.link/erhannisScad/misc.scad>
use <deps.link/erhannisScad/auto_lid.scad>
use <deps.link/scadFluidics/common.scad>
use <deps.link/quickfitPlate/blank_plate.scad>
use <deps.link/getriebe/Getriebe.scad>
use <deps.link/gearbox/gearbox.scad>

$FOREVER = 1000;
DUMMY = false;
$fn = DUMMY ? 20 : 120;

BASE_STRIPE_W = 5;
BASE_STRIPE_W0 = 10;
SIDE_STRIPE_W = 10;
SIDE_STRIPE_W0 = 20;

RING_T = 2;
RING_H = 40;
RING_BARRIER = 2;

BASE_D = 150;
PEG_D = 4;
N_RINGS = 5;
DD = RING_T*1.5;

// I notice I have an annoying mix of parameters and constants...hmm.
//   ...And occasionally hardcoded numbers.

module groove(t=PEG_D+1,h=RING_H-RING_BARRIER*2) {
    channel([0,0],[0,h],d=t,cap="none");
    channel([0,h-t/2],[t*1.5,h-t/2],d=t,cap="square");
    channel([t*1.5,h-t/2],[t*1.5,h-t/2-t],d=t,cap="square");
}

module ring(d=40,t=RING_T,h=RING_H,peg=true,groove=true,grip=false) {
    difference() {
        //radialPerforate(d=d+t/2,t=40,t0=40,h=RING_H*2) {
            difference() {
                cylinder(d=d+t/2,h=h);
                cylinder(d=d-t/2,h=$FOREVER,center=true);
            }
        //}
        
        if (groove) {
            crotate([0,0,180]) crotate([0,0,90]) tz(RING_BARRIER) rx(90) linear_extrude(height=$FOREVER,center=false) {
                groove(t=PEG_D+1,h=h-RING_BARRIER*2);
            }
        }
        if (grip) {
            tz(RING_H-PEG_D*3) teardrop(d=PEG_D*2, l=$FOREVER);
        }
    }
    if (peg) {
        rz(arcAngle(d=d,l=-(PEG_D+2))) crotate([0,0,180]) crotate([0,0,90]) difference() {
            intersection() {
                GAP = 0.4;
                tz(PEG_D/2+RING_BARRIER+GAP) ty(-d/2) rx(-90) tz(-10) cylinder(d=PEG_D,h=t*2+10);
                cylinder(d=d,h=$FOREVER,center=true);
            }
            cylinder(d=d-DD*1.5,h=$FOREVER,center=true);
        }
    }
    if (grip) {
        rz(arcAngle(d=d,l=-(PEG_D+2))) crotate([0,0,180]) crotate([0,0,90]) difference() {
            difference() {
                tz(PEG_D/2) ty(-d/2) rx(-90) tz(-3) cylinder(d=PEG_D,h=t*2+10);
                cylinder(d=d,h=$FOREVER,center=true);
            }
            cylinder(d=d-DD*1.5,h=$FOREVER,center=true);
        }
    }
}

function recurseAA(d,dd,dmin,l) = (d < dmin) ? 0 : arcAngle(d=d,l=l) + recurseAA(d-dd,dd,dmin,l);

difference() {
    for (i=[0:N_RINGS-1]) {
        d=BASE_D+DD*i;
        if (i == 0) {
            // Base
            perforate(nx=10,ny=10,t=BASE_STRIPE_W,t0=BASE_STRIPE_W0) {
                cylinder(d=d,h=RING_T);
            }
        }
        // Rings
        rz(recurseAA(d=d,dd=DD,dmin=BASE_D,l=+(PEG_D+2))) ring(d=d,t=RING_T,h=RING_H,peg=(i!=0),groove=(i<N_RINGS-1),grip=(i==N_RINGS-1));
    }
    //OZp([0,0,5]);
}
//groove();
