/***
* Name: NewModel
* Author: guadalupebabio
* Description: Square matrix and agent moving in cells
* Tags: square
***/

model NewModel

global {
	//Number of agents to create
	geometry var1 <- polyline([{0,0}, {0,10}, {10,10}, {10,0}],0.2); // var1 equals a poly
	geometry var0 <- polyline([{0,0}, {0,10}, {10,10}, {10,0}]); // var0 equals a polyline
	
	
	//geometry shape <- envelope(x,y); 
	geometry shape <- rectangle(15, 15); 
}

species road {
	rgb color<- rgb(125,125,125);
	aspect base_road{
		draw polyline([{0,0}, {0,10}, {10,10}, {10,0}]); // var0 equals a polyline
	
	}
}



experiment test type: gui {
	
	
	output {
		display View1 {
		species road aspect: base_road;	
		}
	}
}