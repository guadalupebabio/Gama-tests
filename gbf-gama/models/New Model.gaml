/***
* Name: NewModel
* Author: guadalupebabio
* Description: Square matrix and agent moving in cells
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
	int size_people <- size_square/10;
	init{ 
		create road number:grid_size*2;
	    
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
	//point myTarget; // I HAVE REMOVE THE <-nil as you have in the Urbam 3D
	point myTarget <- nil;
	reflex move{
	  	do goto target:{0,0} speed:0.1; //The agent should move to any location in one of the cells but it's not moving, why? R:
	}
	aspect base{
		draw circle(size_people) color:#blue;
	}
} //The agent doesnt move in the simulation  and I am doing the same as test.gaml R:


species cell {                      
  aspect default {
    draw cube(size_square) color:#red border:#grey empty:false;   
  }
}


experiment NewModel type: gui {
	
	parameter "Size of the square:" var: size_square  min: 10 max: 3000;
	output {
	   display View1 synchronized:true background:blackMirror ? #black :#white toolbar:false type:opengl draw_env:false {
		   species cell transparency:0.9; //Why the transparency it's not applyed? R:
		   species road aspect: base_road;
		   species people aspect: base;
		   //pressing letter "w" change the background color
		   event["w"] action: {blackMirror<-!blackMirror;};
	   }
	}
}