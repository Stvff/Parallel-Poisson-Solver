package pps

/* dirichlet */
charged_plate_on_top :: proc(phi: ^Grid) {
	phi[0] = 10 /* potential */
	phi[gsy-1] = 0
	#no_bounds_check for row in 1..<gsy-1 {
		/* perfect conductors */
		phi[row][0] = 0
		phi[row][gsx-1] = 0
	}
}

/* Von Neumann */
flow_from_top_to_bottom :: proc(phi: ^Grid) {
	phi[0] = 20
	phi[gsy-1] = 0
	#no_bounds_check for row in 1..<gsy-1 {
		/* no outflow */
		phi[row][0] = phi[row][1]
		phi[row][gsx-1] = phi[row][gsx-2]
	}
}
