//  original drawing by dybde - 6mm
// reworked by Paxy
// reworked by Pierrevedel : male or female shape, triangle or square or rectangle or cross or circle with flat plane shape, shape parameter is now edge lenght and larger head

// preview[view:south east, tilt:top diagonal]
/*Customizer Variables*/
// Gender of the imprint
imprintGender=0;//[0:Female,1:Male]
// Shape of the imprint
imprintShape=4.5;//[3:Triangle,4:Square,4.5:Rectangle,4.6:Cross, 0:Circle with flat plane]
// Only for CIRCLE WITH FLAT.Diameter of the circular shape. BACKLASH : add 1-2mm for female, substrack 1-2mm for male 
imprintDiameter=16;//[1:0.5:50]
// Lenght of the imprint edge (or flat edge for CIRCLE WITH FLAT). BACKLASH : add 1-2mm for female, substrack 1-2mm for male 
imprintEdgeLenght=14;//[1:0.5:50]
// Only for RECTANGLE and CROSS. Lenght of the imprint small edge. BACKLASH : add 1-2mm for female, substrack 1-2mm for male 
imprintSmallEdgeLenght=7;//[1:0.5:50]
// Only for FEMALE key. Outer diameter of the blade. BACKLASH : substrack 1-2mm.
bladeOuterDiameter=20;//[1:0.5:50]
// Lenght of blade
bladeLenght=20;//[1:1:80]
// Only for FEMALE key. Deepness of imprint
imprintDepth=10;//[1:1:80]
// Lenght of the head
headLenght=10;//[5:1:20]
// Width of the head
headWidth=30;//[15:5:50]


/* [Hidden] */
$fn=50;
headThickness=6;
// to prevent null thickness
x=0.1;
//Z coordinate of the ring hole
ringZ=bladeOuterDiameter/2+headLenght+headWidth/2-headThickness/2;

//imprint shape with i for lenght; with i for z offset, j for imprint lenght and k for y offset  
module imprint(i,j,k){
    if (imprintShape>0)        
        // triangle, square, rectangle, cross
        for (a =[0:flagCross(imprintShape)])
        rotate ([0,0, a*90])scale([rectangleRescale(imprintShape),1,1])translate([0,k,i]) rotate ([0, 0, imprintRotation(imprintShape)])cylinder(r=imprintRadius(imprintShape),h=j,$fn=floor(imprintShape));
        // circle with flat
     else
        difference() {
        translate([0,k,i]) cylinder(r=imprintDiameter/2,h=j);
        translate([0,k+imprintDiameter/2,i+j/2]) cube([imprintEdgeLenght,2*(imprintDiameter/2-flatToCenterLenght()),j+x],true);
        };    
};
// 2 spheres belonging to both head and blabe
module headBladeJointElement(){
    translate([0,headWidth/2,bladeOuterDiameter/2]) sphere(r=headThickness/2);
};
module headBladeJoint(){
    headBladeJointElement();
    mirror([0,1,0]) headBladeJointElement();
};
//flat to insert ring
module RingFlatElement(){
    translate([headThickness/2,0,0])
    translate([0,0,ringZ+headThickness/2])
    rotate ([0, 90, 0])
    cylinder(r=headThickness,h=headThickness/2, center=true);
};
module RingFlat(){
    RingFlatElement();
    mirror([1,0,0]) RingFlatElement();
};
//radius of the tesselated cylinder; with i for number of imprint edges 
function imprintRadius(i)=
    (i==3) ? imprintEdgeLenght/(2*sin(60)) : imprintEdgeLenght*sqrt(2)/2;
//rotation of the imprint to line up with the head; with i for number of imprint side 
function imprintRotation(i)=
    (i==3) ? 30 : 45;
//offset to center male triangle imprint
function triangleOffsetY(i)=
    (i==3) ? (2*imprintRadius(imprintShape)-imprintEdgeLenght*cos(30))/2 : 0;
//rescale for rectangle
function rectangleRescale(i)=
    (i>4) ? imprintSmallEdgeLenght/imprintEdgeLenght :1;
//flag for cross
function flagCross(i)=
    (i==4.6) ? 1 : 0;
//distance from center of circle to flat
function flatToCenterLenght()=
    sqrt(pow(imprintDiameter/2,2)-pow(imprintEdgeLenght/2,2));

rotate ([0, 180, 0])

union(){
//blade
    ///female
    if (imprintGender==0){
        difference() {
            union() {    
                translate([0,0,-bladeLenght-bladeOuterDiameter/2])
                    cylinder(r=bladeOuterDiameter/2,h=bladeLenght+bladeOuterDiameter/2);
                //transition between blade and head
                hull() {
                    sphere(r=bladeOuterDiameter/2,center=true);	
                    headBladeJoint();
                    }
            }
            imprint(-bladeLenght-bladeOuterDiameter/2-x,imprintDepth,0);
        }
            
    ///male
    }else {
        union(){
            imprint(-bladeLenght+x,bladeLenght,triangleOffsetY(imprintShape));
            //transition between blade and head
            hull() {
                //null thick imprint to fit with the blade
                imprint(0,x,triangleOffsetY(imprintShape)); 
                headBladeJoint();
            }
        }
    }

//head
    difference() {
        hull() {
            headBladeJoint(); 
            //torus
            translate([0,0,bladeOuterDiameter/2+headLenght])
            rotate ([0, 90, 0])
            //cut half of torus
            difference() {
                rotate_extrude(angle = 360, convexity = 2) translate([headWidth/2,0,0])circle(r=headThickness/2);
                translate([(headWidth+headThickness+x)/2,0,0])cube(headWidth+headThickness+x, center=true);
            }
        }
        union(){
            RingFlat();
            //ring hole
            translate([0,0,ringZ]) rotate([0, 90, 0])
        cylinder(r=headThickness/2,h=headThickness, center=true);    
        }
    } 
}