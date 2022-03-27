.PHONY: link deps neovim app 

CONFIG_DIRS = $(sort $(abspath $(dir $(wildcard .config/*/))))
link:
	mkdir -p ${HOME}/.config
	$(foreach dir,$(CONFIG_DIRS),ln -sf $(dir) ${HOME}/.config/;)
	ln -sf ${PWD}/.zshrc ${HOME}


# neovim deps
deps:
	sudo apt-get install -y xsel nodejs npm ripgrep
	curl -fsSL https://deno.land/x/install/install.sh | sh
	@echo "*** instal dotnet start ***"
	wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
	sudo dpkg -i packages-microsoft-prod.deb
	rm packages-microsoft-prod.deb
	sudo apt-get update; \
	  sudo apt-get install -y apt-transport-https && \
	  sudo apt-get update && \
	  sudo apt-get install -y dotnet-sdk-6.0
	@echo "*** instal dotnet finish ***"

app:
	curl -LO https://github.com/wez/wezterm/releases/download/nightly/wezterm-nightly.Ubuntu20.04.deb
	sudo apt-get install -y ./wezterm-nightly.Ubuntu20.04.deb
	rm wezterm-nightly.Ubuntu20.04.deb
	sudo apt-get install -y zsh
	chsh -s $(shell which zsh)

neovim:
	nvim --headless -c 'lua require("plugins").install_packer()' -c 'qa'
	nvim --headless -c 'autocmd User PackerCompileDone quitall' -c 'PackerCompile'
	nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
	nvim --headless \
		-c 'lua require("rc.treesitter").install_parsers{force=true,sync=true}' \
		-c 'lua require("rc.lsp.install").install_configured_servers_sync()' \
		-c 'qa'
