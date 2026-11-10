# Randomix for Linux — developer entry points.
#
# The Flutter SDK lives in .tooling/ and every toolchain write stays inside the
# repository: sourcing tool/env.sh is all that is needed.
SHELL := /bin/bash
ENV := source tool/env.sh &&
FLUTTER := $(ENV) flutter

.PHONY: help bootstrap sysroot run test analyze format build bundle deb flatpak flatpak-run clean distclean

help:
	@echo "make bootstrap   load dependencies"
	@echo "make run         run the app from source"
	@echo "make test        run the test suite"
	@echo "make analyze     run the static analyzer"
	@echo "make build       build the Linux release bundle"
	@echo "make deb         build dist/randomix_<version>-1_<arch>.deb"
	@echo "make flatpak     build and install the Flatpak (user installation)"
	@echo "make flatpak-run launch the installed Flatpak"
	@echo "make clean       remove build output"

bootstrap:
	$(ENV) flutter pub get

# Only needed when the GTK/GStreamer -dev packages cannot be installed.
sysroot:
	bash tool/setup-sysroot.sh

run:
	$(FLUTTER) run -d linux

test:
	$(FLUTTER) test

analyze:
	$(FLUTTER) analyze

format:
	$(ENV) dart format lib test

build:
	$(FLUTTER) build linux --release

# The deb and flatpak targets call the release build themselves through Make.
deb: build
	bash packaging/deb/build-deb.sh

flatpak: build
	bash packaging/flatpak/build-flatpak.sh

flatpak-run:
	flatpak run io.github.thenobody0817.Randomix

clean:
	$(ENV) flutter clean
	rm -rf build/deb build/flatpak-build build/flatpak-repo

distclean: clean
	rm -rf dist .tooling
