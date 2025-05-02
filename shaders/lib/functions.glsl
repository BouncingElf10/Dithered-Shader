vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float triangularNoise(vec2 xy) {
    float r1 = fract(sin(dot(xy, vec2(12.9898, 78.233))) * 43758.5453);
    float r2 = fract(sin(dot(xy + vec2(1.0), vec2(12.9898, 78.233))) * 43758.5453);
    return (r1 + r2) * 0.5;
}

float IGN(vec2 pixCoord) {
    const vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
    return fract(magic.z * fract(dot(pixCoord, magic.xy)));
}


float rndShit(vec2 coords, float value, float intensity) {
    vec2 seed = floor(coords);
    float hash = fract(sin(dot(seed, vec2(12.9898, 78.233))) * 43758.5453);

    float error = fract(value * 8.0) - 0.5;
    float diffusedError = error * hash * intensity;

    return value + diffusedError;
}

float halftone(vec2 fragCoord, float value, float frequency) {
    vec2 coord = fragCoord * frequency;
    vec2 nearest = 2.0 * fract(coord) - 1.0;
    float dist = length(nearest);
    return step(dist, value * 1.414); // sqrt(2)
}