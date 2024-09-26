package pps

float :: f64

physical_width :float: 1 /* meter */

gsx :: 323*5 /* cells */
gsy :: 271*5 /* cells */

ds :: physical_width/gsx /* m/c */
ds2 :: ds*ds

Grid :: [gsy][gsx]float

Boundary_proc :: #type proc(phi: ^Grid)
Should_iter_proc :: #type proc(phi: ^Grid, i: int) -> bool
Poisson_solver_proc :: #type proc(phi, f: ^Grid, boundary: Boundary_proc, should_iter: Should_iter_proc) -> int

main :: proc() {
	phi := new(Grid)
	f := new(Grid)
	png_to_grid(f, "typesetted math/logo.png")
//	circle_in_middle(f)
//	boundary := charged_plate_on_top
//	boundary := flow_from_topleft_to_bottomright
	boundary := perfect_conductor
	iter_condition := convergence_iter_condition

	solvers := [?]Poisson_solver_proc{
		kernel_solver_family,
//		reference_successive_overrelaxation,
//		reference_gauss_seidel,
//		reference_jacobi,
	}
	solver_names := [?]string{
		"kernel-solver",
//		"SOR",
//		"Gauss-Seidel",
//		"Jacobi",
	}
	#assert(len(solvers) == len(solver_names))

	for solver, i in solvers {
		phi^ = 0

///		now := time.now()
//		iters := solver(phi, f, boundary, iter_condition)
//		fmt.printf("%s took %.3f seconds and %v iterations\n", solver_names[i], time.duration_seconds(time.since(now)), iters)
//		linear_rgb_image(fmt.tprintf("solved fields/%s.png\x00", solver_names[i]), phi)
		gridlines_with_background_image(fmt.tprintf("solved fields/%s.png\x00", solver_names[i]), f, no_outflow, convergence_iter_condition)

//		real := laplace(phi)
//		defer free(real)
//		linear_rgb_image(fmt.tprintf("solution deviations/deviation_%s.png\x00", solver_names[i]), real)

		print()
		free_all(context.temp_allocator)
	}
}

laplace :: proc(phi: ^Grid) -> ^Grid {
	f := new(Grid)
	#no_bounds_check for row in 2..<gsy-2 do for col in 2..<gsx-2 {
		centre := 2*phi[row][col]
		ddiff_x := phi[row][col-1] + phi[row][col+1] - centre
		ddiff_y := phi[row-1][col] + phi[row+1][col] - centre
		f[row][col] = (ddiff_x + ddiff_y)/ds2
	}
	return f
}

deviation_from_laplace :: proc(phi, f: ^Grid) -> ^Grid {
	error := new(Grid)
	#no_bounds_check for row in 2..<gsy-2 do for col in 2..<gsx-2 {
		centre := 2*phi[row][col]
		ddiff_x := (phi[row][col-1] + phi[row][col+1] - centre)
		ddiff_y := (phi[row-1][col] + phi[row+1][col] - centre)
		error[row][col] = (ddiff_x + ddiff_y) - f[row][col]*ds2
	}
	return error
}

circle_in_middle :: proc(grid: ^Grid) {
	density :: float(-0.5) /* property/m^2 */
	radius :: 20
	for row in 0..<gsy-1 do for col in 0..<gsx-1 {
		x := col - gsx/2
		y := row - gsy/2
		if x*x + y*y < radius*radius {
			grid[row][col] = density/ds2 /* p*c^2/m^2 */
		}
	}
}

png_to_grid :: proc(grid: ^Grid, name: string) {
	density :: float(20) /* property/m^2 */
	imag, err := png.load(name)
	assert(err == nil)
	defer image.destroy(imag)
	data := imag.pixels.buf
	for row in 0..<gsy-1 do for col in 0..<gsx-1 {
		x := col*imag.width/gsx
		y := row*imag.height/gsy
		i := (x + y*imag.width)*imag.channels
		grid[row][col] = density*float(data[i])/255.0
	}
}


div_of_T :: proc(V: ^Grid) -> ^Grid {
	f := new(Grid)
	#no_bounds_check for row in 2..<gsy-2 do for col in 2..<gsx-2 {
		centre := 2*V[row][col]
		ddiff_x := V[row][col-1] + V[row][col+1] - centre
		ddiff_y := V[row-1][col] + V[row+1][col] - centre
		f[row][col] = (ddiff_x - ddiff_y)/ds2
	}
	return f
}

tau :: math.TAU
print :: fmt.println
import "core:math"
import "core:fmt"
import "core:time"
import "core:image"
import "core:image/png"
