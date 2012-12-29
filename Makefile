# Copyright (c) Google Inc, 2012
# Author: afshar@google.com (Ali Afshar)

DARTDOC = /usr/local/dart/dart-sdk/bin/dartdoc

doc:
	${DARTDOC} lib/roundtrip.dart
	git push origin --delete gh-pages
	git checkout --orphan gh-pages
	git rm -rf .gitignore lib test Makefile pubspec.yaml README.md
	git commit -m "Docs"
	git push origin gh-pages
	git checkout master
	git branch -D gh-pages
	git commit -a -m "Generated docs."
