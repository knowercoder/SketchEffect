# SketchEffect
SketchEffect helps you to create a pencil sketch effect in Unity. All you have to do is create a material with the “SktechEffect” shader, assign necessary textures, and apply it to your game object. 

Note, this is not a post-processing shader.

## Requirements
- Unity 2021.3 and above
- URP v12+

![SE-Cover](https://github.com/knowercoder/SketchEffect/assets/43854177/194f1a49-8d4a-4b88-8f08-d54f0b223d3b)


## Key Features
- Hatching
  - 6 hatching levels
  - hatch color
  - hatch weight
- Custom lighting
  - multiple light support
  - shadow support
- Outline
  - outline width and color

## Hatching texture usage
There are six levels of hatching textures in the Textures/Hatch folder. You can replace these textures with your custom hatch textures to change the appearance. 

These six textures are packed into two textures as 'darkest' (level 0, 1, 2) and 'brightest' (level 3, 4, 5) and applied to the shader material

To pack your custom textures, use the 'PackRGB' tool under the menu - Tools -> PackRGB

## References:
Pencil hatching: https://kylehalladay.com/blog/tutorial/2017/02/21/Pencil-Sketch-Effect.html

Outline: https://youtu.be/8Xq7tU5QN1Q?si=PwAtReDyQ8mxsVaj

Custom lighting: https://nedmakesgames.medium.com/creating-custom-lighting-in-unitys-shader-graph-with-universal-render-pipeline-5ad442c27276
