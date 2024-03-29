.PHONY: link cli gui sdk neovim neovim_plugin neovim_paser neovim_server

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
		expac \
		unzip \
		xsel \
		tmux \
		github-cli \
		nodejs \
		npm \
		go \
		ripgrep \
		fuse \
		smbclient \
		cifs-utils \
		zsh
	sudo -v ; curl https://rclone.org/install.sh | sudo bash
	curl -fsSL https://deno.land/x/install/install.sh | sh
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	${PWD}/scripts/install_neovim.sh
	mkdir -p ~/.eskk && curl 'https://skk-dev.github.io/dict/SKK-JISYO.L.gz' | gzip -d | iconv -f EUC-JP -t UTF-8 > ~/.eskk/SKK-JISYO.L
	curl https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo | tic -x -

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

sdk:
	sudo npm install -g vscode-langservers-extracted typescript 

neovim_plugin:
	nvim --headless "+Lazy! sync" +qa

neovim_parser:
	nvim --headless '+lua require("plugins.treesitter.parser").install{force=true,sync=true}' +qa

neovim_server:
	nvim --headless '+lua require("plugins.lsp.server").install()' +qa

neovim: neovim_plugin neovim_parser neovim_server

