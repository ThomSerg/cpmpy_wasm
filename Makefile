
PYTHON_VERSION = 3.12.7
VENV_DIR = .venv
REQUIREMENTS = requirements.txt
BRANCH_NAME = pumpkin
DIST_DIR = dist
WHEEL_DIR = build
CPMPY_PATCH_FILE = patches/cpmpy.patch
PUMPKIN_PATH_FILE = patches/pumpkin.patch
TEST_PORT = 8000

all:
	$(MAKE) init
	$(MAKE) compile

init:
	$(MAKE) init-venv
	$(MAKE) install-pyodide
	$(MAKE) setup-pyodide
	$(MAKE) install-emsdk
	$(MAKE) install-cpmpy
	$(MAKE) install-pumpkin
	$(MAKE) install-rust
	$(MAKE) copy-packages

compile:
	$(MAKE) build-cpmpy
	$(MAKE) build-pumpkin
	$(MAKE) collect-wheels

test:
	$(VENV_DIR)/bin/python -m http.server $(TEST_PORT)


init-venv:
	@if command -v pyenv > /dev/null; then \
		echo "Using pyenv to manage Python version..."; \
		if ! pyenv versions --bare | grep -q "^$(PYTHON_VERSION)$$"; then \
			echo "Installing Python $(PYTHON_VERSION) via pyenv..."; \
			pyenv install $(PYTHON_VERSION); \
		fi; \
		pyenv local $(PYTHON_VERSION); \
		PYTHON_BIN=$$(pyenv which python); \
	else \
		echo "pyenv not found, checking for system python$(PYTHON_VERSION)..."; \
		if ! command -v python$(PYTHON_VERSION) > /dev/null; then \
			echo "Python $(PYTHON_VERSION) not found. Please install it manually or use pyenv."; \
			exit 1; \
		fi; \
		PYTHON_BIN=$$(command -v python$(PYTHON_VERSION)); \
	fi; \
	if [ ! -d "$(VENV_DIR)" ]; then \
		echo "Creating virtual environment in $(VENV_DIR)..."; \
		$$PYTHON_BIN -m venv $(VENV_DIR); \
	else \
		echo "Virtual environment already exists at $(VENV_DIR), skipping creation."; \
	fi; \
	echo "Installing uv into virtual environment..."; \
	$(VENV_DIR)/bin/python -m pip install --upgrade pip; \
	$(VENV_DIR)/bin/pip install uv; \
	echo "Installing dependencies with uv..."; \
	$(VENV_DIR)/bin/uv pip install -r $(REQUIREMENTS) --no-cache

setup-pyodide:
	$(VENV_DIR)/bin/uv run --no-cache -- pyodide xbuildenv install 0.27.7

install-emsdk:
	@if [ ! -d "external/cpmpy" ]; then \
		cd external;\
		git clone https://github.com/emscripten-core/emsdk;\
		cd emsdk;\
		./emsdk install 3.1.58;\
		./emsdk activate 3.1.58;\
		. ./emsdk_env.sh;\
		which emcc;\
	else \
		echo "pass";\
	fi

install-rust:
	export CARGO_HOME=./.cargo;\
	export RUSTUP_HOME=./.rustup;\
	curl https://sh.rustup.rs -sSf | sh -s -- -y;\

install-cpmpy:
	@mkdir -p external
	@if [ ! -d "external/cpmpy" ]; then \
		echo "Cloning cpmpy..."; \
		cd external && git clone https://github.com/cpmpy/cpmpy.git; \
	else \
		echo "cpmpy already exists, skipping clone."; \
	fi

	@cd external/cpmpy && \
	current_branch=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$current_branch" != "$(BRANCH_NAME)" ]; then \
		echo "Checking out branch $(BRANCH_NAME)..."; \
		git checkout $(BRANCH_NAME); \
	else \
		echo "Already on branch $(BRANCH_NAME), skipping checkout."; \
	fi

	@cd external/cpmpy && \
	if git apply --check ../../$(CPMPY_PATCH_FILE); then \
		echo "Applying patch $(CPMPY_PATCH_FILE)..."; \
		git apply ../../$(CPMPY_PATCH_FILE); \
	else \
		echo "Patch $(CPMPY_PATCH_FILE) could not be applied cleanly. Skipping or manual review needed."; \
	fi

install-pyodide:
	@if [ ! -d "external/pyodide" ]; then \
		echo "Cloning pyodide..."; \
		cd external;\
		git clone https://github.com/pyodide/pyodide.git; \
	else \
		echo "pyodide already exists, skipping clone."; \
	fi

install-pumpkin:
	@mkdir -p external
	@if [ ! -d "external/Pumpkin" ]; then \
		echo "Cloning pumpkin..."; \
		cd external && git clone https://github.com/ConSol-Lab/Pumpkin.git; \
	else \
		echo "pumpkin already exists, skipping clone."; \
	fi

	@cd external/Pumpkin && \
	if git apply --check ../../$(PUMPKIN_PATCH_FILE); then \
		echo "Applying patch $(PUMPKIN_PATCH_FILE)..."; \
		git apply ../../$(PUMPKIN_PATCH_FILE); \
	else \
		echo "Patch $(PUMPKIN_PATCH_FILE) could not be applied cleanly. Skipping or manual review needed."; \
	fi

	@cp rust-toolchain.toml external/Pumpkin/pumpkin-solver-py/

copy-packages:
	echo "Copying packages..."; \
	cp -r external/pyodide/packages/* ./packages/; \
	rm -r ./packages/test;\


build-cpmpy:
	cd external/emsdk;\
	. ./emsdk_env.sh;\
	cd ../..;\
	export XDG_CACHE_HOME=./cache;\
	$(VENV_DIR)/bin/uv --no-cache run pyodide build-recipes cpmpy --recipe-dir ./packages/ --install;\


build-pumpkin:
	cd external/emsdk;\
	. ./emsdk_env.sh;\
	cd ../..;\
	export XDG_CACHE_HOME=./cache;\
	export MATURIN_TARGET=wasm32-unknown-unknown;\
	export CARGO_BUILD_TARGET=wasm32-unknown-unknown;\
	export CARGO_HOME=./.cargo;\
	export MATURIN_PEP517_ARGS="--target wasm32-unknown-emscripten";\
	export RUSTUP_HOME=./.rustup;\
	cd external/Pumpkin/pumpkin-solver-py;\
	. ../../../$(VENV_DIR)/bin/activate;\
	rustup target add wasm32-unknown-emscripten;\
	pyodide build;\

collect-wheels:
	@if [ ! -d "$(WHEEL_DIR)" ]; then \
		echo "Creating directory $(WHEEL_DIR)..."; \
		mkdir -p "$(WHEEL_DIR)"; \
	else \
		echo "Directory $(WHEEL_DIR) already exists, skipping."; \
	fi

	cp external/Pumpkin/pumpkin-solver-py/dist/* $(DIST_DIR)/
	$(VENV_DIR)/bin/python rename-tags.py --src-dir $(DIST_DIR) --tgt-dir $(WHEEL_DIR)/
