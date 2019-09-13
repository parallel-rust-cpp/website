SHELL=bash
GH_PAGES_REPO='../parallel-rust-cpp.github.io'
VALID_GH_PAGES_REMOTE='git@github.com:parallel-rust-cpp/parallel-rust-cpp.github.io.git'

.PHONY: deploy all build

all: build
deploy: build commit-gh-pages
build:
	mdbook build
commit-gh-pages:
	@echo "====> deploying to github"
	cp --recursive --remove-destination --no-target-directory book /tmp/book
	cd $(GH_PAGES_REPO) &&\
	if [[ ! "$$(git remote get-url $$(git remote))" =~ $(VALID_GH_PAGES_REMOTE) ]]; then\
		echo "error, $(GH_PAGES_REPO) is not the expected github pages repo";\
		exit 1;\
	fi &&\
	if [ "$$(git log --oneline | wc -l)" -gt 2 ]; then\
		echo "error, this repo has suspiciously many commits";\
		exit 1;\
	fi &&\
	git reset --hard HEAD~1 &&\
	cp --recursive --remove-destination --no-target-directory /tmp/book . &&\
	git add --all &&\
	git commit --message "auto-deploy at $$(date --utc)" &&\
	git push --force gh-pages master
