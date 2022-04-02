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
	@echo "*** instal dotnet ***"
	wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
	sudo dpkg -i packages-microsoft-prod.deb
	rm packages-microsoft-prod.deb
	sudo apt-get update; \
	  sudo apt-get install -y apt-transport-https && \
	  sudo apt-get update && \
	  sudo apt-get install -y dotnet-sdk-6.0
	@echo "*** instal mono ***"
	sudo apt-get install -y gnupg ca-certificates
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
	sudo apt-get update -y
	sudo apt-get install -y mono-devel
	@echo "*** instal gh ***"
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
	sudo apt-get install -y gh
	@echo "*** instal stylua ***"
	gh release download --repo "JohnnyMorganz/StyLua" -p "stylua-linux.zip"
	sudo unzip -f stylua-linux.zip -d /usr/bin && sudo chmod a+x /usr/bin/stylua
	rm stylua-linux.zip
	@echo "*** instal shellcheck ***"
	sudo apt-get install -y shellcheck

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
