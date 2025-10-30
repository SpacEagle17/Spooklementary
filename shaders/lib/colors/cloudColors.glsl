vec3 cloudRainColor = mix(nightMiddleSkyColor, dayMiddleSkyColor, sunFactor);
#if OVERALL_COLOR_TONE == 1
    vec3 cloudAmbientColor = mix(ambientColor * overallColorTone * (sunVisibility2 * (0.55 + 0.17 * noonFactor) + 0.35), cloudRainColor * 0.5, rainFactor);
#else
    vec3 cloudAmbientColor = mix(ambientColor * (sunVisibility2 * (0.55 + 0.17 * noonFactor) + 0.35), cloudRainColor * 0.5, rainFactor);
#endif
vec3 cloudLightColor   = mix(
    lightColor * 1.3,
    cloudRainColor * 0.45,
    noonFactor * rainFactor
);