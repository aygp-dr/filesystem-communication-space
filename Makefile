# Makefile for Filesystem Communication Space
# Handles tangling org files, running experiments, and generating diagrams

.PHONY: all tangle experiments benchmark diagrams clean help pdf readme fifo-demo

# Default target
all: README.md tangle diagrams

# Help target
help:
	@echo "Available targets:"
	@echo "  all         - Generate README.md, tangle code and generate diagrams (default)"
	@echo "  tangle      - Extract source code from org files"
	@echo "  experiments - Run all experiments"
	@echo "  fifo-demo   - Run FIFO communication demo with Node.js"
	@echo "  benchmark   - Run performance benchmarks"
	@echo "  diagrams    - Generate Mermaid diagrams"
	@echo "  pdf         - Generate PDF documentation"
	@echo "  readme      - Generate README.md from README.org"
	@echo "  clean       - Remove generated files"
	@echo "  help        - Show this help message"

# Convenience target for README
readme: README.md

# Generate PDF documentation
filesystem-communication-space.pdf: filesystem-communication-space.org
	@echo "Generating PDF documentation..."
	@emacs --batch \
		--load publish-config.el \
		--eval "(org-open-file \"filesystem-communication-space.org\")" \
		--eval "(org-latex-export-to-pdf)" \
		--kill
	@echo "PDF generation complete!"

# Convenience target for PDF
pdf: filesystem-communication-space.pdf

# Generate README.md from README.org for uv/pip compatibility
README.md: README.org
	@echo "Generating README.md from README.org..."
	@emacs --batch \
		--eval "(require 'org)" \
		--eval "(require 'ox-md)" \
		--visit="$<" \
		--eval "(org-md-export-to-markdown)" \
		--kill
	@echo "README.md generation complete!"

# Tangle all org files to extract source code
tangle:
	@echo "Tangling source code from org files..."
	@for file in *.org; do \
		if [ -f "$$file" ]; then \
			echo "Processing $$file..."; \
			emacs --batch \
				--eval "(require 'org)" \
				--eval "(setq org-babel-python-command \"python3\")" \
				--eval "(setq org-confirm-babel-evaluate nil)" \
				--eval "(org-babel-tangle-file \"$$file\")"; \
		fi; \
	done
	@echo "Tangling complete!"

# Run all experiments
experiments: tangle
	@echo "Running experiments..."
	@if [ -d "experiments" ]; then \
		for script in experiments/*.py; do \
			if [ -f "$$script" ] && [ -x "$$script" ]; then \
				echo "Running $$script..."; \
				python3 "$$script" || true; \
			fi; \
		done; \
	fi
	@echo "Experiments complete!"

# Run FIFO instrumentation experiments
fifo-demo:
	@echo "Running FIFO communication demo..."
	@if [ -f "instrumented/demo-summary.sh" ]; then \
		bash instrumented/demo-summary.sh; \
	fi
	@echo "FIFO demo complete!"

# Run benchmarks
benchmark: tangle
	@echo "Running benchmarks..."
	@if [ -f "experiments/benchmark_ipc.py" ]; then \
		python3 experiments/benchmark_ipc.py; \
	fi
	@if [ -f "experiments/measure_throughput.py" ]; then \
		python3 experiments/measure_throughput.py; \
	fi
	@echo "Benchmarks complete!"

# Generate Mermaid diagrams
diagrams:
	@echo "Generating Mermaid diagrams..."
	@mkdir -p diagrams
	@for file in *.org; do \
		if [ -f "$$file" ]; then \
			echo "Extracting diagrams from $$file..."; \
			emacs --batch \
				--eval "(require 'org)" \
				--eval "(setq org-confirm-babel-evaluate nil)" \
				--eval "(require 'ob-mermaid)" \
				--eval "(org-babel-execute-buffer)" \
				--visit="$$file" \
				2>/dev/null || true; \
		fi; \
	done
	@echo "Diagram generation complete!"

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf experiments/ patterns/ analysis/ security/ core/
	@rm -f diagrams/*.png diagrams/*.svg
	@find . -name "*.pyc" -delete
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@rm -f *.tex *.log *.aux *.out *.toc *.lof *.lot
	@echo "Clean complete!"

# Install dependencies (optional)
install-deps:
	@echo "Checking dependencies..."
	@command -v emacs >/dev/null 2>&1 || { echo "Emacs is required but not installed. Aborting." >&2; exit 1; }
	@command -v python3 >/dev/null 2>&1 || { echo "Python 3 is required but not installed. Aborting." >&2; exit 1; }
	@echo "Installing Python dependencies..."
	@pip3 install --user matplotlib numpy psutil || true
	@echo "Dependencies installed!"

# Variables for customization
EMACS ?= emacs
PYTHON ?= python3

# Pattern rules for individual file processing
%.tangle: %.org
	$(EMACS) --batch \
		--eval "(require 'org)" \
		--eval "(setq org-babel-python-command \"$(PYTHON)\")" \
		--eval "(setq org-confirm-babel-evaluate nil)" \
		--eval "(org-babel-tangle-file \"$<\")"

# Create directory structure
setup-dirs:
	@mkdir -p experiments patterns analysis security core diagrams