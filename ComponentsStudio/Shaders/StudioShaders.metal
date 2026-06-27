#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Photo ripple — Apple WWDC24 "Create custom visual effects with SwiftUI"
/// water ripple. The PHOTO ITSELF distorts: each pixel is displaced radially
/// from `origin` by a decaying sine wave, and the layer is re-sampled at the
/// displaced position. The additive line lightens the wave crests into bright
/// white rims. Applied via `.layerEffect`.
///
/// `time` is the elapsed seconds since this ripple was born. `highlight` is the
/// crest brightness factor (Apple's sample hard-codes 0.3; the reference is
/// more aggressive, ~0.4–0.5).
[[ stitchable ]]
half4 photoRipple(
    float2 position,
    SwiftUI::Layer layer,
    float2 origin,
    float time,
    float amplitude,
    float frequency,
    float decay,
    float speed,
    float highlight
) {
    float dist = length(position - origin);

    // The wave reaches each pixel later the farther it is from the origin,
    // so the front is born under the touch and expands outward.
    float delay = dist / speed;
    time = max(0.0, time - delay);

    // Decaying sine — a few crests that fade out over the ripple's life.
    float rippleAmount = amplitude * sin(frequency * time) * exp(-decay * time);

    float2 n = normalize(position - origin);
    float2 newPosition = position + rippleAmount * n;

    half4 color = layer.sample(newPosition);

    // Lighten the crests into bright white rims, proportional to displacement.
    color.rgb += half(highlight * (rippleAmount / amplitude)) * color.a;

    return color;
}

/// Photo Ripple 2 — unified LIQUID GLASS fusion of Apple WWDC24 photo ripple +
/// Victor Baro refractive glass. Applied via `.layerEffect` on the photo itself
/// (stacked per ring, like Photo Ripple 1) so overlapping waves compound.
///
/// Each finger-seeded ring is a traveling wavefront at radius `R = speed * age`.
/// Pixels outside the gaussian band pass through crisp; inside the band:
///   • Baro refraction — radial bend with `1 - pow(localR, falloff)` curvature
///   • WWDC displacement — subtle sinusoidal crest push along the normal
///   • Chromatic aberration — R/B split toward the band edge
///   • Specular glint — thin, additive, cool-toned rim (not opaque white fill)
///   • Optional swirl — tangent rotation fading at the band edge
/// All samples are clamped to [0,size] to avoid black borders.
[[ stitchable ]]
half4 photoRipple2(
    float2 position,
    SwiftUI::Layer layer,
    float2 origin,
    float age,
    float speed,
    float bandWidth,
    float refract,
    float glint,
    float falloff,
    float swirl,
    float displacement,
    float chromatic,
    float maxRadius,
    float life,
    float2 size
) {
    float R = speed * age;
    float dist = length(position - origin);
    float halfW = max(bandWidth, 1.0);
    float x = (dist - R) / halfW;

    // Smooth anti-aliased gaussian band.
    float bandProfile = exp(-x * x);

    float lifeFade = 1.0 - smoothstep(life * 0.55, life, age);
    float radiusFade = 1.0 - smoothstep(maxRadius * 0.78, maxRadius, R);
    float env = lifeFade * radiusFade;
    float band = bandProfile * env;

    // Outside the traveling glass band the photo stays crisp.
    if (band < 0.002) {
        return layer.sample(position);
    }

    float2 toCenter = position - origin;
    float2 dir = toCenter / max(dist, 1e-4);

    // Local coordinate within the band: 0 at crest, 1 at edge.
    float localR = clamp(abs(x), 0.0, 1.0);
    float lensCurve = (1.0 - pow(localR, max(falloff, 0.5))) * bandProfile;

    // Baro-style radial refraction through the traveling lens ring.
    float2 refractOffset = dir * lensCurve * refract * env;

    // Optional subtle swirl (tangent rotation, strongest at crest).
    float swirlFade = bandProfile * (1.0 - localR);
    float theta = swirl * swirlFade * env;
    float c = cos(theta);
    float s = sin(theta);
    float2 rotated = float2(
        toCenter.x * c - toCenter.y * s,
        toCenter.x * s + toCenter.y * c
    );
    float2 swirlOffset = rotated - toCenter;

    // WWDC-style crest displacement — low default, localized to the wavefront.
    float crestShape = sin(3.14159265 * (1.0 - localR)) * bandProfile;
    float2 dispOffset = dir * displacement * crestShape * env;

    float2 totalOffset = refractOffset + swirlOffset + dispOffset;

    // Chromatic aberration — stronger toward the band edge.
    float chromaticStrength = localR * chromatic * 0.14 * band;
    float2 redOffset  = totalOffset * (1.0 + chromaticStrength);
    float2 blueOffset = totalOffset * (1.0 - chromaticStrength);

    float2 pG = clamp(position + totalOffset, float2(0.0), size);
    float2 pR = clamp(position + redOffset,  float2(0.0), size);
    float2 pB = clamp(position + blueOffset, float2(0.0), size);

    half4 sg = layer.sample(pG);
    half4 sr = layer.sample(pR);
    half4 sb = layer.sample(pB);
    half3 color = half3(sr.r, sg.g, sb.b);

    // Thin specular glint at the crest — additive, transparent, cool-toned.
    float2 lightDir = normalize(float2(-0.5, -0.8));
    float rimBias = clamp(dot(dir, lightDir), 0.0, 1.0);
    float edgeFade = pow(bandProfile, 7.0);
    float spec = edgeFade * (0.22 + 0.78 * rimBias) * glint * env;
    half3 highlightColor = half3(0.82, 0.86, 1.05);
    color += half3(spec) * highlightColor * sg.a;

    return half4(color, sg.a);
}

