float4x4 matWorld:WORLD<string UIWidget="None";>;
float4x4 matView:VIEW<string UIWidget="None";>;
float4x4 matProjection:PROJECTION<string UIWidget="None";>;
float4 ambientMaterial
<
	string UIName="Ambient Material";
	string UIWidget="Color";
>;

float4 ambientLightColour:AMBIENT
<
	string UIName="Ambient Luigi Colour";
	string UIWidget="Color";
>;

float4 lightDirection:DIRECTION
<
	string Object="DirectionalLight";
>;

float4 diffuseMaterial
<
	string UIName="Diffuse Material";
	string UIWidget="Color";
>;

float4 diffuseLightColour:DIFFUSE
<
	string UIName="Diffuse Luigi Colour";
	string UIWidget="Color";
>;

float4 specularMaterial
<
	string UIName="Specular Material";
	string UIWidget="Color";
>;

float4 specularLightColour:SPECULAR
<
	string UIName="Specular Luigi Colour";
	string UIWidget="Color";
>;

float4 cameraPosition:POSITION
<
	string Object="Perspective";
	string UIWidget="None";
>;

Texture2D diffuseMap;
bool useDiffuseMap = false;

Texture2D specularMap;
bool useSpecularMap = false;

SamplerState wrapSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};


struct VS_INPUT
{
	float4 pos:POSITION;
	float4 colour:COLOR;
	float3 normal:NORMAL;
	float2 texCoord:TEXCOORD0;
};

struct PS_INPUT
{
	float4 pos:SV_POSITION;
	float4 colour:COLOR;
	float3 normal:NORMAL;
	float2 texCoord:TEXCOORD0;
	float4 cameraDirection:VIEWDIR;
};

PS_INPUT VS(VS_INPUT input)
{
	PS_INPUT output=(PS_INPUT)0;
	
	output.colour = input.colour;
	output.normal = mul(input.normal,matWorld);
	
	float4x4 matViewProjection = mul(matView,matProjection);
	float4x4 matWorldViewProjection = mul(matWorld,matViewProjection);
	
	output.pos = mul(input.pos,matWorldViewProjection);
	float4 worldPos = mul(input.pos,matWorld);
	output.cameraDirection = normalize(cameraPosition-worldPos);
	
	output.texCoord = input.texCoord;
	
	return output;
}

float4 PS(PS_INPUT input):SV_TARGET
{
	float4 diffuseColour = diffuseMaterial;
	float4 specularColour = specularMaterial;
	
	if(useDiffuseMap == true)
	{
		diffuseColour = diffuseMap.Sample(wrapSampler,input.texCoord);
	};
	
	if(useSpecularMap == true)
	{
		specularColour = specularMap.Sample(wrapSampler,input.texCoord);
	};
	
	float3 normal = normalize(input.normal);
	float4 lightDir = -normalize(lightDirection);
	float diffuse = saturate(dot(normal,lightDir));
	float4 halfVec = normalize(lightDir+input.cameraDirection);
	float specular = pow(saturate(dot(normal,halfVec)),25);
	return (ambientMaterial*ambientLightColour)+
			(diffuseColour*diffuseLightColour*diffuse)+
			(specularColour*specularLightColour*specular);
}

RasterizerState DisableCulling
{
    CullMode = NONE;
};

technique10 Render
{
	pass P0
	{
		SetVertexShader(CompileShader(vs_4_0, VS() ) );
		SetGeometryShader( NULL );
		SetPixelShader( CompileShader( ps_4_0,  PS() ) );
		SetRasterizerState(DisableCulling); 
	}
}