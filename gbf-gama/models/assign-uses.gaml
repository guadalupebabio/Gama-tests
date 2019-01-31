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
	int size_square <- 10 ;
	init{ 
		//positions depending of the number of cells
		loop i from:0 to:grid_size-1{
			loop u from:0 to:grid_size-1{
				//Creation of the cell //If I want to create a 3d grid add another loop por the z direction
				create cell number: grid_size*grid_size{ 
					location <- {size_square*i*2 + size_square, size_square*u*2 + size_square}; 
			    }
			}
		}  
		do init_buttons;
	}
	
	//SPATIAL PARAMETERS
	int environment_height <- (grid_size + 1) * size_square * 2;
	int environment_width <- environment_height;
	bool blackMirror parameter: 'Dark Room' category: 'Aspect' <- true;
	
	//GEOMETRY SHAPE <- envelope(x,y); 
	geometry shape <- rectangle(environment_width, environment_height); 
	
	list<building> residentials;
	map<building, float> offices;
	int action_type;
	
	/*** 
	//boutons images [106]
	list<file> images <- [
		file(imageFolder +"residential.png"),
		file(imageFolder +"office.png")
	];
	* 
	***/
	//LOAD IMAGES draging them into ()
	list<file> images <- [
		file("../images/residential.png"),  //Is this really working? why not the one from your code R:
		file("../images/office.png")
	];
	
	action init_buttons	{
		int inc<-0;
		ask button {
			action_nb<-inc;
			inc<-inc+1;
		}
	}
	
	//[181] I don't really understand what makes
	action activate_act {
		button selected_but <- first(button overlapping (circle(1) at_location #user_location));
		ask selected_but {
			ask button {bord_col<-#black;}
			action_type<-action_nb;
			bord_col<-#red;
		}
	}
	
	//[301]
	action build_buildings {
		cell selected_cell <- first(cell overlapping (circle(sqrt(shape.area)/100.0) at_location #user_location));
		if (selected_cell != nil) and (selected_cell.is_active) {
			if (action_type = 3) {ask selected_cell {do new_residential;}}//("S");}} 
			if (action_type = 4) {ask selected_cell {do new_office;}}//("S");}} 
		}
		on_modification_bds <- true;
	}
	//[315]
	action createCell(int id, int x, int y){
		list<string> types <- id_to_building_type[id];
		string type <- types[0];
		string size <- types[1];
		cell current_cell <- cell[x,y];
		bool new_building <- true;
		if (current_cell.my_building != nil) {
			building build <- current_cell.my_building;
			new_building <- (build.type != type) //or (build.size != size);
		}
		if (new_building) {
			if (type = "residential") {
				ask current_cell {do new_residential;}//(size);}
			} else if (type = "office") {
				ask current_cell {do new_office;}//(size);}
			}
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
species cell {                      
  aspect default {
    draw cube(size_square) color:#red border:#grey empty:false;   
  }
}

species building {
	string type <- "residential" among: ["residential", "office"];
	rgb color;
	geometry bounds;

	action initialize(cell the_cell, string the_type, string the_size) {
		the_cell.my_building <- self;
		type <- the_type;
		do define_color;
		shape <- the_cell.shape;
		if (type = "residential") {residentials << self;}
		else if (type = "office") {
			//offices[self] <- proba_choose_per_size[size];
		}
		bounds <- the_cell.shape + 0.5 - shape;
			
	}

	action define_color {
		color <- rgb(125,125,125)  );
	}
	aspect default {
		if show_building {draw shape scaled_by building_scale*1.1 empty:true color: color;}
	}
}

grid button width:3 height:4 {
	int action_nb;
	rgb bord_col<-#black;

	aspect normal {
		if (action_nb > 2 and not (action_nb in [11])) {draw rectangle(shape.width * 0.8,shape.height * 0.8).contour + (shape.height * 0.01) color: bord_col;}
		if (action_nb = 0) {draw "Residential"  color:#black font:font("SansSerif", 16, #bold) at: location - {15,-10.0,0};}
		else if (action_nb = 1) {draw "Office"  color:#black font:font("SansSerif", 16, #bold) at: location - {12,-10.0,0};}
		else {
			draw image_file(images[action_nb - 3]) size:{shape.width * 0.5,shape.height * 0.5};
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
experiment NewModel type: gui {
	
	parameter "Size of the square:" var: size_square  min: 10 max: 3000;
	//Allows visualize two windows at the same time, in this case: View 1 & Possible Actions
	layout value: horizontal([0::7131,1::2869]) tabs:true;
	
	output {
	   display View1 synchronized:true background:blackMirror ? #black :#white toolbar:false type:opengl draw_env:false {
		   species cell transparency:0.9; //Why the transparency it's not applyed? R:
		   species building;
		   //recognice the click of the mouse
		   event mouse_down action:infrastructure_management;
		   //pressing letter "w" change the background color
		   event["w"] action: {blackMirror<-!blackMirror;};
	   }
	   
		//Boutton of action [844]
		display action_buton name:"Possible Actions" ambient_light:100 	{
			species button aspect:normal ;
			event mouse_down action:activate_act;    
		}
	}
}