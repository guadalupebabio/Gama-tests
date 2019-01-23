/***
* Name: NewModel
* Author: guadalupebabio
* Description: Try to make an agent move
***/

model NewModel

global {
	int size_square <- 3 ;
	int numcubes <- 3;
	init{
		loop j from:0 to:1{
			loop i from:0 to:numcubes-1{
				create cell number: numcubes*2 { 
					location <- {size_square*i*2 + size_square,j*10};
				}
			}
		}
  		create road number:1;
		create people number:1{
			speed <- 5.0 # km / # h;
			location <- {0,0}; 
		}
		ask people{
		myTarget<-any_location_in(one_of(cell));
		//myTarget<-{myTarget.x -0.5 + rnd(150)/100.0,myTarget.y -0.5 + rnd(150)/100.0,myTarget.z + rnd(100)/100.0};
		}
	}
	
	
	geometry shape <- rectangle((numcubes + 1) * size_square * 2, (numcubes + 1) * size_square * 2); 
}


species people skills:[moving]{
	point myTarget;
	reflex move{
	  	do goto target:myTarget speed:0.1;
	}

	//reflex move{
	//	do move;
	//}
	aspect base{
		draw circle(0.5) color:#blue;
	}
}

species road {
	rgb color<- rgb(0,0,255);
	aspect base_road{
		draw polyline([{0,0}, {0,10}]) color:color;
	}
}

species cell {                      
  aspect default {
    draw cube(size_square) color:#grey border:#grey empty:false; //when empty: true only one appears, with false the three R:
  }
}



experiment test type: gui {
	output {
		display View1 type:opengl background:#white{
		 	//species cell transparency:0.95; //Even with transparency doesn't allow me to see the agent inside it
		 	species road aspect: base_road;
		 	species people aspect:base;
		}
	}
}
//how can I make the scipt loop, I mean once it gets the targer finds a new one
