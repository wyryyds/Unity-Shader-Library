using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectsBase
{
    public Shader edgeDetectShader;
    private Material edgeDetectMaterial = null;

    public Material Material
    {
        get
        {
            edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
            return edgeDetectMaterial;
        }
    }
    //边缘线强度
    [Range(0.0f,1.0f)]
    public float edgesOnly = 0.0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material != null)
        {
            Material.SetFloat("_EdgeOnly", edgesOnly);
            Material.SetColor("_EdgeColor", edgeColor);
            Material.SetColor("_BackgroundColor", backgroundColor);
            Graphics.Blit(source, destination, Material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
