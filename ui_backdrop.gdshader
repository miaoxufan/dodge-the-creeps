shader_type canvas_item;
void fragment() {
 vec2 p = UV;
 vec3 col = mix(vec3(0.98,0.95,0.87), vec3(0.94,0.89,0.79), p.y);
 float glow = exp(-7.0 * length((p-vec2(0.72,0.43))*vec2(1.2,1.0)));
 col -= vec3(0.0,0.1,0.15)*glow;
 vec2 grid = abs(fract(p*vec2(40.0,24.0))-0.5);
 float line = step(0.487,max(grid.x,grid.y));
 col -= vec3(0.08)*line*0.12;
 vec2 q = (p-vec2(0.76,0.46))*vec2(1.7778,1.0);
 float r = length(q);
 float rings = exp(-abs(r-0.26)*650.0)+0.4*exp(-abs(r-0.31)*650.0);
 float sector = 0.45+0.55*sin(atan(q.y,q.x)*6.0+TIME*0.22);
 col -= vec3(0.0,0.16,0.2)*rings*sector;
 float stars = step(0.996,fract(sin(dot(floor(p*vec2(240.0,135.0)),vec2(12.9898,78.233)))*43758.5453));
 col -= vec3(0.018,0.013,0.009)*stars;
 COLOR = vec4(col,1.0);
}
