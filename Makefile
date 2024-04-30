.PHONY: link cli gui sdk neovim neovim_plugin neovim_paser neovim_server setup-wsl-kali

CONFIG_DIRS = $(sort $(abspath $(dir $(wildcard .config/*/))))
link:
	mkdir -p ${HOME}/.config
	mkdir -p ${HOME}/.local/bin
	$(foreach dir,$(CONFIG_DIRS),ln -sf $(dir) ${HOME}/.config/;)
	ln -sf ${PWD}/.zshrc ${HOME}
	ln -sf ${PWD}/.zshenv ${HOME}
	ln -sf ${PWD}/.xprofile ${HOME}

cli:
	yay -S --noconfirm expac unzip xsel tmux github-cli nodejs npm go ripgrep zsh; \
	curl -fsSL https://deno.land/x/install/install.sh | sh
	${PWD}/scripts/install_neovim.sh
	mkdir -p ~/.eskk && curl 'https://skk-dev.github.io/dict/SKK-JISYO.L.gz' | gzip -d | iconv -f EUC-JP -t UTF-8 > ~/.eskk/SKK-JISYO.L
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
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

setup-wsl-kali:
	# wslu
	sudo apt install gnupg2 apt-transport-https
	wget -O - https://pkg.wslutiliti.es/public.key | sudo gpg -o /usr/share/keyrings/wslu-archive-keyring.pgp --dearmor
	echo "deb [signed-by=/usr/share/keyrings/wslu-archive-keyring.pgp] https://pkg.wslutiliti.es/kali kali-rolling main" | sudo tee -a /etc/apt/sources.list.d/wslu.list
	sudo apt update
	sudo apt install wslu
	# cli
	sudo apt-get install -y xsel ripgrep jq
	curl -fsSL https://deno.land/x/install/install.sh | sh
	mkdir -p ~/.eskk && curl 'https://skk-dev.github.io/dict/SKK-JISYO.L.gz' | gzip -d | iconv -f EUC-JP -t UTF-8 > ~/.eskk/SKK-JISYO.L
	${PWD}/scripts/install_neovim.sh
	make neovim_plugin
	make neovim_parser
	make neovim_server


