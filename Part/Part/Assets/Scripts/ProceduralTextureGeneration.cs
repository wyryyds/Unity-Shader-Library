using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour
{
    public Material material = null;


    #region Material properties
    private int m_textureWidth = 512;
    public int TextureWidth 
    { 
        get { return m_textureWidth; } 
        set { m_textureWidth = value; UpdateMaterial(); } 
    }
    [SerializeField]
    private Color m_circleColor = Color.blue;
    public Color CircleColor
    {
        get { return m_circleColor; }
        set { m_circleColor = value;UpdateMaterial(); }
    }
    [SerializeField]
    private Color m_backgroundColor = Color.white;
    public Color backgroundColor
    {
        get
        {
            return m_backgroundColor;
        }
        set
        {
            m_backgroundColor = value;
            UpdateMaterial();
        }
    }
    [SerializeField]
    private float m_blurFactor = 2.0f;
    public float BlurFactor
    {
        get { return m_blurFactor; }
        set { m_blurFactor = value; UpdateMaterial(); }
    }
    #endregion
    private Texture2D m_generatedTexture = null;

    private void Start()
    {
        if (material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if(renderer==null)
            {
                Debug.LogWarning("No Renderer");
                return;
            }
            material = renderer.material;
        }
        UpdateMaterial();
    }
    private void UpdateMaterial()
    {
        if(material!=null)
        {
            m_generatedTexture = GenerateProceduralTexture();
            material.SetTexture("_MainTex", m_generatedTexture);
        }
    }
    private Texture2D GenerateProceduralTexture()
    {
        Texture2D proceduralTexture = new Texture2D(TextureWidth, TextureWidth);
        float circleInterval = TextureWidth / 4.0f;
        float radius = TextureWidth / 10.0f;
        float edgeBlur = 1.0f / BlurFactor;
        for(int w=0;w<TextureWidth;w++)
        {
            for(int h=0;h<TextureWidth;h++)
            {
                Color pixel = backgroundColor;
                for(int i=0;i<3;i++)
                {
                    for(int j=0;j<3;j++)
                    {
                        Vector2 circleCenter = 
                            new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;
                        Color color = MixColor(CircleColor, new Color(pixel.r, pixel.g, pixel.b, 0.0f),
                            Mathf.SmoothStep(0f, 1.0f, dist * edgeBlur));
                        pixel = MixColor(pixel, color, color.a);
                    }
                }
                proceduralTexture.SetPixel(w, h, pixel);
            }
        }
        proceduralTexture.Apply();
        return proceduralTexture;
    }
    private Color MixColor(Color color0, Color color1, float mixFactor)
    {
        Color mixColor = Color.white;
        mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
        mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
        mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
        mixColor.a = Mathf.Lerp(color0.a, color1.a, mixFactor);
        return mixColor;
    }
}
