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

import "core:fmt"
import "vendor:stb/image"
