;==== H2D filament change ========
;==== 20260116 ===================
M993 A2 B2 C2 ; nozzle cam detection allow status save.
M993 A0 B0 C0 ; nozzle cam detection not allowed.
{if (filament_type[next_extruder] == "PLA") ||  (filament_type[next_extruder] == "PETG")
 ||  (filament_type[next_extruder] == "PLA-CF")  ||  (filament_type[next_extruder] == "PETG-CF")}
	M1015.4 S1 K0 ;disable E air printing detect
{else}
	M1015.4 S0 ;disable E air printing detect
{endif}
M620 S[next_extruder]A ;select AMS by tray index
M1002 gcode_claim_action : 4 ;"changing filament"
M204 S9000 ;set starting acceleration
G1 Z{max_layer_z + 3.0} F1200
M400
M106 P1 S0 ;turn off part cooling fan
M106 P2 S0 ;turn off aux fan
{if toolchange_count == 2}
; get travel path for change filament
;	M620.1 X[travel_point_1_x] Y[travel_point_1_y] F21000 P0
;	M620.1 X[travel_point_2_x] Y[travel_point_2_y] F21000 P1
;	M620.1 X[travel_point_3_x] Y[travel_point_3_y] F21000 P2
{endif}
{if ((filament_type[current_extruder] == "PLA") || (filament_type[current_extruder] == "PLA-CF") || (filament_type[current_extruder] == "PETG")) && (nozzle_diameter[current_extruder] == 0.2)}
	M620.10 A0 F74.8347 L[flush_length] H{nozzle_diameter[current_extruder]} T{flush_temperatures[current_extruder]} P[old_filament_temp] S1
{else}
	M620.10 A0 F{flush_volumetric_speeds[current_extruder]/2.4053*60*0.8} L[flush_length] H{nozzle_diameter[current_extruder]} T{flush_temperatures[current_extruder]} P[old_filament_temp] S1
{endif}
{if ((filament_type[next_extruder] == "PLA") || (filament_type[next_extruder] == "PLA-CF") || (filament_type[next_extruder] == "PETG")) && (nozzle_diameter[next_extruder] == 0.2)}
	M620.10 A1 F74.8347 L[flush_length] H{nozzle_diameter[next_extruder]} T{flush_temperatures[next_extruder]} P[new_filament_temp] S1
{else}
	M620.10 A1 F{flush_volumetric_speeds[next_extruder]/2.4053*60*0.8} L[flush_length] H{nozzle_diameter[next_extruder]} T{flush_temperatures[next_extruder]} P[new_filament_temp] S1
{endif}
{if long_retraction_when_cut}
	M620.11 P1 I[current_extruder] E-{retraction_distance_when_cut} F{max((flush_volumetric_speeds[current_extruder]/2.4053*60), 200)}
{else}
	M620.11 P0 I[current_extruder] E0
{endif}
{if long_retraction_when_ec}
	M620.11 K1 I[current_extruder] R{retraction_distance_when_ec} F{max((flush_volumetric_speeds[current_extruder]/2.4053*60), 200)}
{else}
	M620.11 K0 I[current_extruder] R0
{endif}
M620.15 C{new_filament_temp - filament_cooling_before_tower[next_extruder]}
M628 S1
{if filament_type[current_extruder] == "TPU"}
	M620.11 S0 L0 I[current_extruder] E-{retraction_distances_when_cut[current_extruder]} F{max((flush_volumetric_speeds[current_extruder]/2.4053*60), 200)}
{else}
	{if (filament_type[current_extruder] == "PA") || (filament_type[current_extruder] == "PA-GF")}
		M620.11 S1 L0 I[current_extruder] R4 D2 E-{retraction_distances_when_cut[current_extruder]} F{max((flush_volumetric_speeds[current_extruder]/2.4053*60), 200)}
	{else}
		M620.11 S1 L0 I[current_extruder] R10 D8 E-{retraction_distances_when_cut[current_extruder]} F{max((flush_volumetric_speeds[current_extruder]/2.4053*60), 200)}
	{endif}
{endif}
M629
{if (filament_type[current_extruder] == "TPU" || filament_type[next_extruder] == "TPU") && (old_extruder_variant != "Direct Drive TPU High Flow")}
	M620.11 H2 C331
{else}
	M620.11 H0
{endif}
{if  (old_extruder_variant == "Direct Drive TPU High Flow") && (filament_map[current_extruder] == 2) && (filament_map[next_extruder] == 1)}
;debug log pe:{previous_extruder} ce:{current_extruder} ne:{next_extruder} oev: {old_extruder_variant} nev:{new_extruder_variant}
;debug fm-curr:{filament_map[current_extruder]} fm-next:{filament_map[next_extruder]}
;sw from R2L&TPU kit, travel run a distance for sketch TPU
	G1 X30 Y30 F5000
	M400
	G1 X300 Y30 F5000
	M400
{endif}
T[next_extruder]
;deretract
{if filament_type[next_extruder] == "TPU"}
{else}
	{if (filament_type[next_extruder] == "PA") || (filament_type[next_extruder] == "PA-GF")}
