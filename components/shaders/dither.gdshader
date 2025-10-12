shader_type canvas_item;

uniform sampler2D u_dither_texture : repeat_enable, filter_nearest;
uniform sampler2D u_palette_texture : filter_nearest;

uniform int u_bit_depth : hint_range(2, 256, 1) = 256;
uniform float u_contrast : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float u_offset : hint_range(0.0, 1.0, 0.1) = 0.0;
uniform int u_pixel_size : hint_range(1, 16, 1) = 1;

const vec3 BT709 = vec3(0.2126, 0.7152, 0.0722);

float get_channel_grayscale(vec4 color)
{
	return BT709.r * color.r + BT709.g * color.g + BT709.b * color.b;
}

void fragment()
{
	// calculate the texture sizes so we can scale uv coordinates for the dither texture and pixelate the main texture
	vec2 main_texture_size = vec2(textureSize(TEXTURE, 0)) / float(u_pixel_size);
	vec2 dither_texture_size = vec2(textureSize(u_dither_texture, 0));

	// calculate sample points on each texture
	vec2 main_texture_uv = floor(UV * main_texture_size) / main_texture_size;
	vec2 dither_uv = floor(UV * main_texture_size) / dither_texture_size;

	// sample/calculate grayscale values at current pixel
	vec4 main_texture_color = texture(TEXTURE, main_texture_uv);
	float main_texture_luminosity = get_channel_grayscale(main_texture_color);
	float dither_texture_channel = texture(u_dither_texture, dither_uv).r;

	// adjust luminosity with contrast and offset
	main_texture_luminosity = (main_texture_luminosity - 0.5 + u_offset) * u_contrast + 0.5;
	main_texture_luminosity = clamp(main_texture_luminosity, 0.0, 1.0);

	// adjust luminosity bit depth
	float bits = float(u_bit_depth);
	main_texture_luminosity = floor(main_texture_luminosity * bits) / bits;

	// get the palette texture size mapped so it is 1px high (so the x value however many colour bands there are)
	ivec2 palette_size = textureSize(u_palette_texture, 0);
	palette_size /= palette_size.y;
	float palette_x = float(palette_size.x) - 1.0; // colour boundaries is 1 less than the number of colour bands
	float palette_texel_size = 1.0 / palette_x; // the size of one colour boundary

	main_texture_luminosity = max(main_texture_luminosity - 0.00001, 0.0); // makes sure our floor calculation below behaves when lum == 1.0
	float main_texture_luminosity_lower = floor(main_texture_luminosity * palette_x) * palette_texel_size;
	float main_texture_luminosity_upper = (floor(main_texture_luminosity * palette_x) + 1.0) * palette_texel_size;
	float main_texture_luminosity_scaled = main_texture_luminosity * palette_x - floor(main_texture_luminosity * palette_x); // calculates where lum lies between the upper and lower bound

	// map the dither texture onto the screen
	ivec2 noise_size = textureSize(u_dither_texture, 0);
	vec2 inv_noise_size = vec2(1.0 / float(noise_size.x), 1.0 / float(noise_size.y));
	vec2 noise_uv = UV * inv_noise_size * vec2(float(main_texture_size.x), float(main_texture_size.y));
	float threshold = texture(u_dither_texture, noise_uv).r;

	// adjust the dither slightly so min and max aren't quite at 0.0 and 1.0
	// otherwise we wouldn't get fullly dark and fully light dither patterns at lum 0.0 and 1.0
	threshold = threshold * 0.99 + 0.005;

	// the lower main_texture_luminosity_scaled is, the fewer pixels will be below the dither threshold, and thus will use the lower bound colour, and vice-versa
	float ramp_value = main_texture_luminosity_scaled < threshold ? 0.0f : 1.0f;

	// sample at the lower bound colour if ramp_val is 0.0, upper bound colour if 1.0
	float palette_sample = mix(main_texture_luminosity_lower, main_texture_luminosity_upper, ramp_value);
	vec3 final_palette_color = texture(u_palette_texture, vec2(palette_sample, 0.5)).rgb;

	// return the final colour!
	COLOR.rgb = final_palette_color;
}
