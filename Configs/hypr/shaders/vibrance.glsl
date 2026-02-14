// Vibrance shader - enhances color saturation
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

const float vibrance = 0.25;

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);
    float average = (pixColor.r + pixColor.g + pixColor.b) / 3.0;
    float mx = max(pixColor.r, max(pixColor.g, pixColor.b));
    float amt = (mx - average) * (-vibrance * 3.0);
    pixColor.rgb = mix(pixColor.rgb, vec3(mx), amt);
    gl_FragColor = pixColor;
}
s