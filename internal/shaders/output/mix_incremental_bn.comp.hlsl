struct Params
{
    uint2 img_size;
    float main_mix_factor;
    float aux_mix_factor;
};

static const uint3 gl_WorkGroupSize = uint3(8u, 8u, 1u);

cbuffer UniformParams
{
    Params _20_g_params : packoffset(c0);
};

RWTexture2D<float4> g_in_img1 : register(u3, space0);
RWTexture2D<float4> g_in_img2 : register(u4, space0);
RWTexture2D<float4> g_out_img : register(u0, space0);
RWTexture2D<float4> g_out_base_color_img : register(u1, space0);
RWTexture2D<float4> g_temp_base_color : register(u5, space0);
RWTexture2D<float4> g_out_depth_normals_img : register(u2, space0);
RWTexture2D<float4> g_temp_depth_normals_img : register(u6, space0);

static uint3 gl_GlobalInvocationID;
struct SPIRV_Cross_Input
{
    uint3 gl_GlobalInvocationID : SV_DispatchThreadID;
};

void comp_main()
{
    do
    {
        bool _26 = gl_GlobalInvocationID.x >= _20_g_params.img_size.x;
        bool _36;
        if (!_26)
        {
            _36 = gl_GlobalInvocationID.y >= _20_g_params.img_size.y;
        }
        else
        {
            _36 = _26;
        }
        if (_36)
        {
            break;
        }
        int2 _45 = int2(gl_GlobalInvocationID.xy);
        float3 _56 = g_in_img1[_45].xyz;
        g_out_img[_45] = float4(_56 + ((g_in_img2[_45].xyz - _56) * _20_g_params.main_mix_factor), 1.0f);
        float3 _88 = g_out_base_color_img[_45].xyz;
        g_out_base_color_img[_45] = float4(_88 + ((g_temp_base_color[_45].xyz - _88) * _20_g_params.aux_mix_factor), 1.0f);
        float4 _117 = g_out_depth_normals_img[_45];
        float4 _122 = g_temp_depth_normals_img[_45];
        float3 _128 = clamp(_122.xyz, (-1.0f).xxx, 1.0f.xxx);
        float4 _186 = _122;
        _186.x = _128.x;
        float4 _188 = _186;
        _188.y = _128.y;
        float4 _190 = _188;
        _190.z = _128.z;
        g_out_depth_normals_img[_45] = _117 + ((_190 - _117) * _20_g_params.aux_mix_factor);
        break;
    } while(false);
}

[numthreads(8, 8, 1)]
void main(SPIRV_Cross_Input stage_input)
{
    gl_GlobalInvocationID = stage_input.gl_GlobalInvocationID;
    comp_main();
}
