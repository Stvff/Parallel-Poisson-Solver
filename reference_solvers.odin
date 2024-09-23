package pps

/* TODO: reference_successive_overrelaxation_parity_ordering_cpu */

reference_jacobi :: proc(phi, f: ^Grid, boundary: Boundary_proc, should_iter: Should_iter_proc) -> int {
	second_phi := new(Grid)
	defer free(second_phi)
	phi_a := phi
	phi_b := second_phi

	boundary(phi)
	i := 0
	for ;should_iter(phi_a, i); i += 1 {
		#no_bounds_check for row in 1..<gsy-1 do for col in 1..<gsx-1 {
			orth_sum := phi_a[row+1][col]\
			          + phi_a[row][col-1] + phi_a[row][col+1]\
			          + phi_a[row-1][col] - ds2*f[row][col]
			phi_b[row][col] = orth_sum/4
		}
		boundary(phi_b)
		temp := phi_b
		phi_b = phi_a
		phi_a = temp
	}
	copy(phi[:], phi_a[:])
	return i
}

reference_gauss_seidel :: proc(phi, f: ^Grid, boundary: Boundary_proc, should_iter: Should_iter_proc) -> int {
	boundary(phi)
	i := 0
	for ;should_iter(phi, i); i += 1 {
		#no_bounds_check for row in 1..<gsy-1 do for col in 1..<gsx-1 {
			orth_sum := phi[row+1][col]\
			          + phi[row][col-1] + phi[row][col+1]\
			          + phi[row-1][col] - ds2*f[row][col]
			phi[row][col] = orth_sum/4
		}
		boundary(phi)
	}
	return i
}

reference_successive_overrelaxation :: proc(phi, f: ^Grid, boundary: Boundary_proc, should_iter: Should_iter_proc) -> int {
	relaxation_factor_a :: float(2 - 2*math.PI/float(max(gsx, gsy)))
	relaxation_factor_b :: 1 - relaxation_factor_a

	boundary(phi)
	i := 0
	for ;should_iter(phi, i); i += 1 {
		#no_bounds_check for row in 1..<gsy-1 do for col in 1..<gsx-1 {
			avg := (phi[row+1][col]\
			        + phi[row][col-1] + phi[row][col+1]\
			        + phi[row-1][col] - ds2*f[row][col])/4
			phi[row][col] = relaxation_factor_b*phi[row][col] + relaxation_factor_a*avg
		}
		boundary(phi)
	}
	return i
}

import "core:math"
