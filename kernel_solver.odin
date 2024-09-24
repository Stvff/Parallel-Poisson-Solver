package pps

// Kernel :: [2][2]uint {
// 	{1, 4},
// 	{3, 2}
// }

// Kernel :: [3][3]uint{
// 	{7, 8, 9},
// 	{4, 5, 6},
// 	{1, 2, 3},
// }

// Kernel :: [3][3]uint{
// 	{1, 3, 2},
// 	{3, 5, 4},
// 	{2, 4, 1},
// }

Kernel :: [2][2]uint {
	{1, 0},
	{0, 1}
}

ksy :: len(Kernel)
ksx :: len(Kernel[0])

kernel := Kernel

kernel_solver_family :: proc(phi, f: ^Grid, boundary: Boundary_proc, should_iter: Should_iter_proc) -> int {
	relaxation_factor_a :: float(2 - tau/float(max(gsx, gsy)))
	relaxation_factor_b :: 1 - relaxation_factor_a

	from := max(uint)
	upto := min(uint)
	for row in kernel do for n in row {
		upto = max(n, upto)
		from = min(n, from)
	}

	boundary(phi)
	i := 0
	for ;should_iter(phi, i); i += 1 {
		for step in from..=upto {
//			print(step)
			#no_bounds_check for row in 1..<gsy-1 do for col in 1..<gsx-1 {
				if kernel[row%ksy][col%ksx] != step do continue
				avg := (phi[row+1][col]\
				        + phi[row][col-1] + phi[row][col+1]\
				        + phi[row-1][col] - ds2*f[row][col])/4
				phi[row][col] = relaxation_factor_b*phi[row][col] + relaxation_factor_a*avg
			}
		}
		boundary(phi)
	}
	return i
}
