// custom variables
$fn=50; // when it starts working for no reason!
radius=25;
height=1.5*radius;
minusT=0.25*radius;
startEnd=1;
threadT=4.5;
threadJ=1.5;
byCycles=false;
defaultCycles=15;
defaultZstep=threadT+0.5; // must be greater than threadT!
separation=5;
ringT=2;
ringH=2;
holeR1=17.5;
holeR2=15;
holeH=5;
tolerance=0.3;
rsep=2;
pthick=1;
split=false;

// automatically calculated, ignore
cycles = byCycles ? defaultCycles : (height-2*startEnd-threadT)/defaultZstep;
zstep = byCycles ? (height-2*startEnd-threadT)/cycles : defaultZstep;
ratio=minusT/height;
astep=360/$fn;
segments=floor(cycles*$fn);
ringR=(radius-calcMinus(height/2))*0.75;
insertHole=zstep-0.25*threadT;
psize=pthick+insertHole/2;
pheight=insertHole/2+startEnd+0.75*threadT;
insertR=radius-calcMinus(pheight)+threadJ;

echo("MINIMUM MAXIMUM CAPACITY = ")
echo(cycles*2*PI*(radius-minusT));

split()
difference() {
	union() {
		rotate([0,0,90-($fn-2)*180/$fn])
			body();
		thread();
		translate([0,insertR,0])
		mirror([1,0,0])
		rotate([90,0,0])
		rotate_extrude(angle=90) {
			translate([pheight,0])
				circle(psize);
			translate([0,-psize])
				square([pheight,2*psize]);
		}
	}
	translate([0,insertR,0])
	mirror([1,0,0])
	rotate([90,1,0])
	rotate_extrude(angle=92)
	translate([pheight,0])
			circle(insertHole/2);
}

module body() {
	difference() {
		rotate_extrude()
		difference() {
			square([radius,height]);
			translate([radius,0.5*height])
			scale([1,0.5*height/minusT])
				circle(minusT);
		}
		translate([0,0,-0.1])
			cylinder(r1=holeR1,r2=holeR2,h=holeH+0.1);
	}
}

module thread() {
	upper=[for(i=[0:segments]) // why openscad, why?!
		let(h=i*zstep/$fn+threadT)
		let(r=radius-calcMinus(h+startEnd)-0.0)
		[r*sin(astep*i),
		r*cos(astep*i),
		h]];
	lower=[for(i=[0:segments]) //use incriments instead nerd
		let(h=i*zstep/$fn)
		let(r=radius-calcMinus(h+startEnd)-0.0)
		[r*sin(astep*i),
		r*cos(astep*i),
		h]];
	jut=[for(i=[0:segments]) 
		let(h=i*zstep/$fn+threadT/2)
		let(r=radius+threadJ-calcMinus(h+startEnd))
		[r*sin(astep*i),
		r*cos(astep*i),
		h]];
	points=concat(upper,lower,jut);
	/*for(i=points) {
		color([0.1,0.1,0.5])
		translate([0,0,startEnd])
		translate(i)
			cube(1, center=true);
	}*/
	spines=segments+1;
	ends=[[0,spines,2*spines],[spines-1,3*spines-1,2*spines-1]];
	wall=[for(i=[0:segments-1])
		[i,i+1,spines+1+i,spines+i]];
	top=[for(i=[0:segments-1])
		[i+1,i,2*spines+i,2*spines+i+1]];
	bottom=[for(i=[0:segments-1])
		[spines+i,spines+i+1,2*spines+i+1,2*spines+i]];
	faces=concat(ends,wall,top,bottom);
	translate([0,0,startEnd])
		polyhedron(points,faces, convexity=10); // durrrr
}

function calcMinus(zDist)=
	let(centeredH=zDist-height/2)
	let(scaledH=2*ratio*centeredH)
	minusT*sin(acos(scaledH/minusT));

module split() {
	if(split) {
		difference() {
			union() {
				translate([-radius-separation,0,0])
					children();
				translate([radius+separation,0,height])
				mirror([0,0,1])
					children();
			}
			difference() {
				translate([0,0,0.75*height+0.1])
					cube([4*radius+2*separation+0.1,2*radius+0.1,
						height/2+0.1], center=true);
				translate([radius+separation,0,height/2-0.1])
					ring(tolerance);
			}
			translate([-radius-separation,0,height/2-ringH])
				ring(0);
		} 
	} else {
		children();	
	}
}

module ring(tol) {
		difference() {
			cylinder(r=ringR-tol,h=ringH+0.1);
			translate([0,0,-0.1])
				cylinder(r=ringR-ringT+tol,h=ringH+0.3);
			translate([-ringR+0.1,-(rsep+tol)/2,-0.1])
				cube([2*ringR+0.2,rsep+tol,ringH+0.3]);
		}
}
