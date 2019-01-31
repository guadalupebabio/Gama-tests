/***
* Name: NewModel
* Author: guadalupebabio
* Description: Try to make an agent move
***/

model NewModel

global {
	int size_square <- 3 ;
	int numcubes <- 3;
	graph road_network;
	init{
		loop i from:0 to:numcubes-1{
			create cell_work number: numcubes { 
				location <- {size_square*i*2 + size_square,0};
			}
			create cell_live number: numcubes { 
				location <- {size_square*i*2 + size_square,10};
			}
		}
  		create road number:2;
  		road_network <- as_edge_graph(road);
		create people number:1{
			speed <- 5.0 # km / # h;
			location <- any_location_in(one_of(cell_work)); 
		}
		ask people{
		myTarget<-any_location_in(one_of(cell_live));
		//myTarget<-{myTarget.x -0.5 + rnd(150)/100.0,myTarget.y -0.5 + rnd(150)/100.0,myTarget.z + rnd(100)/100.0};
		}
	}
	
	geometry shape <- rectangle((numcubes + 1) * size_square * 2, (numcubes + 1) * size_square * 2); 
}


species people skills:[moving]{
	point myTarget;
	reflex move{
	  	do goto target:myTarget on: road_network speed:0.1;
	}

	//reflex move{
	//	do move;
	//}
	aspect base{
		draw circle(0.5) color:#red;
	}
}

species road {
	rgb color<- rgb(0,0,255);
	aspect base_road{
		draw polyline([{size_square,0}, {size_square*2*2 + size_square,0}, {size_square*2*2 + size_square,10},{size_square,10}, {size_square,0}]) color:color;
		draw polyline([{size_square*1*2 + size_square,0},{size_square*1*2 + size_square,10}]) color:color;
	}
}

species cell_work {                      
  aspect default_work {
    draw cube(size_square) color:#grey border:#grey empty:false; //when empty: true only one appears, with false the three R:
  }
}
species cell_live {                      
  aspect default_live {
    draw cube(size_square) color:#red border:#grey empty:false; //when empty: true only one appears, with false the three R:
  }
}



experiment test type: gui {
	output {
		display View1 type:opengl background:#white{
		 	species cell_live; //transparency:0.90; //Even with transparency doesn't allow me to see the agent inside it
		 	species cell_work transparency:0.95;
		 	species road aspect: base_road;
		 	species people aspect:base;
		}
	}
}
//how can I make the scipt loop, I mean once it gets the targer finds a new one
