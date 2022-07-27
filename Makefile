.PHONY: link cli gui neovim

CONFIG_DIRS = $(sort $(abspath $(dir $(wildcard .config/*/))))
link:
	mkdir -p ${HOME}/.config
	mkdir -p ${HOME}/.local/bin
	$(foreach dir,$(CONFIG_DIRS),ln -sf $(dir) ${HOME}/.config/;)
	ln -sf ${PWD}/.zshrc ${HOME}
	ln -sf ${PWD}/.zshenv ${HOME}
	ln -sf ${PWD}/.xprofile ${HOME}

cli:
	yay -S --noconfirm \
		unzip \
		xsel \
		github-cli \
		nodejs \
		npm \
		ripgrep \
		stylua \
		shellcheck-bin \
		zsh
	curl -fsSL https://deno.land/x/install/install.sh | sh
	${PWD}/scripts/install_neovim.sh

gui:
	yay -S --noconfirm \
		rofi \
		papirus-icon-theme \
		xremap-x11-bin \
		wezterm
	gh release download -R akiyosi/goneovim nightly --pattern 'goneovim-linux.tar.bz2'
	tar xvf goneovim-linux.tar.bz2 -C ${HOME}/.local/ && \
		rm goneovim-linux.tar.bz2
	ln -sf ${HOME}/.local/goneovim-linux/goneovim ~/.local/bin/goneovim

neovim:
	nvim --headless -c 'lua require("plugins").install_packer()' -c 'qa'
	nvim --headless -c 'autocmd User PackerCompileDone quitall' -c 'PackerCompile'
	nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
	nvim --headless -c 'lua require("rc.treesitter").install_parsers{force=true,sync=true}' -c 'qa'
	nvim --headless -c 'MasonInstall lua-language-server vim-language-server pyright' -c 'qa'

