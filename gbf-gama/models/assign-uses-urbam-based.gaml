/***
* Name: NewModel
* Author: guadalupebabio
* Description: Assign Uses to cells based on Urbam model made by Arno, Pat et Tri 
* Tags: mouse_down
* Doubts: I am not able to make less squares in the Possible Actions window
***/

model NewModel

global{
	//PARAMETERS
	bool blackMirror <- true;
	//SPATIAL PARAMETERS  
	int grid_height <- 6;
	int grid_width <- 6;
	float environment_height <- 5000.0;
	float environment_width <- 5000.0;
	float block_size;
	bool on_modification_bds <- true update: false;
	
	map<string,rgb> color_per_type <- ["residential"::#gray, "office"::#orange];
	list<building> residentials;
	map<building, float> offices;                                                                            //What is map R:
	int action_type;
	
	//geometry shape <- envelope(nyc_bounds0_shape_file);
	geometry shape<-rectangle(environment_width, environment_height); // one edge is 5000(m)
	
	//image des boutons
	string imageFolder <- "../images/";
	list<file> images <- [
		file(imageFolder +"residential.png"),
		file(imageFolder +"office.png")
	]; 
	
	//Charge the bottons of the left side
	init {
		do init_buttons; 
	}
	
	action init_buttons	{
		int inc<-0;
		ask button {
			action_nb<-inc;
			inc<-inc+1;
		}
	}
	
	action activate_act {
		button selected_but <- first(button overlapping (circle(1) at_location #user_location));
		ask selected_but {
			ask button {bord_col<-#black;}
			action_type<-action_nb;
			bord_col<-#red;
		}
	}
		
	action assign_building_type {
		cell selected_cell <- first(cell overlapping (circle(sqrt(shape.area)/100.0) at_location #user_location));
		if (selected_cell != nil){
			if (action_type = 3) {ask selected_cell {do new_residential;}} 
			if (action_type = 4) {ask selected_cell {do new_office;}} 
		}
	}
	
}


species building {
	string type <- "residential" among: ["residential", "office"];
	rgb color;
	geometry bounds;

	action initialize(cell the_cell, string the_type) {
		the_cell.my_building <- self;
		type <- the_type;
		do define_color;
		shape <- the_cell.shape;
		if (type = "residential") {residentials << self;}
		bounds <- the_cell.shape + 0.5 - shape;
			
	}
	
	action remove {}
	action define_color {
		color <- rgb(color_per_type[type]);//gives the different colours assigned in global
	}
	aspect default {
		draw shape scaled_by 0.65*1.1 empty:true color: color;
	}
}

grid cell width: grid_width height: grid_height { 
	building my_building;
	action new_residential {
		if (my_building != nil and (my_building.type = "residential")) {
			return;
		} else {
			if (my_building != nil ) {ask my_building {do remove;}}
			create building returns: bds{
				do initialize(myself, "residential");
			}
		}
		
	}
	action new_office (string the_size) {
		if (my_building != nil and (my_building.type = "office")) {
			return;
		} else {
			if (my_building != nil) {ask my_building {do remove;}}
			create building returns: bds{
				do initialize(myself, "office");
			}
		}
	}
	aspect default{
		draw shape scaled_by (0.5) color: rgb(100,100,100) ;
	}
}

grid button width:3 height:4 {
	int action_nb;
	rgb bord_col<-#black;
	aspect normal {
		if (action_nb > 2 and not (action_nb in [5])) {draw rectangle(shape.width * 0.8,shape.height * 0.8).contour + (shape.height * 0.01) color: bord_col;}
		if (action_nb = 0) {draw "Residential"  color:#black font:font("SansSerif", 13, #bold) at: location - {25,-10.0,0};}
		else if (action_nb = 1) {draw "Office"  color:#black font:font("SansSerif", 13, #bold) at: location - {12,-10.0,0};}
		else {
			draw image_file(images[action_nb - 3]) size:{shape.width * 0.5,shape.height * 0.5} ;
		}
	}
}

experiment assignUses type: gui autorun: true{
	float minimum_cycle_duration <- 0.05;
	layout value: horizontal([0::7131,1::2869]) tabs:true;
	output {
		display map synchronized:true background:blackMirror ? #black :#white toolbar:false type:opengl  draw_env:false //fullscreen:1
		camera_pos: {2160.3206,1631.7982,12043.0275} camera_look_pos: {2160.3206,1631.588,0.0151} camera_up_vector: {0.0,1.0,0.0}{
			species cell aspect:default;// refresh: on_modification_cells;
			species building;// refresh: on_modification_bds;
			event mouse_down action:assign_building_type;
		}
				
	    //Bouton d'action
		display action_buton name:"Possible Actions" ambient_light:100 	{
			species button aspect:normal ;
			event mouse_down action:activate_act;    
		}
		
	}
}
