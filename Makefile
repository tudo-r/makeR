R	:= R --no-save --no-restore
RSCRIPT	:= Rscript
DELETE	:= rm -fR
PKGNAME := $(shell Rscript ./makeR/get-pkg-name)
VERSION := $(shell Rscript ./makeR/get-pkg-version)
TARGZ   := $(PKGNAME)_$(VERSION).tar.gz

.SILENT:
.PHONEY: clean roxygenize package windows install test check

usage:
	echo "Available targets:"
	echo ""
	echo " clean         - Clean everything up"
	echo " roxygenize    - roxygenize in-place"
	echo " package       - build source package"
	echo " install       - install the package"
	echo " depenencies   - install package dependencies, including suggests"
	echo " test          - run unit tests"
	echo " check         - run R CMD check on the package"
	echo " check-rev-dep - run a reverse dependency check against packages on CRAN"
	echo " html          - build static html documentation"
	echo " winbuilder    - ask for email and build on winbuilder"

clean:
	printf  "\nCleaning up ...\n"
	${DELETE} src/*.o src/*.so *.tar.gz
	${DELETE} html
	${DELETE} staticdocs
	${DELETE} *.Rcheck
	${DELETE} .RData .Rhistory

roxygenize: clean
	printf "\nRoxygenizing package ...\n"
	${RSCRIPT} ./makeR/roxygenize

package: roxygenize
	printf "\nBuilding package file $(TARGZ)\n"
	${R} CMD build .

install: package
	printf "\nInstalling package $(TARGZ)\n"
	${R} CMD INSTALL $(TARGZ)

test: install
	printf "\nTesting package $(TARGZ)\n"
	${RSCRIPT} ./test_all.R

check: package
	printf "\nRunning R CMD check ...\n"
	${R} CMD check $(TARGZ)

dependecies:
	${RSCRIPT} ./makeR/dependencies

check-rev-dep: package
	printf "\nRunning reverse dependency checks for CRAN ...\n"
	${RSCRIPT} ./makeR/check-rev-dep

htmlhelp: install
	printf "\nGenerating html docs...\n"
	mkdir staticdocs
	${DELETE} /tmp/pkgdocs
	mkdir /tmp/pkgdocs
	mv README.md README.xxx
	${RSCRIPT} ./makeR/generate-html-docs
	mv README.xxx README.md
	${DELETE} Rplots*.pdf
	git checkout gh-pages
	${DELETE} man
	mv /tmp/pkgdocs man
	git add man
	git commit -am "new html help"
	git push origin gh-pages
	git checkout master

winbuilder: roxygenize
	printf "\nBuilding via winbuilder\n"
	${RSCRIPT} ./makeR/winbuilder

