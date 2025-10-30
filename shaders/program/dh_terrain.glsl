/////////////////////////////////////
// Complementary Shaders by EminGT //
// Spooklementary edit by SpacEagle17
/////////////////////////////////////

//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

flat in int mat;

in vec2 lmCoord;

flat in vec3 upVec, sunVec, northVec, eastVec;
in vec3 normal;
in vec3 playerPos;

in vec4 glColor;

//Pipeline Constants//

//Common Variables//
float NdotU = dot(normal, upVec);
float NdotUmax0 = max(NdotU, 0.0);
float SdotU = dot(sunVec, upVec);
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;
float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
float shadowTime = shadowTimeVar2 * shadowTimeVar2;

vec2 lmCoordM = lmCoord;

mat4 gbufferProjection = dhProjection;
mat4 gbufferProjectionInverse = dhProjectionInverse;

#ifdef OVERWORLD
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    vec3 lightVec = sunVec;
#endif

//Includes//
#include "/lib/util/spaceConversion.glsl"
#include "/lib/util/dither.glsl"

#ifdef ATM_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif

#ifdef TAA
    #include "/lib/antialiasing/jitter.glsl"
#endif

#define GBUFFERS_TERRAIN
    #include "/lib/lighting/mainLighting.glsl"
#undef GBUFFERS_TERRAIN

#ifdef SNOWY_WORLD
    #include "/lib/materials/materialMethods/snowyWorld.glsl"
#endif

//Program//
void main() {
    vec4 color = vec4(glColor.rgb, 1.0);

    vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
    #ifdef TAA
        vec3 viewPos = ScreenToView(vec3(TAAJitter(screenPos.xy, -0.5), screenPos.z));
    #else
        vec3 viewPos = ScreenToView(screenPos);
    #endif
    float lViewPos = length(playerPos);
    vec3 nViewPos = normalize(viewPos);
    float VdotU = dot(nViewPos, upVec);
    float VdotS = dot(nViewPos, sunVec);

    float dither = Bayer64(gl_FragCoord.xy);
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif

    #ifdef ATM_COLOR_MULTS
        atmColorMult = GetAtmColorMult();
    #endif

    bool noSmoothLighting = false, noDirectionalShading = false, noVanillaAO = false, centerShadowBias = false;
    int subsurfaceMode = 0;
    float smoothnessG = 0.0, smoothnessD = 0.0, highlightMult = 1.0, emission = 0.0, snowFactor = 1.0, snowMinNdotU = 0.0, lavaNoiseIntensity = LAVA_NOISE_INTENSITY * 0.1;
    vec3 normalM = normal, geoNormal = normal, shadowMult = vec3(1.0);    
    vec3 worldGeoNormal = normalize(ViewToPlayer(geoNormal * 10000.0));
    float purkinjeOverwrite = 0.0;
    float dhSSAOBrightnessBoost = 1.05;
    
    if (mat == DH_BLOCK_LEAVES) {
        #include "/lib/materials/specificMaterials/terrain/leaves.glsl"
        if(isTimeEventActive(3, 5.0, 1)) discard;
        dhSSAOBrightnessBoost = 1.35; // make brighter to compensate SSAO
    } else if (mat == DH_BLOCK_GRASS) {
        smoothnessG = pow2(color.g) * 0.85;
        dhSSAOBrightnessBoost = mix(1.0, 1.2, 1.0 - clamp01(dot(worldGeoNormal, ViewToPlayer(upVec)))); // only make brighter on the sides
    } else if (mat == DH_BLOCK_ILLUMINATED) {
        dhSSAOBrightnessBoost = 1.2;
        emission = 2.5;
    } else if (mat == DH_BLOCK_LAVA) {
        emission = 1.5;
        dhSSAOBrightnessBoost = 0.9;
    }

    #if SSAO_QUALI > 0
        color.rgb *= dhSSAOBrightnessBoost;
    #endif

    #ifdef SNOWY_WORLD
        DoSnowyWorld(color, smoothnessG, highlightMult, smoothnessD, emission,
                     playerPos, lmCoord, snowFactor, snowMinNdotU, NdotU, subsurfaceMode);
    #endif

    vec3 playerPosAlt = ViewToPlayer(viewPos); // AMD has problems with vertex playerPos and DH
    float lengthCylinder = max(length(playerPosAlt.xz), abs(playerPosAlt.y));
    highlightMult *= 0.5 + 0.5 * pow2(1.0 - smoothstep(far, far * 1.5, lengthCylinder));
    color.a *= smoothstep(far * 0.5, far * 0.7, lengthCylinder);
    if (color.a < min(dither, 1.0)) discard;

    vec3 noisePos = floor((playerPos + cameraPosition) * 4.0 + 0.001) / 32.0;
    float noiseTexture = Noise3D(noisePos) + 0.5;
    float noiseFactor = max0(1.0 - 0.3 * dot(color.rgb, color.rgb));
    color.rgb *= pow(noiseTexture, 0.6 * noiseFactor);
    color.rgb *= 0.8;

    bool isLightSource = lmCoord.x > 0.99;

    DoLighting(color, shadowMult, playerPos, viewPos, lViewPos, geoNormal, normalM, 0.5,
               worldGeoNormal, lmCoordM, noSmoothLighting, noDirectionalShading, noVanillaAO,
               centerShadowBias, subsurfaceMode, smoothnessG, highlightMult, emission, purkinjeOverwrite, isLightSource);
    /* DRAWBUFFERS:06 */
    gl_FragData[0] = color;
    gl_FragData[1] = gl_FragData[1] = vec4(smoothnessG, 0.0, 0.0, lmCoordM.x + clamp01(purkinjeOverwrite) + clamp01(emission));
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

flat out int mat;

out vec2 lmCoord;

flat out vec3 upVec, sunVec, northVec, eastVec;
out vec3 normal;
out vec3 playerPos;

out vec4 glColor;

//Attributes//

//Common Variables//

//Common Functions//

//Includes//
#ifdef TAA
    #include "/lib/antialiasing/jitter.glsl"
#endif

//Program//
void main() {
    gl_Position = ftransform();
    #ifdef TAA
        gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
    #endif

    mat = dhMaterialId;

    lmCoord  = GetLightMapCoordinates();
    
    normal = normalize(gl_NormalMatrix * gl_Normal);
    upVec = normalize(gbufferModelView[1].xyz);
    eastVec = normalize(gbufferModelView[0].xyz);
    northVec = normalize(gbufferModelView[2].xyz);
    sunVec = GetSunVector();

    playerPos = (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).xyz;

    glColor = gl_Color;
}

#endif
