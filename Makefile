project_name = BSGMetrics
project_version = DEVELOP
project_company = Bootstragram
company_id = com.bootstragram

.PHONY: install

install:
	bundle install
	bundle exec pod install --project-directory=Example

open:
	open Example/BSGMetrics.xcworkspace

start-services:
	ruby Server/listen-secure.rb

upgrade:
	bundle update
	bundle exec pod repo update
	bundle exec pod update --project-directory=Example

# install with `brew install appledoc`
doc:
	appledoc \
	--verbose 2 \
	--output ./doc \
	--ignore Pods \
	--ignore .m \
	--project-name $(project_name) \
	--project-version $(project_version) \
	--keep-undocumented-objects \
	--keep-undocumented-members \
	--project-company $(project_company) \
	--company-id $(company_id) \
	--no-repeat-first-par \
	--no-create-docset \
	--create-html \
	--index-desc README.md \
	BSGMetrics/Classes