/// Black field with white dot grid and touch-driven fisheye bulge.
[[ stitchable ]]
half4 sphericMesh(
    float2 position,
    float2 size,
    float2 pointer,
    float gridDensity,
    float bulgeStrength,
    float dotScale
) {
    half3 black = half3(0.0);
    float aspect = size.x / max(size.y, 1.0);

    float2 uv = position / size;
    float2 p = pointer / size;

    float2 delta = uv - p;
    delta.x *= aspect;
    float dist = length(delta);

    float bulgeRadius = 0.36;
    float bulge = bulgeStrength * exp(-dist * dist / (bulgeRadius * bulgeRadius));
    float warp = 1.0 + bulge * 3.4;

    float2 gridPos = p + (delta / warp) / float2(aspect, 1.0);
    float spacing = 1.0 / gridDensity;

    float alpha = 0.0;
    float2 baseCell = gridPos / spacing;
    int2 originCell = int2(floor(baseCell));

    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            float2 cellId = float2(originCell + int2(i, j));
            float2 center = (cellId + 0.5) * spacing;

            float2 toDot = gridPos - center;
            toDot.x *= aspect;

            float2 dotDelta = center - p;
            dotDelta.x *= aspect;
            float dotDist = length(dotDelta);
            float dotBulge = bulgeStrength * exp(-dotDist * dotDist / (bulgeRadius * bulgeRadius));
            float radius = spacing * 0.17 * (1.0 + dotBulge * dotScale);

            float d = length(toDot);
            alpha = max(alpha, 1.0 - smoothstep(radius * 0.62, radius, d));
        }
    }

    return half4(mix(black, half3(1.0), half(alpha)), 1.0);
}

