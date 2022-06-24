//
//  Lighting.h
//  Lighting
//
//  Created by Pham Nghia on 2022/06/20.
//

#ifndef Lighting_h
#define Lighting_h

#import "Common.h"

float3 phongLighting(
  float3 normal,
  float3 position,
  constant Params &params,
  constant Light *lights,
  float3 baseColor);

#endif /* Lighting_h */
