
PYTHON_VERSION = 3.12.9
VENV_DIR = .venv

init-venv:
	@if command -v pyenv > /dev/null; then \
		echo "Using pyenv to manage Python version..."; \
		if ! pyenv versions --bare | grep -q "^$(PYTHON_VERSION)$$"; then \
			echo "Installing Python $(PYTHON_VERSION) via pyenv..."; \
			pyenv install $(PYTHON_VERSION); \
		fi; \
		pyenv local $(PYTHON_VERSION); \
	else \
		echo "pyenv not found, checking for system python$(PYTHON_VERSION)..."; \
		if ! command -v python$(PYTHON_VERSION) > /dev/null; then \
			echo "Python $(PYTHON_VERSION) not found. Please install it manually or use pyenv."; \
			exit 1; \
		fi; \
	fi
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "Creating virtual environment in $(VENV_DIR)..."; \
		python$(PYTHON_VERSION) -m venv $(VENV_DIR); \
	else \
		echo "Virtual environment already exists in $(VENV_DIR), skipping."; \
	fi


install-rust:
	curl https://sh.rustup.rs -sSf | sh -s -- -y

install-cpmpy:
	@if [ ! -d "external/cpmpy" ]; then \
		echo "Cloning cpmpy..."; \
		cd external;\
		git clone https://github.com/cpmpy/cpmpy.git; \
	else \
		echo "cpmpy already exists, skipping clone."; \
	fi

install-pyodide:
	@if [ ! -d "external/pyodide" ]; then \
		echo "Cloning pyodide..."; \
		cd external;\
		git clone https://github.com/pyodide/pyodide.git; \
	else \
		echo "pyodide already exists, skipping clone."; \
	fi
	# @if [ ! -d "./packages" ]; then \
	# 	echo "Copying packages..."; \
	# 	cp -r pyodide/packages ./packages; \
	# else \
	# 	echo "./packages already exists, skipping copy."; \
	# fi