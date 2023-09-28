# Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT

import finn.builder.build_dataflow as build
import finn.builder.build_dataflow_config as build_cfg
from custom_steps import custom_step_mlp_export
from qonnx.core.datatype import DataType
from qonnx.core.modelwrapper import ModelWrapper

# Define model name
model_name = "finn_latency-mlp"
fpga_part = "xcvu2p-fsvj2104-3-e"

# Set up the build configuration for this model
cfg = build_cfg.DataflowBuildConfig(
    output_dir = "output_%s_%s" % (model_name, fpga_part),
    synth_clk_period_ns = 3.0, # ~333MHz
    fpga_part = fpga_part,
    vitis_opt_strategy = build_cfg.VitisOptStrategyCfg.PERFORMANCE_BEST,
    generate_outputs = [
        build_cfg.DataflowOutputType.ESTIMATE_REPORTS,
        build_cfg.DataflowOutputType.STITCHED_IP,
    ],
    save_intermediate_models=True,
    stitched_ip_gen_dcp=True,
    # stop_step = "step_generate_estimate_reports", # Uncomment to stop build after generating reports
    folding_config_file = "folding_config.json",
)

# Export MLP model to FINN-ONNX
modelOnnx = custom_step_mlp_export(model_name)
model = ModelWrapper(modelOnnx)

model.set_tensor_datatype(model.graph.input[0].name, DataType["BIPOLAR"])
model.save("models/finn_latency-mlp.onnx")


# Launch FINN compiler
build.build_dataflow_cfg("models/finn_latency-mlp.onnx", cfg)