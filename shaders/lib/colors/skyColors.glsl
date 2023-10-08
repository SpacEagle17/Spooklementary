#ifndef INCLUDE_SKY_COLORS
#define INCLUDE_SKY_COLORS

#ifdef OVERWORLD
    uniform vec3 skyColorSmooth;
    vec3 skyColorM = (skyColor / (length(clamp(skyColorSmooth, skyColor * 0.9, skyColor * 1.1)) + 0.0001)) * vec3(0.949, 0.7725, 0.5569);
    vec3 skyColorNoon = skyColorM * mix(1.28, 1.28 - 0.47 * rainFactor, heightRelativeToCloud);
    vec3 skyColorSunset = skyColorM * mix(1.18, 1.18 - 0.44 * rainFactor, heightRelativeToCloud) * invNightFactor * invNightFactor;

    vec3 skyColorSqrt       = sqrt(skyColorNoon);
    vec3 noonUpSkyColor     = pow(skyColorSqrt, vec3(2.9));
    vec3 noonMiddleSkyColor = skyColorSqrt * mix(vec3(1.15), vec3(1.15) - vec3(0.1, 0.4, 0.6) * rainFactor, heightRelativeToCloud) + noonUpSkyColor * 0.6;
    vec3 noonDownSkyColor   = skyColorSqrt * mix(vec3(0.9), vec3(0.9) - vec3(0.15, 0.3, 0.42) * rainFactor, heightRelativeToCloud) + noonUpSkyColor * 0.25;

    vec3 sunsetUpSkyColor     = skyColorSunset * mix(vec3(0.8, 0.58, 0.58), vec3(0.8, 0.58, 0.58) + vec3(0.1, 0.2, 0.35) * rainFactor2, heightRelativeToCloud);
    vec3 sunsetMiddleSkyColor = skyColorSunset * mix(vec3(1.8, 1.3, 1.2), vec3(1.8, 1.3, 1.2) + vec3(0.15, 0.25, -0.05) * rainFactor2, heightRelativeToCloud);
    vec3 sunsetDownSkyColorP  = mix(vec3(1.45, 0.86, 0.5), vec3(1.45, 0.86, 0.5) - vec3(0.8, 0.3, 0.0) * rainFactor, heightRelativeToCloud);
    vec3 sunsetDownSkyColor   = sunsetDownSkyColorP * 0.5 + 0.25 * sunsetMiddleSkyColor;

    vec3 dayUpSkyColor     = mix(noonUpSkyColor, sunsetUpSkyColor, invNoonFactor2);
    vec3 dayMiddleSkyColor = mix(noonMiddleSkyColor, sunsetMiddleSkyColor, invNoonFactor2);
    vec3 dayDownSkyColor   = mix(noonDownSkyColor, sunsetDownSkyColor, invNoonFactor2);

    vec3 nightColFactor      = vec3(0.07, 0.14, 0.24) * mix(1.0, 1.0 - 0.5 * rainFactor, heightRelativeToCloud) + skyColor;
    vec3 nightUpSkyColor     = pow(nightColFactor, vec3(0.90)) * 0.4;
    vec3 nightMiddleSkyColor = sqrt(nightUpSkyColor) * 0.68;
    vec3 nightDownSkyColor   = nightMiddleSkyColor * vec3(0.82, 0.82, 0.88);
#endif

#endif