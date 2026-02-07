// Blue light filter shader - reduces eye strain at night
// Source this in hyprland.conf with: decoration { screen_shader = path }

precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

const float temperature = 3500.0;
const float temperatureStrength = 1.0;

#define WithQuickAndDirtyLuminancePreservation

vec3 colorTemperatureToRGB(float temp) {
    temp = temp / 100.0;
    vec3 color;
    if (temp <= 66.0) {
        color.r = 255.0;
        color.g = temp - 2.0;
        color.g = -155.25485562709179 - 0.44596950469579133 * color.g + 104.49216199393888 * log(color.g);
    } else {
        color.r = temp - 55.0;
        color.r = 351.97690566805693 + 0.114206453784165 * color.r - 40.25366309332127 * log(color.r);
        color.g = temp - 50.0;
        color.g = 325.4494125711974 + 0.07943456536662342 * color.g - 28.0852963507957 * log(color.g);
    }
    if (temp >= 66.0)
        color.b = 255.0;
    else if (temp <= 19.0)
        color.b = 0.0;
    else {
        color.b = temp - 10.0;
        color.b = -254.76935184120902 + 0.8274096064007395 * color.b + 115.67994401066147 * log(color.b);
    }
    return clamp(color / 255.0, 0.0, 1.0);
}

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);
    vec3 nightColor = colorTemperatureToRGB(temperature);
    #ifdef WithQuickAndDirtyLuminancePreservation
    float luma = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    vec3 corrected = nightColor * luma;
    pixColor.rgb = mix(pixColor.rgb, corrected, temperatureStrength);
    #else
    pixColor.rgb = mix(pixColor.rgb, pixColor.rgb * nightColor, temperatureStrength);
    #endif
    gl_FragColor = pixColor;
}
