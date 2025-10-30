lmCoordM = vec2(0.0);
color = vec4(0.0);

int sampleCount = 8;

float multiplier = 0.4 / (-viewVector.z * sampleCount);
vec2 interval = viewVector.xy * multiplier;
vec2 coord = signMidCoordPos * 0.5 + 0.5;
vec2 absMidCoordPos2 = absMidCoordPos * 2.0;
vec2 midCoord = texCoord - absMidCoordPos * signMidCoordPos;
vec2 minimumMidCoordPos = midCoord - absMidCoordPos;

for (int i = 0; i < sampleCount; i++) {
    float portalStep = (i + dither) / sampleCount;
    coord += interval * portalStep;
    vec2 sampleCoord = fract(coord) * absMidCoordPos2 + minimumMidCoordPos;
    vec4 psample = texture2DLod(tex, sampleCoord, 0);

    float factor = 1.0 - portalStep;
    psample *= pow(factor, 0.1);

    emission = max(emission, psample.r);

    color += psample;
}
color /= sampleCount;

color.rgb *= color.rgb * vec3(1.25, 1.0, 0.65);
color.a = sqrt1(color.a) * 0.8;

emission *= emission;
emission *= emission;
emission *= emission;
emission = clamp(emission * 120.0, 0.03, 1.2) * 8.0;

vec3 worldPos = playerPos + cameraPosition;
vec2 portalUV;
if (abs(worldGeoNormal.x) > 0.5) {
    portalUV = worldPos.yz;
} else {
    portalUV = worldPos.yx;
}

float baseNoise = texture2DLod(noisetex, portalUV * 0.03 + frameTimeCounter * 0.01, 0.0).b;
vec2 timeWaves = vec2(
    sin(frameTimeCounter * 0.7 + portalUV.x * 2.0),
    cos(frameTimeCounter * 0.5 + portalUV.y * 2.0)
);

vec2 warpedUV = portalUV * 0.1 + baseNoise * 0.05 * timeWaves + frameTimeCounter * 0.0083;
float portalNoise = 1.0 - texture2DLod(noisetex, warpedUV, 0.0).g;

color.rgb = mix(color.rgb * 0.66, color.rgb * 0.66 + pow2(vec3(portalNoise * 1.2)), portalNoise);
emission = mix(0, emission, portalNoise);
noGeneratedNormals = portalNoise > 0.25;

#define PORTAL_REDUCE_CLOSEUP
#ifdef PORTAL_REDUCE_CLOSEUP
    color.a *= min1(lViewPos - 0.2);
    if (color.a < 0.101) {
        if (color.a < 0.101 * dither) discard;
        else color.a = 0.101;
    }
#endif

#ifdef PORTAL_EDGE_EFFECT
    vec3 voxelPos = SceneToVoxel(playerPos);

    if (CheckInsideVoxelVolume(voxelPos)) {
        float portalOffset = 0.0625 * dither;
        vec3[6] portalOffsets = vec3[](
            vec3( portalOffset, 0, 0),
            vec3(-portalOffset, 0, 0),
            vec3( 0, portalOffset, 0),
            vec3( 0,-portalOffset, 0),
            vec3( 0, 0, portalOffset),
            vec3( 0, 0,-portalOffset)
        );

        float edge = 0.0;
        for (int i = 0; i < 6; i++) {
            uint voxel = GetVoxelVolume(ivec3(voxelPos + portalOffsets[i]));
            if (voxel != uint(25)) {
                edge = 1.0; break;
            }
        }

        vec4 edgeColor = vec4(normalize(color.rgb), 1.0);
        edgeColor.b *= 0.8;
        color = mix(color, edgeColor, edge);
        emission = mix(emission, 5.0, edge);
    }
#endif