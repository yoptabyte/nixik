{ config, pkgs, lib, ... }:

{
  programs.nixvim = {
    enable = true;
    nixpkgs.useGlobalPackages = true;
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
      colorcolumn = "";
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
      { mode = "n"; key = "<leader>bb"; action = "<cmd>Telescope buffers<CR>"; options = { desc = "List and select buffers"; }; }
      { mode = "n"; key = "<leader>bn"; action = "<cmd>bnext<CR>"; options = { desc = "Next buffer"; }; }
      { mode = "n"; key = "<leader>bp"; action = "<cmd>bprevious<CR>"; options = { desc = "Previous buffer"; }; }
      { mode = "n"; key = "<leader>bi"; action = ":buffer "; options = { desc = "Go to buffer by number or name"; }; }
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
      { mode = "n"; key = "<leader>e"; action = ":Neotree toggle position=float<CR>"; options = { desc = "Toggle floating file explorer"; }; }
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
          default_component_configs = {
            file_size = { enabled = true; width = 10; required_width = 70; };
            type = { enabled = true; width = 12; required_width = 82; };
            last_modified = {
              enabled = true;
              width = 18;
              required_width = 96;
              format = "%Y-%m-%d %H:%M";
            };
          };
          window = {
            position = "float";
            width = 110;
            height = 34;
            popup_border_style = "rounded";
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
            window.mappings = {
              r = "rename";
              "gP" = "chmod";
            };
            commands.chmod.__raw = ''
              function(state)
                local node = state.tree:get_node()
                if not node or not node.path then return end

                vim.ui.input({ prompt = "chmod (for example 664): " }, function(input)
                  if not input then return end
                  if not input:match("^[0-7][0-7][0-7][0-7]?$") then
                    vim.notify("Enter an octal mode with three or four digits, for example 664", vim.log.levels.WARN)
                    return
                  end

                  local ok, err = vim.uv.fs_chmod(node.path, tonumber(input, 8))
                  if not ok then
                    vim.notify("chmod failed: " .. tostring(err), vim.log.levels.ERROR)
                    return
                  end

                  vim.schedule(function()
                    require("neo-tree.sources.manager").refresh("filesystem")
                  end)
                end)
              end
            '';
            components.permissions.__raw = ''
              function(config, node, state)
                local stat = node.path and vim.uv.fs_stat(node.path)
                if not stat then return { text = "", highlight = "NeoTreeFileName" } end

                local mode = stat.mode
                local kind = bit.band(mode, 0xF000) == 0x4000 and "d"
                  or bit.band(mode, 0xF000) == 0xA000 and "l" or "-"
                local symbols = { "r", "w", "x", "r", "w", "x", "r", "w", "x" }
                local bits = { 0x100, 0x80, 0x40, 0x20, 0x10, 0x8, 0x4, 0x2, 0x1 }
                for index, mask in ipairs(bits) do
                  if bit.band(mode, mask) == 0 then symbols[index] = "-" end
                end

                return { text = kind .. table.concat(symbols), highlight = "NeoTreeFileName" }
              end
            '';
          };
          renderers.__raw = ''
            {
              directory = {
                { "indent" }, { "icon" }, { "current_filter" },
                { "container", content = {
                  { "name", zindex = 10 }, { "symlink_target", zindex = 10 },
                  { "clipboard", zindex = 10 }, { "diagnostics", errors_only = true, zindex = 20, align = "right", hide_when_expanded = true },
                  { "git_status", zindex = 10, align = "right", hide_when_expanded = true },
                  { "file_size", zindex = 10, align = "right" }, { "type", zindex = 10, align = "right" },
                  { "last_modified", zindex = 10, align = "right" }, { "permissions", zindex = 10, align = "right" },
                } },
              },
              file = {
                { "indent" }, { "icon" },
                { "container", content = {
                  { "name", zindex = 10 }, { "symlink_target", zindex = 10 }, { "clipboard", zindex = 10 },
                  { "modified", zindex = 20, align = "right" }, { "diagnostics", zindex = 20, align = "right" },
                  { "git_status", zindex = 10, align = "right" }, { "file_size", zindex = 10, align = "right" },
                  { "type", zindex = 10, align = "right" }, { "last_modified", zindex = 10, align = "right" },
                  { "permissions", zindex = 10, align = "right" },
                } },
              },
            }
          '';
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
                a = { bg = "#d65d0e"; fg = "#fbf1c7"; gui = "bold"; };
                b = { bg = "#ebdbb2"; fg = "#3c3836"; };
                c = { bg = "#fbf1c7"; fg = "#3c3836"; };
              };
              insert = {
                a = { bg = "#458588"; fg = "#fbf1c7"; gui = "bold"; };
                b = { bg = "#ebdbb2"; fg = "#3c3836"; };
                c = { bg = "#fbf1c7"; fg = "#3c3836"; };
              };
              visual = {
                a = { bg = "#98971a"; fg = "#fbf1c7"; gui = "bold"; };
                b = { bg = "#ebdbb2"; fg = "#3c3836"; };
                c = { bg = "#fbf1c7"; fg = "#3c3836"; };
              };
              replace = {
                a = { bg = "#98971a"; fg = "#fbf1c7"; gui = "bold"; };
                b = { bg = "#ebdbb2"; fg = "#3c3836"; };
                c = { bg = "#fbf1c7"; fg = "#3c3836"; };
              };
              command = {
                a = { bg = "#d65d0e"; fg = "#fbf1c7"; gui = "bold"; };
                b = { bg = "#ebdbb2"; fg = "#3c3836"; };
                c = { bg = "#fbf1c7"; fg = "#3c3836"; };
              };
              inactive = {
                a = { bg = "#fbf1c7"; fg = "#928374"; gui = "bold"; };
                b = { bg = "#fbf1c7"; fg = "#928374"; };
                c = { bg = "#fbf1c7"; fg = "#928374"; };
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

      nvim-autopairs.enable = true;

      comment = {
        enable = true;
        settings = {
          toggler  = { line = "<leader>/"; block = "<leader>bc"; };
          opleader = { line = "<leader>/"; block = "<leader>B"; };
        };
      };

      indent-blankline = {
        enable = true;
        luaConfig.pre = ''
          -- Gruvbox Light rainbow indent guides
          local indent_hooks = require("ibl.hooks")
          local function set_indent_colors()
            local colors = {
              RainbowRed = "#9d0006",
              RainbowYellow = "#b57614",
              RainbowBlue = "#076678",
              RainbowOrange = "#af3a03",
              RainbowGreen = "#79740e",
              RainbowViolet = "#8f3f71",
              RainbowCyan = "#427b58",
            }
            for group, color in pairs(colors) do
              vim.api.nvim_set_hl(0, group, { fg = color })
            end
          end
          indent_hooks.register(indent_hooks.type.HIGHLIGHT_SETUP, set_indent_colors)
          set_indent_colors()
        '';
        settings = {
          indent.highlight = [
            "RainbowRed"
            "RainbowYellow"
            "RainbowBlue"
            "RainbowOrange"
            "RainbowGreen"
            "RainbowViolet"
            "RainbowCyan"
          ];
          scope.enabled = true;
        };
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
      gruvbox
      vim-sleuth
      hydra-nvim
      multicursors-nvim
    ];

    extraConfigLua = ''
      -- Gruvbox Light (standard/medium contrast)
      vim.o.background = "light"
      vim.g.gruvbox_contrast_light = "medium"
      vim.g.gruvbox_italic = true
      vim.cmd.colorscheme("gruvbox")

      -- Neo-tree colours
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "neo-tree",
        callback = function()
          local hl = vim.api.nvim_set_hl
          hl(0, "NeoTreeNormal",       { fg="#3c3836", bg="none" })
          hl(0, "NeoTreeNormalNC",     { fg="#3c3836", bg="none" })
          hl(0, "NeoTreeCursorLine",   { bg="#ebdbb2" })
          hl(0, "NeoTreeRootName",     { fg="#3c3836", bold=true })
          hl(0, "NeoTreeDirectoryName",{ fg="#3c3836" })
          hl(0, "NeoTreeFileName",     { fg="#3c3836" })
          hl(0, "NeoTreeGitAdded",     { fg="#458588" })
          hl(0, "NeoTreeGitModified",  { fg="#d79921" })
          hl(0, "NeoTreeGitDeleted",   { fg="#cc241d" })
          hl(0, "NeoTreeGitUntracked", { fg="#928374" })
          hl(0, "NeoTreeIndentMarker", { fg="#a89984" })
          hl(0, "NeoTreeWinSeparator", { fg="#d5c4a1" })
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
      local font_sizes  = { code = 14, neotree = 11 }
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
