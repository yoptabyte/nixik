{ config, lib, pkgs, ... }:

let
  myEmacs = (pkgs.emacs30-pgtk.pkgs.withPackages (epkgs: with epkgs; [
    vertico orderless marginalia consult which-key corfu
    evil evil-collection general
    drag-stuff
    treemacs treemacs-evil treemacs-magit
    magit diff-hl
    doom-modeline nerd-icons nerd-icons-completion
    vterm multi-vterm
    nix-mode markdown-mode scala-mode go-mode php-mode
    treesit-grammars.with-all-grammars
    pdf-tools
    ob-rust ob-go
    telega
  ]));
in
{
  environment.systemPackages = [ myEmacs pkgs.rust-analyzer ];

  systemd.user.services.emacs = {
    description = "Emacs text editor daemon";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe myEmacs} --fg-daemon";
      ExecStop = "${lib.getExe myEmacs}client -e '(kill-emacs)'";
      Restart = "on-failure";
    };
  };

  hjem.users.yoptabyte = {
    files = {
      ".emacs.d/themes/k380-graphite-theme.el".source = ../../modules/home/files/k380-graphite-theme.el;
      ".emacs.d/init.el".source = ../../modules/shared/emacs-init.el;
    };
  };
}
