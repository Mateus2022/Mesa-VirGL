# Copyright © 2022 Konstantin Seurer
# SPDX-License-Identifier: MIT

radix_sort_shaders = [
  'init.comp',
  'fill.comp',
  'histogram.comp',
  'prefix.comp',
  'scatter_0_even.comp',
  'scatter_0_odd.comp',
  'scatter_1_even.comp',
  'scatter_1_odd.comp'
]

shader_include_dir = dir_source_root + '/src/amd/vulkan/radix_sort/targets/u64'

shader_include_files = files(
  'bufref.h',
  'prefix_limits.h',
  'prefix.h',
  'push.h',
  'scatter.glsl',
  dir_source_root + '/src/amd/vulkan/radix_sort/targets/u64/config.h'
)

radix_sort_spv = []
foreach s : radix_sort_shaders
  _name = f'@s@.spv.h'
  radix_sort_spv += custom_target(
    _name,
    input : s,
    output : _name,
    command : [
      prog_glslang, '-V', '-I' + shader_include_dir, '--target-env', 'spirv1.3',
      '-x', '-o', '@OUTPUT@', '@INPUT@', glslang_quiet, glslang_depfile,
    ],
    depfile : f'@_name@.d',
    depend_files : shader_include_files,
  )
endforeach
