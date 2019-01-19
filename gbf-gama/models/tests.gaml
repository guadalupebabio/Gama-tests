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
		loop i from:0 to:2{
			create cell number: numcubes{ 
				location <- {size_square*i*2 + size_square,0};
			}
		}
  		create road number:1;
		create people number:1{
			speed <- 5.0 # km / # h;
			location <- any_location_in(one_of(cell)); 
		}
	}
	
	
	geometry shape <- rectangle((numcubes + 1) * size_square * 2, (numcubes + 1) * size_square * 2); 
}


species people skills:[moving]{
	point myTarget <- nil;
	reflex move{
	  	do goto target:any_location_in(one_of(cell)) speed:0.1;
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
		 	//species cell transparency:0.9; //Even with transparency doesn't allow me to see the agent inside it
		 	species road aspect: base_road;
		 	species people aspect:base;
		}
	}
}