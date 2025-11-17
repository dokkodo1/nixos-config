{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (blender.override {
      cudaSupport = true;
    })
  ];
  environment.variables = {
    CUDA_PATH = "${pkgs.cudatoolkit}";
  };
}
