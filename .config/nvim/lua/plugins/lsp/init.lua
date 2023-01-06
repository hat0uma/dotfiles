local M = {
  "p00f/clangd_extensions.nvim",
  "Hoffs/omnisharp-extended-lsp.nvim",
  "jose-elias-alvarez/typescript.nvim",
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
    cmd = { "Mason", "MasonInstall" },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup()
    end,
  },
  {
    "folke/neodev.nvim",
    config = function()
      require("neodev").setup {
        library = {
          enabled = true,
          runtime = true,
          types = true,
          plugins = true,
        },
        experimental = {
          pathStrict = true,
        },
        setup_jsonls = false,
        lspconfig = true,
      }
    end,
  },
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    config = function()
      require "mason-lspconfig"

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      local on_attach = function(client, bufnr)
        --- https://github.com/OmniSharp/omnisharp-roslyn/issues/2483
        if client.name == "omnisharp" then
          client.server_capabilities.semanticTokensProvider = {
            full = vim.empty_dict(),
            legend = {
              tokenModifiers = { "static_symbol" },
              tokenTypes = {
                "comment",
                "excluded_code",
                "identifier",
                "keyword",
                "keyword_control",
                "number",
                "operator",
                "operator_overloaded",
                "preprocessor_keyword",
                "string",
                "whitespace",
                "text",
                "static_symbol",
                "preprocessor_text",
                "punctuation",
                "string_verbatim",
                "string_escape_character",
                "class_name",
                "delegate_name",
                "enum_name",
                "interface_name",
                "module_name",
                "struct_name",
                "type_parameter_name",
                "field_name",
                "enum_member_name",
                "constant_name",
                "local_name",
                "parameter_name",
                "method_name",
                "extension_method_name",
                "property_name",
                "event_name",
                "namespace_name",
                "label_name",
                "xml_doc_comment_attribute_name",
                "xml_doc_comment_attribute_quotes",
                "xml_doc_comment_attribute_value",
                "xml_doc_comment_cdata_section",
                "xml_doc_comment_comment",
                "xml_doc_comment_delimiter",
                "xml_doc_comment_entity_reference",
                "xml_doc_comment_name",
                "xml_doc_comment_processing_instruction",
                "xml_doc_comment_text",
                "xml_literal_attribute_name",
                "xml_literal_attribute_quotes",
                "xml_literal_attribute_value",
                "xml_literal_cdata_section",
                "xml_literal_comment",
                "xml_literal_delimiter",
                "xml_literal_embedded_expression",
                "xml_literal_entity_reference",
                "xml_literal_name",
                "xml_literal_processing_instruction",
                "xml_literal_text",
                "regex_comment",
                "regex_character_class",
                "regex_anchor",
                "regex_quantifier",
                "regex_grouping",
                "regex_alternation",
                "regex_text",
                "regex_self_escaped_character",
                "regex_other_escape",
              },
            },
            range = true,
          }
        end
        if client.server_capabilities.documentSymbolProvider then
          require("nvim-navic").attach(client, bufnr)
        end
        require("plugins.lsp.format").on_attach(client, bufnr)
        require("plugins.lsp.keymap").on_attach(client, bufnr)
      end
      local default_opts = { on_attach = on_attach, capabilities = capabilities }

      local servers = require("plugins.lsp.server").configurations
      for name, opts in pairs(servers) do
        opts = vim.tbl_deep_extend("force", default_opts, opts or {})
        if name == "tsserver" then
          require("typescript").setup { server = opts }
        else
          require("lspconfig")[name].setup(opts)
        end
      end

      require("plugins.lsp.format").setup()
      require("plugins.lsp.diagnostic").setup()
      require("plugins.null-ls").setup_sources { on_attach = on_attach }
    end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "jose-elias-alvarez/null-ls.nvim",
      "SmiteshP/nvim-navic",
      "mason-lspconfig.nvim",
      "neodev.nvim",
    },
  },
}
return M
