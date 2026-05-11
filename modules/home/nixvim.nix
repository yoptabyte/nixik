{ config, pkgs, lib, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    opts = {
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      swapfile = false;
      backup = false;
      undofile = true;
      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      signcolumn = "yes";
      updatetime = 50;
      colorcolumn = "80";
      cursorline = true;
      mouse = "a";
      clipboard = "unnamedplus";
      completeopt = "menu,menuone,noselect";
      conceallevel = 0;
      fileencoding = "utf-8";
      pumheight = 10;
      showmode = false;
      showtabline = 0;
      splitbelow = true;
      splitright = true;
      timeoutlen = 300;
      writebackup = false;
      list = true;
      listchars = "space:·,trail:·,extends:>,precedes:<,tab:>·,nbsp:·";
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = [
      # Window navigation
      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options = { desc = "Go to left window"; }; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options = { desc = "Go to lower window"; }; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options = { desc = "Go to upper window"; }; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options = { desc = "Go to right window"; }; }
      # Resize windows
      { mode = "n"; key = "<C-Up>";    action = ":resize +2<CR>";          options = { desc = "Increase window height"; }; }
      { mode = "n"; key = "<C-Down>";  action = ":resize -2<CR>";          options = { desc = "Decrease window height"; }; }
      { mode = "n"; key = "<C-Left>";  action = ":vertical resize -2<CR>"; options = { desc = "Decrease window width"; }; }
      { mode = "n"; key = "<C-Right>"; action = ":vertical resize +2<CR>"; options = { desc = "Increase window width"; }; }
      # Buffers
      { mode = "n"; key = "<S-l>"; action = ":bnext<CR>";     options = { desc = "Next buffer"; }; }
      { mode = "n"; key = "<S-h>"; action = ":bprevious<CR>"; options = { desc = "Previous buffer"; }; }
      # Move text
      { mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv"; options = { desc = "Move block down"; }; }
      { mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv"; options = { desc = "Move block up"; }; }
      # Indent
      { mode = "v"; key = "<"; action = "<gv"; options = { desc = "Indent left"; }; }
      { mode = "v"; key = ">"; action = ">gv"; options = { desc = "Indent right"; }; }
      # Paste without yank
      { mode = "v"; key = "p"; action = "\"_dP"; options = { desc = "Paste without yanking"; }; }
      # Misc
      { mode = "n"; key = "<Esc>";    action = ":noh<CR>";  options = { desc = "Clear search highlighting"; }; }
      { mode = "n"; key = "<C-s>";    action = ":w<CR>";    options = { desc = "Save file"; }; }
      { mode = "n"; key = "<leader>q"; action = ":q<CR>";   options = { desc = "Quit"; }; }
      { mode = "n"; key = "<leader>Q"; action = ":qa<CR>";  options = { desc = "Quit all"; }; }
      { mode = "n"; key = "<leader>|"; action = ":vsplit<CR>"; options = { desc = "Vertical split"; }; }
      { mode = "n"; key = "<leader>-"; action = ":split<CR>";  options = { desc = "Horizontal split"; }; }
      # Telescope
      { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<CR>";  options = { desc = "Find files"; }; }
      { mode = "n"; key = "<leader>fw"; action = "<cmd>Telescope live_grep<CR>";   options = { desc = "Find words"; }; }
      { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<CR>";     options = { desc = "Find buffers"; }; }
      { mode = "n"; key = "<leader>fh"; action = "<cmd>Telescope help_tags<CR>";   options = { desc = "Find help"; }; }
      { mode = "n"; key = "<leader>fo"; action = "<cmd>Telescope oldfiles<CR>";    options = { desc = "Find old files"; }; }
      { mode = "n"; key = "<leader>fc"; action = "<cmd>Telescope grep_string<CR>"; options = { desc = "Find word under cursor"; }; }
      { mode = "n"; key = "<leader>fk"; action = "<cmd>Telescope keymaps<CR>";     options = { desc = "Find keymaps"; }; }
      { mode = "n"; key = "<leader>fm"; action = "<cmd>Telescope marks<CR>";       options = { desc = "Find marks"; }; }
      { mode = "n"; key = "<leader>fr"; action = "<cmd>Telescope registers<CR>";   options = { desc = "Find registers"; }; }
      { mode = "n"; key = "<leader>ft"; action = "<cmd>Telescope colorscheme<CR>"; options = { desc = "Find themes"; }; }
      # Neo-tree
      { mode = "n"; key = "<leader>e"; action = ":Neotree toggle<CR>"; options = { desc = "Toggle file explorer"; }; }
      { mode = "n"; key = "<leader>o"; action = ":Neotree focus<CR>";  options = { desc = "Focus file explorer"; }; }
      # Git
      { mode = "n"; key = "<leader>gg"; action = ":LazyGit<CR>";                                        options = { desc = "LazyGit"; }; }
      { mode = "n"; key = "<leader>gj"; action = ":lua require('gitsigns').next_hunk()<CR>";             options = { desc = "Next git hunk"; }; }
      { mode = "n"; key = "<leader>gk"; action = ":lua require('gitsigns').prev_hunk()<CR>";             options = { desc = "Previous git hunk"; }; }
      { mode = "n"; key = "<leader>gp"; action = ":lua require('gitsigns').preview_hunk()<CR>";          options = { desc = "Preview git hunk"; }; }
      { mode = "n"; key = "<leader>gr"; action = ":lua require('gitsigns').reset_hunk()<CR>";            options = { desc = "Reset git hunk"; }; }
      { mode = "n"; key = "<leader>gs"; action = ":lua require('gitsigns').stage_hunk()<CR>";            options = { desc = "Stage git hunk"; }; }
      { mode = "n"; key = "<leader>gu"; action = ":lua require('gitsigns').undo_stage_hunk()<CR>";       options = { desc = "Undo stage git hunk"; }; }
      { mode = "n"; key = "<leader>gd"; action = ":lua require('gitsigns').diffthis()<CR>";              options = { desc = "Git diff"; }; }
      # LSP
      { mode = "n"; key = "<leader>la"; action = ":lua vim.lsp.buf.code_action()<CR>";   options = { desc = "Code action"; }; }
      { mode = "n"; key = "<leader>ld"; action = ":lua vim.lsp.buf.definition()<CR>";    options = { desc = "Go to definition"; }; }
      { mode = "n"; key = "<leader>lD"; action = ":lua vim.lsp.buf.declaration()<CR>";   options = { desc = "Go to declaration"; }; }
      { mode = "n"; key = "<leader>lf"; action = ":lua vim.lsp.buf.format()<CR>";        options = { desc = "Format"; }; }
      { mode = "n"; key = "<leader>lh"; action = ":lua vim.lsp.buf.hover()<CR>";         options = { desc = "Hover"; }; }
      { mode = "n"; key = "<leader>li"; action = ":lua vim.lsp.buf.implementation()<CR>"; options = { desc = "Go to implementation"; }; }
      { mode = "n"; key = "<leader>lr"; action = ":lua vim.lsp.buf.references()<CR>";    options = { desc = "References"; }; }
      { mode = "n"; key = "<leader>lR"; action = ":lua vim.lsp.buf.rename()<CR>";        options = { desc = "Rename"; }; }
      { mode = "n"; key = "<leader>ls"; action = ":lua vim.lsp.buf.signature_help()<CR>"; options = { desc = "Signature help"; }; }
      { mode = "n"; key = "<leader>lt"; action = ":lua vim.lsp.buf.type_definition()<CR>"; options = { desc = "Type definition"; }; }
      # Buffers
      { mode = "n"; key = "<leader>c"; action = ":bdelete<CR>";  options = { desc = "Close buffer"; }; }
      { mode = "n"; key = "<leader>C"; action = ":bdelete!<CR>"; options = { desc = "Force close buffer"; }; }
      # Comment
      { mode = "n"; key = "<leader>/"; action = "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>"; options = { desc = "Toggle comment line"; }; }
      { mode = "v"; key = "<leader>/"; action = "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>"; options = { desc = "Toggle comment selection"; }; }
      # Multi-cursor
      { mode = "n"; key = "<leader>m"; action = "<cmd>MCstart<CR>"; options = { desc = "Multi-cursor: start"; }; }
      { mode = "v"; key = "<leader>m"; action = "<cmd>MCstart<CR>"; options = { desc = "Multi-cursor: start (selection)"; }; }
      # Zen mode
      { mode = "n"; key = "<leader>z"; action = "<cmd>ZenMode<CR>"; options = { desc = "Toggle zen mode"; }; }
      # Zoom
      { mode = "n"; key = "<C-=>"; action = ":ZoomIn<CR>";  options = { desc = "Zoom in"; }; }
      { mode = "n"; key = "<C-->"; action = ":ZoomOut<CR>"; options = { desc = "Zoom out"; }; }
    ];

    plugins = {
      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
          ui-select.enable = true;
        };
        settings = {
          defaults = {
            prompt_prefix = " ";
            selection_caret = " ";
            path_display = [ "truncate" ];
            sorting_strategy = "ascending";
            layout_config = {
              horizontal = { prompt_position = "top"; preview_width = 0.55; };
              vertical   = { mirror = false; };
              width = 0.87;
              height = 0.80;
              preview_cutoff = 120;
            };
            mappings.i = {
              "<C-n>" = "move_selection_next";
              "<C-p>" = "move_selection_previous";
              "<C-j>" = "move_selection_next";
              "<C-k>" = "move_selection_previous";
            };
          };
        };
      };

      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          enable_refresh = true;
          window = {
            width = 30;
            mappings."<space>" = "none";
          };
          event_handlers = [{
            event = "neo_tree_buffer_enter";
            handler.__raw = ''
              function()
                vim.opt_local.number = true
                vim.opt_local.relativenumber = true
              end
            '';
          }];
          filesystem = {
            follow_current_file.enabled = true;
            use_libuv_file_watcher = true;
          };
        };
      };

      which-key = {
        enable = true;
        settings = {
          delay = 300;
          icons.group = "";
          spec = [
            { __unkeyed-1 = "<leader>f"; group = "Find"; }
            { __unkeyed-1 = "<leader>g"; group = "Git"; }
            { __unkeyed-1 = "<leader>l"; group = "LSP"; }
            { __unkeyed-1 = "<leader>b"; group = "Buffer"; }
          ];
        };
      };

      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
        grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
          bash
          lua
          markdown
          markdown_inline
          nix
          vim
          vimdoc
          yaml
          json
          python
          rust
          go
          html
          css
          javascript
          typescript
        ];
      };

      lsp = {
        enable = true;
        servers = {
          nil_ls.enable   = true;
          lua_ls.enable   = true;
          pyright.enable  = true;
          ts_ls.enable    = true;
          gopls.enable    = true;
          html.enable     = true;
          cssls.enable    = true;
          tailwindcss.enable = true;
          docker_language_server.enable = true;
          docker_compose_language_service.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>"     = "cmp.mapping.scroll_docs(-4)";
            "<C-e>"     = "cmp.mapping.close()";
            "<C-f>"     = "cmp.mapping.scroll_docs(4)";
            "<CR>"      = "cmp.mapping.confirm({ select = true })";
            "<S-Tab>"   = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<Tab>"     = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
            { name = "luasnip"; }
          ];
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
        };
      };

      luasnip.enable = true;
      friendly-snippets.enable = true;

      gitsigns = {
        enable = true;
        settings.signs = {
          add.text          = "│";
          change.text       = "│";
          delete.text       = "_";
          topdelete.text    = "‾";
          changedelete.text = "~";
          untracked.text    = "┆";
        };
      };

      lazygit.enable = true;

      lualine = {
        enable = true;
        settings = {
          options = {
            theme = {
              normal = {
                a = { bg = "#f0c040"; fg = "#28261f"; gui = "bold"; };
                b = { bg = "#302e26"; fg = "#c8c8c0"; };
                c = { bg = "#28261f"; fg = "#c8c8c0"; };
              };
              insert = {
                a = { bg = "#a8d8a0"; fg = "#28261f"; gui = "bold"; };
                b = { bg = "#302e26"; fg = "#c8c8c0"; };
                c = { bg = "#28261f"; fg = "#c8c8c0"; };
              };
              visual = {
                a = { bg = "#e8a020"; fg = "#28261f"; gui = "bold"; };
                b = { bg = "#302e26"; fg = "#c8c8c0"; };
                c = { bg = "#28261f"; fg = "#c8c8c0"; };
              };
              replace = {
                a = { bg = "#e8a020"; fg = "#28261f"; gui = "bold"; };
                b = { bg = "#302e26"; fg = "#c8c8c0"; };
                c = { bg = "#28261f"; fg = "#c8c8c0"; };
              };
              command = {
                a = { bg = "#f0c040"; fg = "#28261f"; gui = "bold"; };
                b = { bg = "#302e26"; fg = "#c8c8c0"; };
                c = { bg = "#28261f"; fg = "#c8c8c0"; };
              };
              inactive = {
                a = { bg = "#28261f"; fg = "#888882"; gui = "bold"; };
                b = { bg = "#28261f"; fg = "#888882"; };
                c = { bg = "#28261f"; fg = "#888882"; };
              };
            };
            component_separators = { left = ""; right = ""; };
            section_separators   = { left = ""; right = ""; };
          };
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [ "branch" "diff" "diagnostics" ];
            lualine_c = [ "filename" ];
            lualine_x = [ "encoding" "fileformat" "filetype" ];
            lualine_y = [ "progress" ];
            lualine_z = [ "location" ];
          };
        };
      };

      bufferline = {
        enable = false;
      #   settings.options = {
      #     mode = "buffers";
      #     separator_style = "slant";
      #     always_show_bufferline = true;
      #     show_buffer_close_icons = true;
      #     show_close_icon = false;
      #     color_icons = true;
      #   };
      };

      nvim-autopairs.enable = true;

      comment = {
        enable = true;
        settings = {
          toggler  = { line = "<leader>/"; block = "<leader>bc"; };
          opleader = { line = "<leader>/"; block = "<leader>b"; };
        };
      };

      indent-blankline = {
        enable = true;
        settings.scope.enabled = true;
      };

      colorizer.enable = true;
      web-devicons.enable = true;
      nvim-surround.enable = true;
      todo-comments.enable = true;
      trouble.enable = true;

      zen-mode = {
        enable = true;
        settings = {
          window = {
            backdrop = 0.95;
            width = 0.8;
            height = 0.9;
            options = {
              signcolumn = "no";
              number = true;
              relativenumber = true;
              cursorline = false;
              cursorcolumn = false;
              foldcolumn = "0";
              list = false;
            };
          };
          plugins.options = {
            enabled = true;
            ruler = false;
            showcmd = false;
            laststatus = 0;
          };
        };
      };

      alpha = {
        enable = true;
        settings.layout = [
          { type = "padding"; val = 2; }
          {
            opts = { hl = "Type"; position = "center"; };
            type = "text";
            val = [
              "⠄⠄⠄⠄⠄⠄⣠⢼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⡄⠄⠄⠄"
              "⠄⠄⣀⣤⣴⣾⣿⣷⣭⣭⣭⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠄⠄"
              "⠄⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣸⣿⣿⣧⠄⠄"
              "⠄⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⢻⣿⣿⡄⠄"
              "⠄⢸⣿⣮⣿⣿⣿⣿⣿⣿⣿⡟⢹⣿⣿⣿⡟⢛⢻⣷⢻⣿⣧⠄"
              "⠄⠄⣿⡏⣿⡟⡛⢻⣿⣿⣿⣿⠸⣿⣿⣿⣷⣬⣼⣿⢸⣿⣿⠄"
              "⠄⠄⣿⣧⢿⣧⣥⣾⣿⣿⣿⡟⣴⣝⠿⣿⣿⣿⠿⣫⣾⣿⣿⡆"
              "⠄⠄⢸⣿⣮⡻⠿⣿⠿⣟⣫⣾⣿⣿⣿⣷⣶⣾⣿⡏⣿⣿⣿⡇"
              "⠄⠄⢸⣿⣿⣿⡇⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⣿⣿⣿⡇"
              "⠄⠄⢸⣿⣿⣿⡇⠄⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢸⣿⣿⣿⠄"
              "⠄⠄⣼⣿⣿⣿⢃⣾⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⣿⣿⣿⡇⠄"
              "⠄⠄⠸⣿⣿⢣⢶⣟⣿⣖⣿⣷⣻⣮⡿⣽⣿⣻⣖⣶⣤⣭⡉⠄"
            ];
          }
          { type = "padding"; val = 2; }
        ];
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      vim-sleuth
      hydra-nvim
      multicursors-nvim
    ];

    extraConfigLua = ''
      -- K380 Graphite colour scheme
      vim.cmd("highlight clear")
      vim.cmd("set background=dark")
      local hl = vim.api.nvim_set_hl
      hl(0, "Normal",        { fg="#c8c8c0", bg="#28261F" })
      hl(0, "NormalNC",      { fg="#c8c8c0", bg="#28261F" })
      hl(0, "NormalFloat",   { fg="#c8c8c0", bg="#302e26" })
      hl(0, "FloatBorder",   { fg="#3d3b30", bg="none" })
      hl(0, "SignColumn",    { bg="none" })
      hl(0, "EndOfBuffer",   { fg="#302e26", bg="none" })
      hl(0, "CursorLine",    { bg="#302e26" })
      hl(0, "CursorLineNr",  { fg="#f0c040", bold=true })
      hl(0, "LineNr",        { fg="#48463a" })
      hl(0, "ColorColumn",   { bg="#302e26" })
      hl(0, "Visual",        { bg="#3d3b30" })
      hl(0, "Search",        { fg="#28261f", bg="#f0c040" })
      hl(0, "IncSearch",     { fg="#28261f", bg="#e8a020" })
      hl(0, "Cursor",        { fg="#28261f", bg="#f0c040" })
      hl(0, "StatusLine",    { fg="#f0c040", bg="#302e26" })
      hl(0, "StatusLineNC",  { fg="#888882", bg="#28261f" })
      hl(0, "TabLine",       { fg="#888882", bg="#28261f" })
      hl(0, "TabLineSel",    { fg="#f0c040", bg="#302e26" })
      hl(0, "TabLineFill",   { bg="#201e18" })
      hl(0, "Pmenu",         { fg="#c8c8c0", bg="#302e26" })
      hl(0, "PmenuSel",      { fg="#28261f", bg="#f0c040" })
      hl(0, "PmenuSbar",     { bg="#302e26" })
      hl(0, "PmenuThumb",    { bg="#f0c040" })
      hl(0, "Comment",       { fg="#5a5848", italic=true })
      hl(0, "Keyword",       { fg="#f0c040" })
      hl(0, "Statement",     { fg="#f0c040" })
      hl(0, "Conditional",   { fg="#f0c040" })
      hl(0, "Repeat",        { fg="#f0c040" })
      hl(0, "Function",      { fg="#a8d8a0" })
      hl(0, "String",        { fg="#e8a020" })
      hl(0, "Number",        { fg="#e8a020" })
      hl(0, "Boolean",       { fg="#e8a020" })
      hl(0, "Identifier",    { fg="#c8c8c0" })
      hl(0, "Type",          { fg="#a8d8a0" })
      hl(0, "Special",       { fg="#f0c040" })
      hl(0, "PreProc",       { fg="#f0c040" })
      hl(0, "Constant",      { fg="#e8a020" })
      hl(0, "Error",         { fg="#e8a020", bg="#28261f" })
      hl(0, "Todo",          { fg="#28261f", bg="#f0c040" })
      hl(0, "DiagnosticError", { fg="#e8a020" })
      hl(0, "DiagnosticWarn",  { fg="#f0c040" })
      hl(0, "DiagnosticInfo",  { fg="#a8d8a0" })
      hl(0, "DiagnosticHint",  { fg="#888882" })

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          hl(0, "Normal",   { fg="#c8c8c0", bg="#28261F" })
          hl(0, "NormalNC", { fg="#c8c8c0", bg="#28261F" })
        end,
      })

      -- Neo-tree colours
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "neo-tree",
        callback = function()
          local hl = vim.api.nvim_set_hl
          hl(0, "NeoTreeNormal",       { fg="#c8c8c0", bg="none" })
          hl(0, "NeoTreeNormalNC",     { fg="#c8c8c0", bg="none" })
          hl(0, "NeoTreeCursorLine",   { bg="#302e26" })
          hl(0, "NeoTreeRootName",     { fg="#c8c8c0", bold=true })
          hl(0, "NeoTreeDirectoryName",{ fg="#c8c8c0" })
          hl(0, "NeoTreeFileName",     { fg="#c8c8c0" })
          hl(0, "NeoTreeGitAdded",     { fg="#a8d8a0" })
          hl(0, "NeoTreeGitModified",  { fg="#e8a020" })
          hl(0, "NeoTreeGitDeleted",   { fg="#e8a020" })
          hl(0, "NeoTreeGitUntracked", { fg="#5a5848" })
          hl(0, "NeoTreeIndentMarker", { fg="#48463a" })
          hl(0, "NeoTreeWinSeparator", { fg="#3d3b30" })
        end,
      })

      -- Transparent background (keep editor bg solid)
      local function set_transparent_background()
        for _, group in ipairs({ "SignColumn","EndOfBuffer","NormalFloat","FloatBorder" }) do
          vim.api.nvim_set_hl(0, group, { bg = "none" })
        end
      end
      set_transparent_background()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_transparent_background })

      -- Per-window zoom
      local font_name   = "ZedMono Nerd Font"
      local font_sizes  = { code = 14, neotree = 14 }
      local function set_font(size) vim.o.guifont = font_name .. ":h" .. size end
      local function is_neotree()   return vim.bo.filetype == "neo-tree" end
      vim.api.nvim_create_user_command("ZoomIn",  function()
        if is_neotree() then font_sizes.neotree = font_sizes.neotree + 1; set_font(font_sizes.neotree)
        else                 font_sizes.code    = font_sizes.code    + 1; set_font(font_sizes.code) end
      end, {})
      vim.api.nvim_create_user_command("ZoomOut", function()
        if is_neotree() then if font_sizes.neotree > 6 then font_sizes.neotree = font_sizes.neotree - 1; set_font(font_sizes.neotree) end
        else                 if font_sizes.code    > 6 then font_sizes.code    = font_sizes.code    - 1; set_font(font_sizes.code)    end end
      end, {})
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          set_font(is_neotree() and font_sizes.neotree or font_sizes.code)
        end,
      })

      -- multicursors.nvim
      pcall(function() require("multicursors").setup({}) end)

      -- Highlight on yank
      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
      })

      -- LSP: guard nil capability registrations
      local orig = vim.lsp.handlers["client/registerCapability"]
      vim.lsp.handlers["client/registerCapability"] = function(err, result, ctx, config)
        if not result or not result.registrations then return end
        return orig(err, result, ctx, config)
      end

      vim.opt.iskeyword:append("-")
    '';
  };
}
