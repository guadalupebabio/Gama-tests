/***
* Name: NewModel
* Author: guadalupebabio
* Description: Try to draw a line
* Tags: 
***/

model NewModel

global {
	
	int size_square <- 5 ;
	float min_speed <- 1.0 #km / #h;
	float max_speed <- 5.0 #km / #h;
	init{
		loop i from:0 to:1{
			create cell number: 2{ 
				location <- {0, 10*i};
			}
		}
	}
	
	init{
  		create road number:1;
		create people number:1{
			speed <- min_speed + rnd (max_speed - min_speed) ;
			//living_place <- one_of (cell);
			location <- any_location_in (cell); 
		}
	}
	
	
	geometry shape <- rectangle(15, 15); 
}




species people skills:[moving]{
	point the_target <- any_location_in (living_place) ;
	reflex move{
		do goto target: the_target ;
	}
	aspect base{
		draw circle(0.5) color:#blue;
	}
}


species road {
	rgb color<- rgb(0,0,255);
	aspect base_road{
		draw polyline([{0,0}, {0,10}]) color:color; // var0 equals a polyline
	}
}

species cell {                      
  aspect default {
    draw cube(size_square) color:#grey border:#grey at:location empty:false;   
  }
}



experiment test type: gui {
	
	output {
		display View1 type:opengl background:#white{
		 	species cell transparency:0.9;
		 	species road aspect: base_road;
		 	species people aspect:base;
		}
	}
}