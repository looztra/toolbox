POETRY_GUARD            := $(shell command -v poetry 2> /dev/null)
VENV_DIR                ?= $(shell poetry env info --path)
VENV_PYTHON3            := python3
PYTHON3_GUARD           := $(shell command -v ${VENV_PYTHON3} 2> /dev/null)
ifneq ($(VENV_DIR),)
	VENV_EXISTS             := $(shell ls -d $(VENV_DIR) 2> /dev/null)
else
	VENV_EXISTS             :=
endif
VENV_ACTIVATED          := $(shell echo $(VIRTUAL_ENV) 2> /dev/null)
VENV_ACTIVATE_FISH_CMD  := source $(VENV_DIR)/bin/activate.fish
VENV_ACTIVATE_OTHER_CMD := source $(VENV_DIR)/bin/activate
POETRY_INSTALL_SYNC_OPT := true

.PHONY: check-poetry
check-poetry: ## Check if poetry is installed 🐍
	@echo "+ $@"
ifndef POETRY_GUARD
	$(error "python3 is not available please install it")
endif
	@echo "Found poetry at '${POETRY_GUARD}' (and that's a good news)"

.PHONY: check-python3
check-python3: ## Check if python3 is installed 🐍
	@echo "+ $@"
ifndef PYTHON3_GUARD
	$(error "python3 is not available please install it")
endif
	@echo "Found ${VENV_PYTHON3} (and that's a good news)"

.PHONY: check-venv-exists
check-venv-exists: ## Check if venv is created 🙉
	@echo "+ $@"
ifdef VENV_EXISTS
	@echo "Found venv at path '$(VENV_DIR)' (and that's a good news)"
else
	$(error "no venv dir found, please create it first with 'make setup-venv'")
endif

.PHONY: setup-venv
setup-venv: check-python3 ## ▶ Setup a virtual env for running our python goodness 🎃
	@echo "+ $@"
ifeq ($(VENV_DIR),)
	@poetry install --sync
else
	@echo "Doing nothing, venv already setup at path [$(VENV_DIR)]"
endif


.PHONY: delete-venv
delete-venv: ## ▶ Delete venv
	@echo "+ $@"
	@if [ -d $(VENV_DIR) ]; then \
		echo "Deleting directory [$(VENV_DIR)]"; \
		rm -rf $(VENV_DIR); \
	else \
		echo "Nothing to do, directory [$(VENV_DIR)] does not exist"; \
	fi

.PHONY: venv
venv: setup-venv

.PHONY: activate-venv
activate-venv: check-python3 check-venv-exists ## Activate venv for the current shell ✨
	@echo "+ $@"
	@echo "Activating venv for shell [$(CURRENT_SHELL)]"
	@echo "please exec the current command: "
	@echo "------------>"
	@if [[ "$(CURRENT_SHELL)" == "fish" ]]; then \
		echo $(VENV_ACTIVATE_FISH_CMD); \
	else \
		echo $(VENV_ACTIVATE_OTHER_CMD); \
	fi
	@echo "<------------"

.PHONY: echo-venv-activate-cmd
echo-venv-activate-cmd: SHELL := $(WHICH_BASH)
echo-venv-activate-cmd: ## ▶ Echo the command to use to activate the venv
	@if [[ "$(CURRENT_SHELL)" == "fish" ]]; then \
		echo $(VENV_ACTIVATE_FISH_CMD); \
	else \
		echo $(VENV_ACTIVATE_OTHER_CMD); \
	fi

.PHONY: check-venv-is-ready
check-venv-is-ready: ## Check if venv is ready
	echo "+ $@"

.PHONY: check-venv-is-activated
check-venv-is-activated: ## Check if venv is activated 👻
	@echo "+ $@"
ifndef VENV_ACTIVATED
	$(error "venv does not seem to be activated, please activate it with 'make activate-venv'")
endif
	@echo "venv activated (and that's a good news)"
	@echo "Running venv from [${VIRTUAL_ENV}]"

.PHONY: exit-venv
exit-venv: check-venv-is-activated ## Exit venv (deactivate) 👋
	@echo "+ $@"
	@echo "Please exec the command:"
	@echo "deactivate"

.PHONY: poetry-lock
poetry-lock: ## ▶ Update poetry lockfile
	@echo "+ $@"
	@poetry lock

.PHONY: generate-requirements-file
generate-requirements-file: ## ▶ Generare the requirements.txt file from poetry.lock reference
	@echo "+ $@"
	poetry export --format=requirements.txt --with dev --without-hashes --output=requirements.txt;

.PHONY: update-requirements-file
update-requirements-file: SHELL := $(WHICH_BASH)
update-requirements-file: poetry-lock generate-requirements-file ## ▶ Update dependencies (poetry.lock and requirements.txt)
	@echo "+ $@"

.PHONY: install-requirements
install-requirements: SHELL := $(WHICH_BASH)
install-requirements: ## ▶ Install requirements in a single command
	@echo "+ $@"
ifeq ($(POETRY_INSTALL_SYNC_OPT),true)
	$(eval POETRY_INSTALL_SYNC_OPT_STRING = --sync)
else
	$(eval POETRY_INSTALL_SYNC_OPT_STRING = )
endif
	poetry install $(POETRY_INSTALL_SYNC_OPT_STRING)
