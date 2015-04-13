R	:= R --no-save --no-restore
RSCRIPT	:= Rscript
DELETE	:= rm -fR
PKGNAME := $(shell Rscript ./makeR/get-pkg-name)
VERSION := $(shell Rscript ./makeR/get-pkg-version)
TARGZ   := $(PKGNAME)_$(VERSION).tar.gz

.SILENT:
.PHONEY: clean roxygenize package windows install dependencies test check

usage:
	echo "Available targets:"
	echo ""
	echo " clean          - Clean everything up"
	echo " roxygenize     - roxygenize in-place"
	echo " package        - build source package"
	echo " install        - install the package"
	echo " dependencies   - install package dependencies, including suggests"
	echo " test           - run unit tests"
	echo " check          - run R CMD check on the package"
	echo " check-rev-dep  - run a reverse dependency check against packages on CRAN"
	echo " check-rd-files - run Rd2pdf on each doc file to track hard-to-spot doc/latex errors"
	echo " winbuilder     - ask for email and build on winbuilder"

clean:
	echo  "Cleaning up ..."
	${DELETE} src/*.o src/*.so *.tar.gz
	${DELETE} *.Rcheck
	${DELETE} .RData .Rhistory

roxygenize: clean
	echo "Roxygenizing package ..."
	${RSCRIPT} ./makeR/roxygenize

package: roxygenize
	echo "Building package file $(TARGZ)"
	${R} CMD build .

install: package
	echo "Installing package $(TARGZ)"
	${R} CMD INSTALL --install-tests $(TARGZ)

test: install
	echo "Testing package $(TARGZ)"
	${RSCRIPT} ./test_all.R $(file)

check: package
	echo "Running R CMD check ..."
	${R} CMD check $(TARGZ)

dependencies:
	${RSCRIPT} ./makeR/dependencies

check-rev-dep: install
	echo "Running reverse dependency checks for CRAN ..."
	${RSCRIPT} ./makeR/check-rev-dep

check-rd-files: install
	echo "Checking RDs one by one ..."
	${RSCRIPT} ./makeR/check-rd-files

winbuilder: roxygenize
	echo "Building via winbuilder"
	${RSCRIPT} ./makeR/winbuilder

