all:
	chezmoi apply

install-packages:
	pip3 install --user $(shell grep -v '^#' pip_packages.list)
	sudo apt-get install --no-install-recommends $(shell grep -v '^#' apt_packages.list)

update-third-party: \
	update-victormono

tmpfile := $(shell mktemp -d)
update-victormono:
	curl -sLo ${tmpfile}/victormono.zip https://rubjo.github.io/victor-mono/VictorMonoAll.zip
	unzip ${tmpfile}/victormono.zip -d ${tmpfile}
	cp ${tmpfile}/OTF/* $(shell chezmoi source-path ~/.local/share/fonts/victormono)
	rm -r ${tmpfile}

font-cache:
	fc-cache -fv
	sudo fc-cache -fv
