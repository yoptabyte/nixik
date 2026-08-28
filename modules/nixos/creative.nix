{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Video recording and streaming
    obs-studio

    # 3D editor
    blender

    # Audio editor
    audacity

    # Image editor
    krita

    # Video editor
    kdePackages.kdenlive

    # Lightweight DOCX viewer/editor
    abiword
  ];

  # OBS Studio: virtual camera via v4l2loopback
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';

}
