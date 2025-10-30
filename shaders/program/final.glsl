/////////////////////////////////////
// Complementary Shaders by EminGT //
// Spooklementary edit by SpacEagle17
/////////////////////////////////////

//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

noperspective in vec2 texCoord;

//Pipeline Constants//
#include "/lib/pipelineSettings.glsl"

//Common Variables//
vec2 view = vec2(viewWidth, viewHeight);

#if defined MC_ANISOTROPIC_FILTERING || COLORED_LIGHTING > 0 || WORLD_SPACE_REFLECTIONS > 0 && COLORED_LIGHTING == 0
    #define ANY_ERROR_MESSAGE
#endif

#ifdef MC_ANISOTROPIC_FILTERING
    #define OPTIFINE_AF_ERROR
#endif

#if COLORED_LIGHTING > 0 && !defined IS_IRIS
    #define OPTIFINE_ACT_ERROR
#endif

#if COLORED_LIGHTING > 0 && defined MC_OS_MAC
    #define APPLE_ACT_ERROR
#endif

#if COLORED_LIGHTING > 0
    #define COORDINATES_ACT_ERROR
    #define SHADOWDISTANCE_ACT_ERROR
#endif

#if WORLD_SPACE_REFLECTIONS > 0 && COLORED_LIGHTING == 0
    #define WSR_MISSING_ACT_ERROR
#endif

//Common Functions//
#if IMAGE_SHARPENING > 0
    vec2 viewD = 1.0 / vec2(viewWidth, viewHeight);

    vec2 sharpenOffsets[4] = vec2[4](
        vec2( viewD.x,  0.0),
        vec2( 0.0,  viewD.x),
        vec2(-viewD.x,  0.0),
        vec2( 0.0, -viewD.x)
    );

    void SharpenImage(inout vec3 color, vec2 texCoordM) {
        #ifdef TAA
            float sharpenMult = IMAGE_SHARPENING;
        #else
            float sharpenMult = IMAGE_SHARPENING * 0.5;
        #endif
        float mult = 0.0125 * sharpenMult;
        color *= 1.0 + 0.05 * sharpenMult;

        for (int i = 0; i < 4; i++) {
            color -= texture2D(colortex3, texCoordM + sharpenOffsets[i]).rgb * mult;
        }
    }
#endif

float retroNoise (vec2 noise){
	return fract(sin(dot(noise.xy,vec2(10.998,98.233)))*12433.14159265359);
}

#define ANY_ERROR_MESSAGE

//Includes//
#ifdef ANY_ERROR_MESSAGE
    #include "/lib/textRendering/textRenderer.glsl"

    void beginTextM(int textSize, vec2 offset) {
        float scale = 860;
        beginText(ivec2(vec2(scale * viewWidth / viewHeight, scale) * texCoord) / textSize, ivec2(0 + offset.x, scale / textSize - offset.y));
        text.bgCol = vec4(0.0);
    }
#endif

