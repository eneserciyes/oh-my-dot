STOW_DIR := $(HOME)/ws/oh-my-dot
PACKAGES := btop claude ghostty git lazygit nvim scripts sioyek ssh timewarrior tmux zsh
UNAME := $(shell uname)

.PHONY: stow unstow restow install brew

stow:
	@for pkg in $(PACKAGES); do \
		stow -v -d $(STOW_DIR) -t $(HOME) $$pkg 2>/dev/null || \
		echo "Skipping $$pkg (conflicts with existing files)"; \
	done

unstow:
	stow -v -D -d $(STOW_DIR) -t $(HOME) $(PACKAGES)

restow:
	stow -v -R -d $(STOW_DIR) -t $(HOME) $(PACKAGES)

brew:
	command -v brew >/dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew bundle --file=$(STOW_DIR)/Brewfile

install:
ifeq ($(UNAME),Darwin)
	$(MAKE) brew
	$(MAKE) stow
else
	bash $(STOW_DIR)/install/install-all.sh
	$(MAKE) stow
endif