;		VG1 E1 F{max(new_filament_e_feedrate, 200)}
;		VG1 E1 F{max(new_filament_e_feedrate/2, 100)}
	{else}
;		VG1 E4 F{max(new_filament_e_feedrate, 200)}
;		VG1 E4 F{max(new_filament_e_feedrate/2, 100)}
	{endif}
{endif}
; VFLUSH_START
{if flush_length>41.5}
;	VG1 E41.5 F{min(old_filament_e_feedrate,new_filament_e_feedrate)}
;	VG1 E{flush_length-41.5} F{new_filament_e_feedrate}
{else}
;	VG1 E{flush_length} F{min(old_filament_e_feedrate,new_filament_e_feedrate)}
{endif}
SYNC T{ceil(flush_length / 125) * 5}
; VFLUSH_END
M1002 set_filament_type:{filament_type[next_extruder]}
M400
M83
{if next_extruder < 255}
	M620.10 R{new_extruder_retracted_length}
	M628 S0
;	VM109 S[new_filament_temp]
	M629
	M400
;prime_tower_interface
	{if is_prime_tower_interface && filament_tower_interface_purge_volume !=0}
		G150.1
		M620.13 W0 L{filament_tower_interface_purge_volume} T{filament_tower_interface_print_temp} R0.0
	{endif}
;prime_tower_interface
	M983.3 F{filament_max_volumetric_speed[next_extruder]/2.4} A0.4 R{new_extruder_retracted_length}
	M400
	{if wipe_avoid_perimeter}
		G1 Y320 F30000
		G1 X{wipe_avoid_pos_x} F30000
	{endif}
	G1 Y295 F30000
	G1 Y265 F18000
	G1 Z{max_layer_z + 3.0} F3000
	{if layer_z <= (initial_layer_print_height + 0.001)}
		M204 S[initial_layer_acceleration]
	{else}
		M204 S[default_acceleration]
	{endif}
{else}
	G1 X[x_after_toolchange] Y[y_after_toolchange] Z[z_after_toolchange] F12000
{endif}
M621 S[next_extruder]A
M993 A3 B3 C3 ; nozzle cam detection allow status restore.
{if (filament_type[next_extruder]  == "TPU")}
	M1015.3 S1;enable tpu clog detect
{else}
	M1015.3 S0;disable tpu clog detect
{endif}
{if (filament_type[next_extruder] == "PLA") ||  (filament_type[next_extruder] == "PETG")
 ||  (filament_type[next_extruder] == "PLA-CF")  ||  (filament_type[next_extruder] == "PETG-CF")}
	M1015.4 S1 K1 H[nozzle_diameter] ;enable E air printing detect
{else}
	M1015.4 S0 ; disable E air printing detect
{endif}
M620.6 I[next_extruder] W1 ;enable ams air printing detect
M1002 gcode_claim_action : 0
