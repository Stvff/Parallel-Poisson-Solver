package pps

color_map :: proc(f: float) -> [3]u8 {
	colors := [?][3]float{{0, 0, 0}, {0.1, 0, 0.3}, {0.72, 0.25, 0.35}, {0.7, 0.4, 0.35}, {1, 0.9, 0.8}}
	indecs := [?]float{0, 0.12, 0.64, 0.73, 1}
	#assert(len(colors) == len(indecs))
	index := 0
	for p, i in indecs {
		if p > f {
			index = max(0, i - 1)
			break
		}
	}
	scale := (f - indecs[index])/(indecs[index + 1] - indecs[index])
	clr := 255*((1 - scale)*colors[index] + scale*colors[index + 1])
	return {u8(clr.r), u8(clr.g), u8(clr.b)}
}

linear_rgb_image :: proc(name: string, grid: ^Grid) {
	image_data := new([gsy][gsx][4]u8)
	defer free(image_data)

	minv := max(float)
	maxv := min(float)
	for row in grid do for value in row {
		maxv = max(value, maxv)
		minv = min(value, minv)
	}
	fmt.printf("%v: max: %v, min: %v\n", name[:len(name)-1], maxv, minv)
	for row in 0..<gsy do for col in 0..<gsx {
		scale := (grid[row][col]-minv)/(maxv-minv)
		image_data[row][col].rgb = color_map(scale)
		image_data[row][col].a = 255
	}
	image.write_png(transmute(cstring)raw_data(name), gsx, gsy, 4, image_data, size_of(image_data[0]))
}

gridlines_image :: proc(name: string, grid: ^Grid, boundary: Boundary_proc, iter_condition: Should_iter_proc) {
	frequency :float: 15

	image_data := new([gsy][gsx][4]u8)
	L_field := new(Grid)
	lapl_of_L := div_of_T(grid)
	defer {
		free(image_data)
		free(lapl_of_L)
		free(L_field)
	}
	now := time.now()
	iters := reference_successive_overrelaxation(L_field, lapl_of_L, boundary, iter_condition)
	fmt.printf("the L field took %.3f seconds and %v iterations\n", time.duration_seconds(time.since(now)), iters)

	minv := max(float)
	maxv := min(float)
	minL := max(float)
	maxL := min(float)
	for &row, y in grid do for value, x in row {
		maxv = max(value, maxv)
		minv = min(value, minv)
		maxL = max(L_field[y][x], maxL)
		minL = min(L_field[y][x], minL)
	}
	for row in 0..<gsy do for col in 0..<gsx {
		scaleV := (grid[row][col]-minv)/(maxv-minv)
		scaleL := (L_field[row][col]-minL)/(maxL-minL)
		scaleV = 1 if abs(0.5 - frequency*math.mod(scaleV, 1/frequency)) < 0.05 else 0
		scaleL = 1 if abs(0.5 - frequency*math.mod(scaleL, 1/frequency)) < 0.05 else 0
	//	scaleV = 0.5 + 0.5*math.cos(tau*frequency*scaleV)
	//	scaleL = 0.5 + 0.5*math.cos(tau*frequency*scaleL)

		image_data[row][col].rgb = u8( 255*min(1, scaleV + scaleL) )
		image_data[row][col].a = 255
	}
	image.write_png(transmute(cstring)raw_data(name), gsx, gsy, 4, image_data, size_of(image_data[0]))
}


sinusoid_mono_image :: proc(name: string, grid: ^Grid) {
	frequency :float: 10

	image_data := new([gsy][gsx][4]u8)
	defer free(image_data)

	minv := max(float)
	maxv := min(float)
	for row in grid do for value in row {
		maxv = max(value, maxv)
		minv = min(value, minv)
	}
	fmt.printf("%v: max: %v, min: %v\n", name[:len(name)-1], maxv, minv)
	for row in 0..<gsy do for col in 0..<gsx {
		scale := (grid[row][col]-minv)/(maxv-minv)
		image_data[row][col].rgb = u8( 255*(0.5 + 0.5*math.cos(tau*frequency*scale)) )
		image_data[row][col].a = 255
	}
	image.write_png(transmute(cstring)raw_data(name), gsx, gsy, 4, image_data, size_of(image_data[0]))
}

linear_mono_image :: proc(name: string, grid: ^Grid) {
	image_data := new([gsy][gsx][4]u8)
	defer free(image_data)

	minv := max(float)
	maxv := min(float)
	for row in grid do for value in row {
		maxv = max(value, maxv)
		minv = min(value, minv)
	}
	fmt.printf("%v: max: %v, min: %v\n", name[:len(name)-1], maxv, minv)
	for row in 0..<gsy do for col in 0..<gsx {
		image_data[row][col].rgb = u8(255*(grid[row][col]-minv)/(maxv-minv))
		image_data[row][col].a = 255
	}
	image.write_png(transmute(cstring)raw_data(name), gsx, gsy, 4, image_data, size_of(image_data[0]))
}

hot_cold_image :: proc(name: string, grid: ^Grid) {
	image_data := new([gsy][gsx][4]u8)
	defer free(image_data)

	minv := max(float)
	maxv := min(float)
	for row in grid do for value in row {
		maxv = max(value, maxv)
		minv = min(value, minv)
	}
	fmt.printf("%v: max: %v, min: %v\n", name[:len(name)-1], maxv, minv)
	for row in 0..<gsy do for col in 0..<gsx {
		image_data[row][col].r = u8(255*abs(max(0, grid[row][col])/maxv))
		image_data[row][col].b = u8(255*abs(min(0, grid[row][col])/minv))
		image_data[row][col].a = 255
	}
	image.write_png(transmute(cstring)raw_data(name), gsx, gsy, 4, image_data, size_of(image_data[0]))
}

import "core:time"
import "core:math"
import "core:fmt"
import "vendor:stb/image"
