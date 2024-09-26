package pps

/* dirichlet */
perfect_conductor :: proc(phi: ^Grid) {
	phi[0] = 0
	phi[gsy-1] = 0
	#no_bounds_check for row in 1..<gsy-1 {
		phi[row][0] = 0
		phi[row][gsx-1] = 0
	}
}

charged_plate_on_top :: proc(phi: ^Grid) {
	phi[0] = 10 /* potential */
	phi[gsy-1] = 0
	#no_bounds_check for row in 1..<gsy-1 {
		phi[row][0] = 0
		phi[row][gsx-1] = 0
	}
}

two_charged_plates :: proc(phi: ^Grid) {
	phi[0] = 10 /* potential */
	phi[gsy-1] = 10
	#no_bounds_check for row in 1..<gsy-1 {
		phi[row][0] = 0
		phi[row][gsx-1] = 0
	}
}

/* Von Neumann */
no_outflow :: proc(phi: ^Grid) {
	phi[0] = phi[1]
	phi[gsy-1] = phi[gsy-2]
	#no_bounds_check for row in 1..<gsy-1 {
		phi[row][0] = phi[row][1]
		phi[row][gsx-1] = phi[row][gsx-2]
	}
}

flow_from_top_to_bottom :: proc(phi: ^Grid) {
	phi[0] = 20
	phi[gsy-1] = 0
	#no_bounds_check for row in 1..<gsy-1 {
		phi[row][0] = phi[row][1]
		phi[row][gsx-1] = phi[row][gsx-2]
	}
}

flow_from_topleft_to_bottomright :: proc(phi: ^Grid) {
	phi[0] = phi[1]
	phi[gsy-1] = phi[gsy-2]
	#no_bounds_check for row in 1..<(gsy/2) {
		phi[row][0] = ds*3
		phi[row][gsx-1] = phi[row][gsx-2]
	}
	#no_bounds_check for row in (gsy/2)..<(gsy-1) {
		phi[row][0] = phi[row][1]
		phi[row][gsx-1] = -ds*3
	}
}

no_flow_from_topleft_to_bottomright :: proc(phi: ^Grid) {
	phi[0] = 0
	phi[gsy-1] = 0
	#no_bounds_check for row in 1..<(gsy/2) {
		phi[row][0] = phi[row][1]
		phi[row][gsx-1] = -ds*3
	}
	#no_bounds_check for row in (gsy/2)..<(gsy-1) {
		phi[row][0] = -ds*3
		phi[row][gsx-1] = phi[row][gsx-2]
	}
}

no_flow_left_to_right :: proc(phi: ^Grid) {
	phi[0] = phi[1]
	phi[gsy-1] = phi[gsy-2]
	#no_bounds_check for row in 1..<gsy-1 {
		phi[row][0] = 0
		phi[row][gsx-1] = 0
	}
}