/// Refractive Glass — a faithful reproduction of Victor Baro's "Implementing a
/// Refractive Glass Shader in Metal" tutorial, assembling all four steps the
/// article walks through into one shader, applied to the whole content via
/// `.layerEffect`. A circular glass lens (center `glassCenter`, radius
/// `glassRadius`) sits over the wallpaper behind it and:
///   1. Refraction + magnification — offsets the sampled background along the
///      radial direction with a parabolic `1 - r²` falloff (center-focused
///      lens), faking Snell's-law bending of light through glass.
///   2. Chromatic aberration — splits the R/B sample channels along the offset,
///      stronger toward the edge (green stays put), for a subtle rainbow fringe.
///   3. Edge lighting (rim highlight) — a thin cool-toned glow at the glass
///      boundary, modulated by a fake upper-left light direction, suggesting
///      the material's thickness/curvature.
///   4. Shadow & occlusion — a soft, directionally-offset darkening just
///      outside the glass radius, grounding the lens in the scene.
///
/// Coordinates: the tutorial works in normalized `uv = position/size` space.
/// Here the math is done directly in PIXEL space (`glassCenter` is still passed
/// normalized and converted), which is mathematically equivalent to the
/// tutorial's formulas — `toCenter_uv * size == toCenter_px` — but keeps the
/// lens perfectly circular on a non-square (portrait) screen instead of
/// stretching into an ellipse.
[[ stitchable ]]
half4 refractiveGlass(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 glassCenter,   // normalized [0,1]
    float glassRadius,    // pixels
    float refraction,
    float falloff,        // distortion curve exponent in 1 - pow(r, falloff)
    float swirl,          // rotation at center (radians); fades to 0 at rim
    float edgeThickness,  // pixels
    float chromatic,
    float rimIntensity,
    float shadowStrength,
    float shadowBlur,     // pixels
    float shadowOffset,   // pixels
    float swirlPhase,     // radians — continuous idle rotation inside the lens
    float2 velocity       // normalized lens velocity (units/sec); boosts swirl when moving
) {
    float2 center = glassCenter * size;
    float2 toCenter = position - center;
    float dist = length(toCenter);
    float radius = max(glassRadius, 1.0);
    float normalizedDist = dist / radius;

    half4 originalColor = layer.sample(position);

    // ----- Outside the glass: soft directional shadow / occlusion -----
    if (normalizedDist > 1.0) {
        // Offset the shadow down-and-right to imply a directional light.
        float2 shadowCenter = center + float2(shadowOffset, shadowOffset);
        float shadowDist = length(position - shadowCenter);
        float shadowRadius = radius + shadowBlur;
        half4 result = originalColor;
        if (shadowDist < shadowRadius) {
            float shadowFalloff = (shadowDist - radius) / max(shadowBlur, 1.0);
            float feather = smoothstep(1.0, 0.0, shadowFalloff);
            result = mix(result, half4(0.0, 0.0, 0.0, 1.0),
                         half(feather * shadowStrength));
        }
        return result;
    }

    // ----- Inside the glass -----
    // (1) Swirl rotation + radial refraction — combined into one sampling
    // offset. Swirl rotates position around the lens center by `swirl` radians
    // at the center, fading to zero at the rim; refraction adds the existing
    // Snell-style radial bend (1 - pow(r, falloff)).
    float falloffSwirl = 1.0 - clamp(normalizedDist, 0.0, 1.0);
    float2 fromCenter = position - center;

    // User swirl knob + motion-driven boost; swirlPhase spins continuously inside the bubble.
    float motionAmount = length(velocity);
    float motionSwirl = motionAmount * 6.5;
    float theta = (swirl + motionSwirl) * falloffSwirl + swirlPhase * falloffSwirl * 1.6;

    // Movement vector tilts the swirl field — liquid drags inside the glass as it floats.
    if (motionAmount > 1e-4) {
        float velAngle = atan2(velocity.y, velocity.x);
        float radialAngle = atan2(fromCenter.y, fromCenter.x);
        float directionalTwist = sin(radialAngle - velAngle + swirlPhase * 0.65)
                                 * motionAmount * 3.8;
        theta += directionalTwist * falloffSwirl;
    }

    float c = cos(theta);
    float s = sin(theta);
    float2 rotated = float2(
        fromCenter.x * c - fromCenter.y * s,
        fromCenter.x * s + fromCenter.y * c
    );
    float2 swirlOffset = rotated - fromCenter;

    float distortion = 1.0 - pow(normalizedDist, falloff);
    float2 refractedOffset = -fromCenter * distortion * refraction;
    float2 totalOffset = swirlOffset + refractedOffset;

    // SwiftUI layer samples use a Y-up offset space relative to position (Y-down).
    // Negate Y on displacement so refraction/swirl bend in the same direction as the layer.
    float2 sampleOffset = float2(totalOffset.x, -totalOffset.y);

    // (2) Chromatic aberration on the combined offset — red shifts one way,
    // blue the other, green stays; split grows toward the edge.
    float chromaticStrength = normalizedDist * chromatic;
    float2 redSampleOffset  = sampleOffset * (1.0 + chromaticStrength);
    float2 blueSampleOffset = sampleOffset * (1.0 - chromaticStrength);

    float2 gPos = clamp(position + sampleOffset, float2(0.0), size);
    float2 rPos = clamp(position + redSampleOffset,  float2(0.0), size);
    float2 bPos = clamp(position + blueSampleOffset, float2(0.0), size);

    half4 refractedColor = layer.sample(gPos);
    half4 redSample  = layer.sample(rPos);
    half4 blueSample = layer.sample(bPos);
    refractedColor.r = redSample.r;
    refractedColor.b = blueSample.b;

    half4 result = refractedColor;

    // (3) Edge lighting / rim highlight, modulated by a fake upper-left light
    // so the glint wraps the top-left of the lens (glass thickness cue).
    float edgeDistance = abs(dist - radius);
    float edgeFade = smoothstep(edgeThickness, 0.0, edgeDistance);
    float2 lightDir = normalize(float2(-0.5, -0.8));
    float rimBias = clamp(dot(normalize(toCenter), lightDir), 0.0, 1.0);
    half3 highlightColor = half3(1.1, 1.1, 1.2);  // cool-toned
    result.rgb += half(edgeFade * rimBias * rimIntensity) * highlightColor;

    return result;
}

