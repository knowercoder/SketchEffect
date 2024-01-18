using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;

//This Editor script is a tool to pack your three hatch textures into
//a single textures. This will reduce the number of textures and
//thereby reduce the storage space. 

// Make sure you order yuor hatch texture in the order from darkest to brighest
namespace SketchEffect.Editor
{
    public class PackToRGB : EditorWindow
    {

        private Texture2D[] RGB;

        [MenuItem("Tools/PackRGB")]
        public static void ShowWindow()
        {
            EditorWindow.GetWindow(typeof(PackToRGB));
        }

        private void OnGUI()
        {
            if (RGB == null)
            {
                RGB = new Texture2D[3];
            }

            GUI.enabled = true;

            //Get the three hatch textures - hatch3, hatch2, hathc1
            RGB[0] = EditorGUILayout.ObjectField("Take R From Here: ", RGB[0], typeof(Texture2D), false) as Texture2D;
            RGB[1] = EditorGUILayout.ObjectField("Take R From Here: ", RGB[1], typeof(Texture2D), false) as Texture2D;
            RGB[2] = EditorGUILayout.ObjectField("Take R From Here: ", RGB[2], typeof(Texture2D), false) as Texture2D;

            //pack the textures in to a single texture and save as a .png texture file
            if (GUILayout.Button("Pack"))
            {
                string outPath = EditorUtility.SaveFilePanel("Where to save", "", "mytexture", "png");

                Texture2D outTex = new Texture2D(RGB[0].width, RGB[0].height, TextureFormat.RGB24, false);
                for (int i = 0; i < 3; ++i)
                {
                    string fileURL = AssetDatabase.GetAssetPath(RGB[i]);
                    byte[] imgByes = File.ReadAllBytes(fileURL);
                    Texture2D readableTex = new Texture2D(1, 1, TextureFormat.ARGB32, false);
                    readableTex.LoadImage(imgByes);
                    CopyChannel(readableTex, outTex, i);
                    outTex.Apply();
                }

                byte[] b = outTex.EncodeToPNG();
                File.WriteAllBytes(outPath, b);
                AssetDatabase.Refresh();
            }
        }

        //Copies the source texture channel and packs into the destination channel
        void CopyChannel(Texture2D src, Texture2D dst, int channel)
        {
            for (int i = 0; i < src.width; ++i)
            {
                for (int j = 0; j < src.height; ++j)
                {
                    Color s = src.GetPixel(i, j);
                    Color d = dst.GetPixel(i, j);
                    d.r = channel == 0 ? s.r : d.r;
                    d.g = channel == 1 ? s.g : d.g;
                    d.b = channel == 2 ? s.b : d.b;

                    dst.SetPixel(i, j, d);
                }
            }

        }

    }
}
