//
//    __ __  __  __  ___    ____    __
//   |  V  |/  \| _\| __|   |  \ `v' /
//   | \_/ | /\ | v | _|    | -<`. .'
//   |_| |_|_||_|__/|___|   |__/ !_!
//
//    ____                         _             ______ _  __ __  ___
//   |  _ \                       (_)           |  ____| |/ _/_ |/ _ \
//   | |_) | ___  _   _ _ __   ___ _ _ __   __ _| |__  | | |_ | | | | |
//   |  _ < / _ \| | | | '_ \ / __| | '_ \ / _` |  __| | |  _|| | | | |
//   | |_) | (_) | |_| | | | | (__| | | | | (_| | |____| | |  | | |_| |
//   |____/ \___/ \__,_|_| |_|\___|_|_| |_|\__, |______|_|_|  |_|\___/
//
//   Feel free to make changes to any of the code (or steal it)
//
//   Check out more of my work on GitHub, Modrinth, Or Curseforge :)
//

#version 150 compatibility

#include "lib/kernels.glsl"
#include "lib/functions.glsl"
#include "settings.glsl"

in vec2 texCoord;
uniform sampler2D colortex0;
uniform sampler2D colortex4; // Blue Noise

layout(location = 0) out vec4 fragColor;

void main() {
    ivec2 resolution = textureSize(colortex0, 0);
    vec2 pixelSize = 1.0 / vec2(resolution) * SCALE;
    vec2 scaledTexCoord = floor(texCoord / pixelSize) * pixelSize;

    vec4 mainColor = texture(colortex0, scaledTexCoord);
    float brightness = 0.30*mainColor.r + 0.59*mainColor.g + 0.11*mainColor.b;

    float ditherScale = max(SCALE, 0.01);
    if (SCALE == 0.01) { ditherScale = 1; } else { ditherScale = SCALE; }
    if (DITHERING_STYLE == 5) { ditherScale = 1; } else { ditherScale = SCALE; }
    ivec2 pixelCoords = ivec2(texCoord / ditherScale * vec2(resolution));

    vec3 dithered;
    float threshold;
    float layers = POSTERIZING_AMOUNT;
    if (DITHERING_STYLE == 0) {
        if (BAYER_SIZE == 2) {
            threshold = B2(pixelCoords) / 4.0;
        } else if (BAYER_SIZE == 4) {
            threshold = B4(pixelCoords) / 16.0;
        } else if (BAYER_SIZE == 8) {
            threshold = B8(pixelCoords) / 64.0;
        } else if (BAYER_SIZE == 16) {
            threshold = B16(pixelCoords) / 256.0;
        } else if (BAYER_SIZE == 32) {
            threshold = B32(pixelCoords) / 1024.0;
        } else {
            threshold = 0.5; // Default fallback
        }

        if (BAYER_STYLE == 0) {
            // Monochrome dithering
            dithered = step(threshold, vec3(brightness));
        } else if (BAYER_STYLE == 1) {
            // Per-channel dithering
            dithered = step(threshold, mainColor.rgb);
        } else if (BAYER_STYLE == 2) {
            // Original color dithering
            vec3 color1 = floor(mainColor.rgb * layers) / layers;
            vec3 color2 = ceil(mainColor.rgb * layers) / layers;
            dithered = mix(color1, color2, step(threshold, fract(mainColor.rgb * layers)));
        } else if (BAYER_STYLE == 3) {
            float ditherAdjust = (threshold - 0.5) * (1.0/8.0);
            dithered = mainColor.rgb + vec3(ditherAdjust);
        } else if (BAYER_STYLE == 4) {
            // Hue-preserving dithering
            vec3 hsvColor = rgb2hsv(mainColor.rgb);
            float ditherValue = step(threshold, hsvColor.z);
            hsvColor.z = ditherValue * 1.0;
            dithered = hsv2rgb(hsvColor);
        } else if (BAYER_STYLE == 5) {
            // Smoother gradient dithering
            vec3 color1 = floor(mainColor.rgb * layers) / layers;
            vec3 color2 = ceil(mainColor.rgb * layers) / layers;
            float softThreshold = (threshold - 0.5) * 0.3;
            vec3 fractPart = fract(mainColor.rgb * layers);
            vec3 compare = clamp(fractPart - softThreshold, 0.0, 1.0);
            float noise = fract(sin(dot(vec2(pixelCoords), vec2(12.9898, 78.233))) * 43758.5453) * 0.1 - 0.05;
            compare = clamp(compare + vec3(noise), 0.0, 1.0);
            dithered = mix(color1, color2, smoothstep(0.0, 1.0, compare));
        }
    } else if (DITHERING_STYLE == 1) {
        vec2 noiseCoord = mod(pixelCoords, 256.0) / 256.0; // If using a 256x256 noise texture
        float blueNoise = texture(colortex4, noiseCoord).r;

        // Apply the dithering
        vec3 color1 = floor(mainColor.rgb * layers) / layers;
        vec3 color2 = ceil(mainColor.rgb * layers) / layers;
        dithered = mix(color1, color2, step(blueNoise, fract(mainColor.rgb * layers)));
    } else if (DITHERING_STYLE == 2) {
        float triNoise = triangularNoise(pixelCoords);
        dithered = floor((mainColor.rgb + vec3(triNoise / layers)) * layers) / layers;
    } else if (DITHERING_STYLE == 3) {
        float ignNoise = IGN(pixelCoords);
        vec3 color1 = floor(mainColor.rgb * layers) / layers;
        vec3 color2 = ceil(mainColor.rgb * layers) / layers;
        dithered = mix(color1, color2, step(ignNoise, fract(mainColor.rgb * layers)));
    } else if (DITHERING_STYLE == 4) {
        dithered.r = floor(rndShit(pixelCoords, mainColor.r, 0.8) * layers) / layers;
        dithered.g = floor(rndShit(pixelCoords + vec2(1.7, 5.2), mainColor.g, 0.8) * layers) / layers;
        dithered.b = floor(rndShit(pixelCoords + vec2(3.4, 1.9), mainColor.b, 0.8) * layers) / layers;
    } else if (DITHERING_STYLE == 5) {
        float size = SCALE * 0.02;
        dithered.r = halftone(pixelCoords, mainColor.r, size);
        dithered.g = halftone(pixelCoords + vec2(1.0, 0.0), mainColor.g, size);
        dithered.b = halftone(pixelCoords + vec2(0.0, 1.0), mainColor.b, size);
    }

    fragColor = vec4(dithered, fragColor.a);

    //fragColor = vec4(vec3(pixelCoords.x, pixelCoords.y, 0), 1);
    //fragColor = texture(colortex0, scaledTexCoord);
}
