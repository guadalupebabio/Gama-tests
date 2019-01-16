/***
* Name: NewModel
* Author: guadalupebabio
* Description: Try to draw a line
* Tags: 
***/

model NewModel

global {
	init{
  	create road number:2;
	} 
	
	
	//Number of agents to create
	//geometry var1 <- polyline([{0,0}, {0,10}, {10,10}, {10,0}],0.2); // var1 equals a poly
	//geometry var0 <- polyline([{0,0}, {0,10}, {10,10}, {10,0}]); // var0 equals a polyline
	
	
	//geometry shape <- envelope(x,y); 
	geometry shape <- rectangle(15, 15); 
}

species road {
	rgb color<- rgb(0,0,255);
	aspect base_road{
		draw polyline([{0,0}, {0,10}, {10,10}, {10,0}]) color:color; // var0 equals a polyline
		draw polyline([{1,0}, {1,10}, {11,10}, {11,0}]) color:color;
	}
}



experiment test type: gui {
	
	
	output {
		display View1 {
		species road aspect: base_road;	
		}
	}
}