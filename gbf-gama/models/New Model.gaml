/***
* Name: NewModel
* Author: guadalupebabio
* Description: Square matrix  with asign uses. 
* Tags: square
***/
/***
 * 29 Jan
 * Agents don't move
 ***/
model NewModel

global {
	//Number of agents to create
	int grid_size <- 6;
	
	//Size of the square
	int size_square <- 1000 ;
	float size_people <- size_square/10;
	graph the_graph;
	init{ 
		create road number:grid_size*2;
	    the_graph <- as_edge_graph(road);
	    
		//positions depending of the number of cells
		loop i from:0 to:grid_size-1{
			loop u from:0 to:grid_size-1{
				//Creation of the cell 
				create cell number: grid_size*grid_size{ 
					location <- {size_square*i*2 + size_square, size_square*u*2 + size_square}; 
			    }
			}
		}  
		create people number:6{
			speed <- 5.0 # km / # h; 
			location <- any_location_in(one_of(cell));
		}
		
		//ask people{ //what makes the ask people? R:
		//	myTarget<-any_location_in(one_of(cell)); 
		//}
		
	}
	
	//SPATIAL PARAMETERS
	int environment_height <- (grid_size + 1) * size_square * 2;
	int environment_width <- environment_height;
	bool blackMirror parameter: 'Dark Room' category: 'Aspect' <- true;
	
	//geometry shape <- envelope(x,y); 
	geometry shape <- rectangle(environment_width, environment_height); 
	
	//import csv
}


species road {
	rgb color<- rgb(0,0,225);
	aspect base_road{
		loop i from:0 to:grid_size-1{
			draw polyline([{size_square*i*2 + size_square,size_square}, {size_square*i*2 + size_square,size_square*5*2 + size_square}]) color:color; 
		} 
		loop i from:0 to:grid_size-1{
			draw polyline([{size_square,size_square*i*2 + size_square}, {size_square*5*2 + size_square,size_square*i*2 + size_square}]) color:color; 
		}
		
	}
}

species people skills:[moving]{
	point myTarget;
	reflex move{
	  	do goto target:myTarget speed:0.1 on: the_graph; //The agent should move to any location in one of the cells but it's not moving, why? R:
	}
	aspect base{
		draw circle(size_people) color:#blue;
	}
} //The agent doesnt move in the simulation  and I am doing the same as test.gaml R:


species cell {                      
  aspect default {
    draw square(size_square) color:#red border:#grey empty:false;   
  }
}


experiment NewModel type: gui {
	
	parameter "Size of the square:" var: size_square  min: 10 max: 3000;
	output {
	   display NewModel synchronized:true background:blackMirror ? #black :#white toolbar:false type:opengl draw_env:false {
		   //Why the transparency it's not applyed? R:
		   species cell transparency:0.6; 
		   species road aspect: base_road;
		   species people aspect: base;
		   //pressing letter "w" change the background color
		   event["w"] action: {blackMirror<-!blackMirror;};
		   
	   }
	}
}