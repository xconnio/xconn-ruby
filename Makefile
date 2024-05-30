build-docs:
	mkdir -p site/xconn/
	mkdocs build -d site/xconn/ruby

run-docs:
	mkdocs serve

clean-docs:
	rm -rf site/
