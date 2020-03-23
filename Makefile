SHELL:=/usr/bin/env bash
VENV=~/.local/share/venv/spark
PYTHON_REQUIREMENTS=dev/requirements.txt
RENV=~/.local/share/renv
RENV_LOCK=dev/renv.lock

clean:
	@echo "Removing Python venv $(VENV)"
	$(VENV)/bin/deactivate
	rm -rf $(VENV)
	@echo "Removing R renv $(RENV)"

python-setup:
	@echo "Installing Python venv to $(VENV)"
	sudo apt-get install -y python3-venv
	python3 -m venv $(VENV)
	@echo "Installing Python packages from $(PYTHON_REQUIREMENTS)"
	source $(VENV)/bin/activate \
		&& python -m pip install --upgrade pip \
		&& python -m pip install -r $(PYTHON_REQUIREMENTS)

R-setup:
	@echo "Installing R"
	echo 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/' | sudo tee -a /etc/apt/sources.list
	curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xE298A3A825C0D65DFD57CBB651716619E084DAB9" | sudo apt-key add
	sudo apt-get update
	sudo apt-get install -y r-base r-base-dev libcurl4-openssl-dev

	@echo "Installing R packages"
	sudo Rscript -e "install.packages('renv')"
	sudo Rscript -e "renv::consent(provided = TRUE)"
	sudo Rscript -e "renv::restore(lockfile = '$(RENV_LOCK)')"

dev-setup: python-setup R-setup

test-dependencies: dev-setup
	source $(VENV)/bin/activate && \
		./dev/test-dependencies.sh

test: dev-setup
	export MAVEN_OPTS="-Xmx2g -XX:ReservedCodeCacheSize=1g"
	source $(VENV)/bin/activate && \
		./dev/run-tests

install:
	./build/mvn -DskipTests clean install

.PHONY: test dev-setup R-setup python-setup install