/// Frosted-glass refraction with chromatic split and pointer lens.
[[ stitchable ]]
half4 glassRefraction(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 pointer,
    float time,
    float lensStrength,
    float frostAmount,
    float chromaticSplit
) {
    float2 uv = position / size;
    float2 p = pointer / size;
    float dist = distance(uv, p);

    float breathe = sin(time * 1.2) * 0.004;
    float lens = exp(-dist * dist * 7.0) * (0.028 + breathe) * lensStrength;
    float2 offset = (uv - p) * lens * size;

    half4 r = layer.sample(position + offset * float2(chromaticSplit, 1.0));
    half4 g = layer.sample(position + offset);
    half4 b = layer.sample(position + offset * float2(2.0 - chromaticSplit, 1.0));
    half4 color = half4(r.r, g.g, b.b, g.a);

    float frost = exp(-dist * 3.5) * frostAmount;
    color.rgb = mix(color.rgb, half3(1.0), half(frost));
    color.rgb = mix(color.rgb, half3(0.98), half(0.08));
    return color;
}

/// Interactive dotted background — metal.graphics "Interactive Dotted Background".
/// A tiled dot grid on black; dots glow, attract, or repel near touch based on
/// `mode` (0 = glow, 1 = attraction, 2 = repulsion). A 3×3 neighbourhood search
/// keeps displaced dots from clipping at cell boundaries. Applied via `.colorEffect`.
[[ stitchable ]]
half4 dottedBackground(
    float2 position,
    half4 color,
    float2 size,
    float2 touch,
    float mode,
    float intensity,
    float gridDensity,
    float influenceRadius,
    float maxDisplacement
) {
    float2 uv = position / size;
    float cols = gridDensity;
    float rows = cols * (size.y / size.x);
    float2 grid = float2(cols, rows);

    float2 scaled = uv * grid;
    float2 currentCell = floor(scaled);

    float2 touchUV = touch / size;
    float aspect = size.y / size.x;

    float bestBrightness = 0.0;
    float bestDotMask = 0.0;

    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
            float2 neighbor = currentCell + float2(dx, dy);
            float2 dotWorld = (neighbor + 0.5) / grid;

            float2 awayDir = dotWorld - touchUV;
            float touchDist = length(float2(awayDir.x, awayDir.y * aspect));
            float2 dir = touchDist > 0.001 ? normalize(awayDir) : float2(0.0);
            float influence = (1.0 - smoothstep(0.0, influenceRadius, touchDist)) * intensity;

            float2 dotCenter = neighbor + 0.5;
            float radius = 0.12;
            float brightness = 0.25;

            if (mode < 0.5) {
                radius = mix(0.12, 0.22, influence);
                brightness = mix(0.25, 1.0, influence);
            } else if (mode < 1.5) {
                dotCenter += dir * (influence * maxDisplacement);
                brightness = mix(0.25, 1.0, influence);
            } else {
                dotCenter -= dir * (influence * maxDisplacement);
                brightness = mix(0.25, 1.0, 1.0 - influence);
            }

            float dist = radius - length(scaled - dotCenter);
            float dotMask = smoothstep(-0.02, 0.02, dist);

            if (dotMask * brightness > bestDotMask * bestBrightness) {
                bestDotMask = dotMask;
                bestBrightness = brightness;
            }
        }
    }

    return half4(half3(bestBrightness * bestDotMask), 1.0);
}

/// Film grain overlay — Uladzislau Volchyk "Crafting Interactive Tiles in SwiftUI".
/// Procedural black-and-white noise blended over MeshGradient via `.colorEffect`
/// inside a `GrainEffect` view modifier. Applied via `.visualEffect`.
[[ stitchable ]]
half4 noiseShader(
    float2 position,
    half4 color,
    float2 size
) {
    float noise = fract(sin(dot(position, float2(12.9898, 78.233))) * 43758.5453);
    return half4(half3(noise), 1.0) * color.a;
}
