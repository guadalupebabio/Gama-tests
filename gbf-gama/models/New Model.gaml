/***
* Name: NewModel
* Author: guadalupebabio
* Description: Square matrix and agent moving in cells
* Tags: square
***/

model NewModel

global {
	//Number of agents to create
	int grid_size <- 6;
	
	//Size of the square
	int size_square <- 1000 ;
	init { 
			//positions depending of the number of cells
			loop i from:0 to:grid_size-1{
				loop u from:0 to:grid_size-1{
					//Creation of the cell 
					create cell number: grid_size*grid_size{ 
						location <- {size_square*i*2 + size_square, size_square*u*2 + size_square}; 
				    }
				}
			}  
	}
	//Size of the agent
	int size_agent <- 1000 ;
	
	// How I imagine if I can draw lines
	init {
	  		create road number:12;  //if I cange the number nothing happens
			//loop q from:0 to:grid_size-1{
			//	locationlines <- {size_square*q*2 + size_square,0}; //considering location <- {starting,ending} for the ones in vertical
		      //      //location <- {size_square*i*2 + size_square + grid_size*size_square ,size_square*i*2 + size_square  }; //considering location <- {starting,ending} for the ones in horizontal
				//}	
	}
	
	/***
	init { 
			//positions depending of the number of cells		
			//Creation of the cell 
			create people number: 1{ 
			location <- {0, 0}; 
			}  
	}
	***/
	
	
	//SPATIAL PARAMETERS  
	float environment_height <- (grid_size + 1) * size_square * 2;
	float environment_width <- environment_height;
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

 /***
species people{
	vegetation_cell myCell <- one_of (vegetation_cell) ; 
		
	init { 
		location <- myCell.location;
	}
		
	reflex basic_move { 
		myCell <- one_of (myCell.neighbours) ;
		location <- myCell.location ;
	}
	aspect base{
		draw circle(size_agent) color:#blue;
	}
}
***/

species cell {                      
  aspect default {
    draw cube(size_square) color:#red;   
  }
}

 
grid vegetation_cell width: 50 height: 50 neighbors: 4{
	rgb color <- rgb(255, 255, 255);
	list<vegetation_cell> neighbours  <- (self neighbors_at 2);
}



experiment NewModel type: gui {
	
	parameter "Size of the square:" var: size_square  min: 10 max: 3000;
	output {
	   display View1 synchronized:true background:blackMirror ? #black :#white toolbar:false type:opengl draw_env:false {
		   species cell;
		   species road aspect: base_road;
		   //species people aspect: base;
		   //grid vegetation_cell lines: #black ;
		   //pressing letter "w" change the background color
		   event["w"] action: {blackMirror<-!blackMirror;};
	   }
	}
}