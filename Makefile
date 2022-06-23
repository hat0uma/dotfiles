.PHONY: link cli gui neovim

CONFIG_DIRS = $(sort $(abspath $(dir $(wildcard .config/*/))))
link:
	mkdir -p ${HOME}/.config
	$(foreach dir,$(CONFIG_DIRS),ln -sf $(dir) ${HOME}/.config/;)
	ln -sf ${PWD}/.zshrc ${HOME}

cli:
	yay -S --noconfirm \
		unzip \
		xsel \
		github-cli \
		nodejs \
		npm \
		ripgrep \
		stylua \
		shellcheck \
		zsh
	curl -fsSL https://deno.land/x/install/install.sh | sh
	${PWD}/scripts/install_neovim.sh

gui:
	yay -S --noconfirm \
		rofi \
		papirus-icon-theme \
		wezterm

neovim:
	nvim --headless -c 'lua require("plugins").install_packer()' -c 'qa'
	nvim --headless -c 'autocmd User PackerCompileDone quitall' -c 'PackerCompile'
	nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
	nvim --headless -c 'lua require("rc.treesitter").install_parsers{force=true,sync=true}' -c qa
	# nvim --headless -c 'lua require("rc.lsp.install").install_configured_servers_sync()' -c 'qa'
	nvim --headless -c 'LspInstall --sync sumneko_lua vimls pyright bashls' -c 'qa'

