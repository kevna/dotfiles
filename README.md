# github.com/kevna/dotfiles

lakevna's dotfiles, managed with [`chezmoi`](https://github.com/twpayne/chezmoi).

Install the [latest chezmoi release](https://github.com/twpayne/chezmoi/releases/latest), initialise the source directory with this repo and apply the config files in one command:
```
sh -c "$(curl -fsLS git.io/chezmoi)" -- init kevna --apply
```
WARNING: this will clobber any exsting config files, to merge them instead drop `--apply` and use chezmoi commands to merge/apply the configuration manually.
