#setdep @previous|all@

set N     @node@
set NODE n910
set OUTPUT /home/kasm-user/Desktop/Work/TransportModels/
set PNGOUT 0-png_out/

for {set i 0} {$i < 101} {incr i} {
	set aux [expr $i + 1]
	if {$i < 10} {
		load_file $OUTPUT$NODE\_000$i\_nmos1_des.tdr -fod
		create_plot -dataset $NODE\_000$i\_nmos1_des
		if {$i == 0} {
			set DATASETNAME $NODE\_000$i\_nmos1_des
		} else {			 
			set DATASETNAME $NODE\_000$i\_nmos1_des
		}
	} else {
		if {$i < 100} {
			load_file $OUTPUT$NODE\_00$i\_nmos1_des.tdr -fod
			create_plot -dataset $NODE\_00$i\_nmos1_des
			set DATASETNAME $NODE\_00$i\_nmos1_des
		} else {
			if {$i < 1000} {
				load_file $OUTPUT$NODE\_0$i\_nmos1_des.tdr -fod
				create_plot -dataset $NODE\_0$i\_nmos1_des
				set DATASETNAME $NODE\_0$i\_nmos1_des
			} else {
				load_file $OUTPUT$NODE\_$i\_nmos1_des.tdr -fod
				create_plot -dataset $NODE\_$i\_nmos1_des
				set DATASETNAME $NODE\_$i\_nmos1_des
				}
		}
	}

	set PLOTNAME Plot_$DATASETNAME
	select_plots $PLOTNAME
	set_plot_prop -plot $PLOTNAME -hide_title
	set_axis_prop -plot $PLOTNAME -axis x -title "X (um)"
	set_axis_prop -plot $PLOTNAME -axis y -title "Y (um)"
	zoom_plot -plot $PLOTNAME -window {0.2 -0.35 -0.2 0.35}
	set_material_prop {DepletionRegion} -plot $PLOTNAME -geom $DATASETNAME -on
	#set_field_prop ImpactIonization -plot $PLOTNAME -geom $DATASETNAME -show_bands -max 5e+30 -max_fixed -min 1e+12 -min_fixed
	#set_field_prop hDensity -plot $PLOTNAME -geom $DATASETNAME -show_bands -max 5e+18 -max_fixed -min 1e+8 -min_fixed
	set_field_prop ElectrostaticPotential -plot $PLOTNAME -geom $DATASETNAME -show_bands -max 4.1 -max_fixed -min -0.45 -min_fixed
	
	set_legend_prop -plot $PLOTNAME -position {0.75 0.95} -size {0.25 0.3}
	
	set PNGNAME $OUTPUT$PNGOUT$NODE\_$i.png
	export_view $PNGNAME -plots $PLOTNAME -format png
	remove_plots $PLOTNAME
	remove_datasets $DATASETNAME

}
