build-docs:
	mkdir -p site/xconn/
	mkdocs build -d site/xconn/dart

run-docs:
	mkdocs serve

clean-docs:
	rm -rf site/
