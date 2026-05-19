{ config, lib, pkgs, ... }:

let
  myEmacs = (pkgs.emacs30-pgtk.pkgs.withPackages (epkgs: with epkgs; [
    # Core / UI
    vertico
    orderless
    marginalia
    consult
    which-key

    # Evil
    evil
    evil-collection
    general

    # Editing
    drag-stuff

    # Sidebar / Tabs
    treemacs
    treemacs-evil
    treemacs-magit
    # centaur-tabs

    # Git
    magit
    diff-hl

    # Modeline / Icons
    doom-modeline
    nerd-icons
    nerd-icons-completion

    # Terminal
    vterm

    # Language support
    nix-mode
    markdown-mode
    scala-mode
    treesit-grammars.with-all-grammars

    # Documents
    pdf-tools
  ]));
in
{
  environment.systemPackages = [ myEmacs ];

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
