/***
* Name: NewModel
* Author: guadalupebabio
* Description: Assign Uses to cells based on Urbam model made by Arno, Pat et Tri. Reads a csv file.
* Next: Import data fromcsv fil
* Tags: mouse_down
* Doubts: I am not able to make less squares in the Possible Actions window. Why cells and buindings are not created in init{}.
* ***/

model NewModel

global{
	//PARAMETERS
	bool blackMirror <- true;
	//SPATIAL PARAMETERS  
	int grid_height <- 6;
	int grid_width <- 6;
	int nb_people <- 100;
	float environment_height <- 5000.0;
	float environment_width <- 5000.0;
	float block_size;
	float size_people <- (environment_height / (grid_width*20)) ;
	graph the_graph;
	int current_hour update: (time / #hour) mod 24;  ///m03
	int min_work_start <- 6;  ///m03
	int max_work_start <- 8;  ///m03
	int min_work_end <- 16;   ///m03
	int max_work_end <- 20;   ///m03
	float step <- 10 #mn;    ///m03
	
	map<string,rgb> color_per_type <- ["residential"::#gray, "office"::#orange, "retail"::#blue];
	list<building> residentials;
	list<building> offices;
	list<building> retails;  
	int action_type;
	
	geometry shape<-rectangle(environment_width, environment_height); // Size of the cells
	
	//image des boutons
	string imageFolder <- "../images/";
	list<file> images <- [
		file(imageFolder +"residential.png"),
		file(imageFolder +"office.png")
	]; 
	
	//import csv
	//string matrix_file <- "../includes/grid_6x6.csv"; 
	file my_csv_file <- csv_file("../includes/grid_6x6.csv",",");
	init {
		//convert the file into a matrix
		matrix data <- matrix(my_csv_file);
		//loop on the matrix rows (skip the first header line)
		loop i from: 0 to: data.rows -1{
			//loop on the matrix columns
			loop j from: 0 to: data.columns -1{
				write "data rows:"+ i +" colums:" + j + " = " + data[j,i];
				create building number:1{
					int id  <- int( data[j,i]);
					//do createCell(id, j, i);
					if (id=0){ask cell[j,i] {do new_retail;}} 
					if (id=1){ask cell[j,i] {do new_residential;}}
					if (id=2){ask cell[j,i] {do new_office;}}
					}
				}
			}	
		}		
	
	
	action assign_building_type {
		cell selected_cell <- first(cell overlapping (circle(sqrt(shape.area)/100.0) at_location #user_location));
		if (selected_cell != nil){
			if (action_type = 3) {ask selected_cell {do new_residential;}} 
			if (action_type = 4) {ask selected_cell {do new_office;}} 
			if (action_type = 5) {ask selected_cell {do new_retail;}} 
		}
	}
	
	//Charge the bottons of the left side
	init {
		do init_buttons;
		loop i from: 0 to: grid_height -2 { //grid_width -1
			loop j from: 0 to: grid_width -1 { //grid_height -1
				create road number:1{
					shape <- line ([cell[j,i],cell[j,i+1]]);
				}
				create road number:1{
					shape <- line ([cell[i,j],cell[i+1,j]]);
				}
			}
		}
		the_graph <- as_edge_graph(road);
		
		list<building>  work_buildings <- building  where (each.type="office"); //my_building.type = "office" ///m03
		list<building>  residential_buildings <- building  where (each.type="residential"); ///m03
		list<building>  retail_buildings <- building  where (each.type="retail"); ///m03
		create people number:nb_people{
			speed <- 5.0 # km / # h;
			start_work <- min_work_start + rnd (max_work_start - min_work_start) ;
			end_work <- min_work_end + rnd (max_work_end - min_work_end) ;
			living_place <- one_of(residential_buildings) ; ///m03
			working_place <- one_of(work_buildings) ; ///m03
			objective <- "resting"; ///m03
			location <- any_location_in (living_place); ///m03
		}
		/*** 
		ask people{
			myTarget <- any_location_in (working_place);
		}	*/	
	
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
	
}


species road{
	rgb color<- rgb(0,0,225);
	aspect base_road{
		draw shape color:color;
	}
}

species people skills:[moving]{
	rgb color <- #yellow ;
	building living_place <- nil ;  ///m03
	building working_place <- nil ; ///m03
	int start_work ; ///m03
	int end_work  ;  ///m03
	string objective ; 
	//point myTarget; // I HAVE REMOVE THE <-nil as you have in the Urbam 3D
	point myTarget <- nil;
	reflex time_to_work when: current_hour = start_work and objective = "resting"{
		objective <- "working" ;
		myTarget <- any_location_in (working_place);
	}
		
	reflex time_to_go_home when: current_hour = end_work and objective = "working"{
		objective <- "resting" ;
		myTarget <- any_location_in (living_place); 
	} 
	 
	reflex move when: myTarget != nil {
		do goto target: myTarget on: the_graph ; 
		if myTarget = location {
			myTarget <- nil ;
		}
	}
	/*** 
	reflex move{
		myTarget <- any_location_in (working_place); ///m03
		do goto target:myTarget speed:0.1 on: the_graph;
	  	//do goto target:{0,0} speed:0.1; //The agent should move to any location in one of the cells but it's not moving, why? R:
	}*/
	aspect base{
		draw circle(size_people) color:color;
	}
} //The agent doesnt move in the simulation  and I am doing the same as test.gaml R:


species building {
	string type <- "residential" among: ["retail","residential", "office"];
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
	
	action new_retail {
		if (my_building != nil and (my_building.type = "retail")) {
			return;
		} else {
			if (my_building != nil) {ask my_building {do remove;}}
			create building returns: bds{
				do initialize(myself, "retail");
			}
		}
	}
	
	aspect default{
		draw shape scaled_by (0.5) color: rgb(150,100,100) ;
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
	parameter "Number of people agents" var: nb_people category: "People" ;
	output {
		display map synchronized:true background:blackMirror ? #black :#white toolbar:false type:opengl  draw_env:false //fullscreen:1
		camera_pos: {2160.3206,1631.7982,12043.0275} camera_look_pos: {2160.3206,1631.588,0.0151} camera_up_vector: {0.0,1.0,0.0}{
			//species cell aspect:default;// refresh: on_modification_cells;
			species building;// refresh: on_modification_bds;
			species people aspect: base;
			species road aspect: base_road;
			event mouse_down action:assign_building_type;
		}
				
	    //Bouton d'action
		display action_buton name:"Possible Actions" ambient_light:100 	{
			species button aspect:normal ;
			event mouse_down action:activate_act;    
		}
	}
}
