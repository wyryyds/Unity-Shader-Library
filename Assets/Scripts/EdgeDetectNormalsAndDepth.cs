using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetectNormalsAndDepth :PostEffectsBase
{
    public Shader edgeDetectShader;
    private Material edgeDetectMaterial = null;
    public Material EdgeDetectMaterial
    {
        get
        {
            edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);  
            return edgeDetectMaterial;
        }
    }

    [Range(0.0f, 1.0f)]
    public float edgesOnly = 0.0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;
    //采样距离，改值越大描边越宽
    public float sampleDistance = 1.0f;
    public float sensitivityDepth = 1.0f;
    public float sensitivityNormals=1.0f;

    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }
    //有[ImageEffectOpaque]标签会在不透明Pass结束之后立即执行改函数，不对透明物体产生影响
    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(EdgeDetectMaterial!=null)
        {
            EdgeDetectMaterial.SetFloat("_EdgeOnly", edgesOnly);
            EdgeDetectMaterial.SetColor("_EdgeColor", edgeColor);
            EdgeDetectMaterial.SetColor("_BackgroundColor", backgroundColor);
            EdgeDetectMaterial.SetFloat("_SampleDistance", sampleDistance);
            EdgeDetectMaterial.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));

            Graphics.Blit(source, destination, EdgeDetectMaterial );
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
