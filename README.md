# SketchEffect
SketchEffect helps you to create a pencil sketch effect in Unity. All you have to do is create a material with the “SktechEffect” shader, assign necessary textures, and apply it to your game object. 

Note, this is not a post-processing shader.


![SketchEffect](https://github.com/user-attachments/assets/c3328189-ac83-41fe-bf1d-26e2a66e7c69)


## Requirements
- Unity 2021.3 and above
- URP v12+

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
Pencil hatching: [Pencil Sketch Effect by Kyle Halladay](https://kylehalladay.com/blog/tutorial/2017/02/21/Pencil-Sketch-Effect.html)

Outline: [Toon Outlines by NedMakesGames](https://youtu.be/8Xq7tU5QN1Q?si=PwAtReDyQ8mxsVaj)

Custom lighting: [URP custom lighting by NedMakesGames](https://nedmakesgames.medium.com/creating-custom-lighting-in-unitys-shader-graph-with-universal-render-pipeline-5ad442c27276)
