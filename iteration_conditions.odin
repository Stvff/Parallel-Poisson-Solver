package pps

simplest_iter_condition :: proc(phi: ^Grid, i: int) -> bool {
	iteration_limit :: 3000
	return i < iteration_limit
}

settable_iteration_limit := 0
settable_iter_condition :: proc(phi: ^Grid, i: int) -> bool {
	return i < settable_iteration_limit
}

conv_prev_phi: ^Grid
conv_first := true
convergence_iter_condition :: proc(phi: ^Grid, i: int) -> bool {
	err_target :: 1e-6
	iteration_limit :: 10_000_000
	if conv_first {
		conv_prev_phi = new(Grid) if conv_prev_phi == nil else conv_prev_phi
		copy(conv_prev_phi[:], phi[:])
		conv_first = false
		return true
	}
	max_err := float(0)
	#no_bounds_check for row in 0..<gsy do for col in 0..<gsx {
		max_err = max(max_err, abs(conv_prev_phi[row][col] - phi[row][col]))
	}
	copy(conv_prev_phi[:], phi[:])
	condition := i > iteration_limit || max_err > err_target
	if !condition do conv_first = true
	return condition
}

et_prev_phi: ^Grid
et_first := true
et_errors := make([dynamic]float)
errortracking_iter_condition :: proc(phi: ^Grid, i: int) -> bool {
	err_target :: 1e-6
	iteration_limit :: 10_000_000
	if et_first {
		et_prev_phi = new(Grid) if et_prev_phi == nil else et_prev_phi
		copy(et_prev_phi[:], phi[:])
		clear(&et_errors)
		et_first = false
		return true
	}
	max_err := float(0)
	#no_bounds_check for row in 0..<gsy do for col in 0..<gsx {
		max_err = max(max_err, abs(et_prev_phi[row][col] - phi[row][col]))
	}
	copy(et_prev_phi[:], phi[:])
	append(&et_errors, max_err)
	condition := i > iteration_limit || max_err > err_target
	if !condition do et_first = true
	return condition
}