//Program//
void main() {
    vec2 texCoordM = texCoord;


    if (isTimeEventActive(5, 7, 3)) { // screen random scrolling up and down and stuttering
        float scrollSpeed = 2.0;
        float stutterSpeed = 0.2;
        float scroll   = (1.0 - step(retroNoise(vec2(frameTimeCounter * 0.00002, 8.0)), 0.9)) * scrollSpeed;
        float stutter  = (1.0 - step(retroNoise(vec2(frameTimeCounter * 0.00005, 9.0)), 0.8)) * stutterSpeed;
        float stutter2 = (1.0 - step(retroNoise(vec2(frameTimeCounter * 0.00003, 5.0)), 0.7)) * stutterSpeed;
        float verticalOffset = sin(frameTimeCounter) * scroll + stutter * stutter2;
        texCoordM.y = mod(texCoordM.y + verticalOffset, 1.10);
    }

    #ifdef UNDERWATER_DISTORTION
        if (isEyeInWater == 1)
            texCoordM += WATER_REFRACTION_INTENSITY * 0.00035 * sin((texCoord.x + texCoord.y) * 25.0 + frameTimeCounter * 3.0);
    #endif

    vec3 color = texture2D(colortex3, texCoordM).rgb;

    #if CHROMA_ABERRATION > 0 || defined PLAYER_MOOD_EFFECTS && defined OVERWORLD
        vec2 scale = vec2(1.0, viewHeight / viewWidth);
        vec2 aberration = (texCoordM - 0.5) * (2.0 / vec2(viewWidth, viewHeight)) * scale * max(CHROMA_ABERRATION, playerMood * 8.5);
        color.rb = vec2(texture2D(colortex3, texCoordM + aberration).r, texture2D(colortex3, texCoordM - aberration).b);
    #endif

    #if IMAGE_SHARPENING > 0
        SharpenImage(color, texCoordM);
    #endif

    /*ivec2 boxOffsets[8] = ivec2[8](
        ivec2( 1, 0),
        ivec2( 0, 1),
        ivec2(-1, 0),
        ivec2( 0,-1),
        ivec2( 1, 1),
        ivec2( 1,-1),
        ivec2(-1, 1),
        ivec2(-1,-1)
    );

    for (int i = 0; i < 8; i++) {
        color = max(color, texelFetch(colortex3, texelCoord + boxOffsets[i], 0).rgb);
    }*/

    #ifdef OPTIFINE_AF_ERROR
        #include "/lib/textRendering/error_optifine_af.glsl"
    #elif defined OPTIFINE_ACT_ERROR
        #include "/lib/textRendering/error_optifine_act.glsl"
    #elif defined APPLE_ACT_ERROR
        #include "/lib/textRendering/error_apple_act.glsl"
    #elif defined WSR_MISSING_ACT_ERROR
        #include "/lib/textRendering/error_wsr_missing_act.glsl"
    #else
        #ifdef COORDINATES_ACT_ERROR
            ivec2 absCameraPositionIntXZ = abs(cameraPositionInt.xz);
            if (max(absCameraPositionIntXZ.x, absCameraPositionIntXZ.y) > 8388550) {
                #include "/lib/textRendering/error_coordinates_act.glsl"
            }
        #endif
        #ifdef SHADOWDISTANCE_ACT_ERROR
            if (COLORED_LIGHTING_INTERNAL > shadowDistance*2) {
                #include "/lib/textRendering/error_shadowdistance_act.glsl"
            }
        #endif
    #endif

    #ifdef VIGNETTE_R
        vec2 texCoordMin = texCoordM.xy - 0.5;
        float vignette = 1.0 - dot(texCoordMin, texCoordMin) * (1.0 - GetLuminance(color));
        color *= vignette;
    #endif

    #if defined PLAYER_MOOD_EFFECTS && defined OVERWORLD
        float maxStaticStrength = 0.50;
        float minStaticStrength = 0.30;
        const float staticSpeed = 10.0;

        vec2 fractStaticCoord = fract(texCoord * fract(sin(frameTimeCounter * staticSpeed)));

        maxStaticStrength = clamp(sin(frameTimeCounter * 0.5), minStaticStrength, maxStaticStrength);

        vec3 staticColor = vec3(retroNoise(fractStaticCoord)) * maxStaticStrength;
        float staticIntensity = smoothstep(0.95, 1.0, playerMood) * 0.45;
        color += mix(vec3(0.0), staticColor, staticIntensity);
    #endif

    float dither = texture2DLod(noisetex, texCoord * view / 128.0, 0.0).b;
    color += vec3((dither - 0.25) / 128.0);

    color.rgb = mix(color.rgb, color.rgb * GetLuminance(color), 0.60);


    // beginTextM(2, vec2(5));
    // text.fpPrecision = 6;
    // printFloat(fuzzyOr(darknessFactor, (1.0 - eyeBrightnessM)));
    // endText(color.rgb);

    // color.rgb = mix(color.rgb, vec3(GetLuminance(color)), 0.15);

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

noperspective out vec2 texCoord;

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

//Program//
void main() {
    gl_Position = ftransform();
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif