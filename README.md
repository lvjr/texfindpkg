# TeXFindPkg tool for querying or installing TeX packages

```
Description: Query or Install TeX packages and their dependencies
Copyright: 2023-2024 (c) Jianrui Lyu <tolvjr@163.com>
Repository: https://github.com/lvjr/texfindpkg
License: GNU General Public License v3.0
```

## 1\. Introduction

TeXFindPkg makes it easy to query or install TeX packages and their dependencies by file names, command names or environment names.
It supports both TeXLive and MiKTeX distributions. At present it focuses mainly on LaTeX packages,
but may extend to ConTeXt packages if anyone would like to contribute.

## 2\. Installation

Normally your TeX distribution will copy TeXFindPkg files and create a binary file `texfindpkg` when you install this package.
If a manual installation is needed, you could copy TeXFindPkg files to TEXMF tree as follows:

| Package file       | Where to install it |
| :------            | :------ |
| texfindpkg.1       | TEXMF/doc/man/man1/texfindpkg.1 |
| README.md          | TEXMF/doc/support/texfindpkg/README.md |
| texfindpkg.lua     | TEXMF/scripts/texfindpkg/texfindpkg.lua |
| texfindpkg.json.gz | TEXMF/tex/latex/texfindpkg/texfindpkg.json.gz |
| tfpbuild.lua       | TEXMF/source/texfindpkg/tfpbuild.lua |

Then you could create a symbolic link from `/usr/local/bin/texfindpkg` to `path/to/texfindpkg.lua` on Linux or MacOS,
or create a batch file `texfindpkg.bat` in binary folder of the TeX distribution with these lines on Windows:

```
@echo off
texlua path\to\texfindpkg.lua %*
```

## 3\. Usage

After installing TeXFindPkg, you can run it by executing

```
texfindpkg <action> [<option>] [<name>]
```

The `<action>` could be `query`, `install`, `help` or `version`.
The leading dashes in any `<action>` will be removed first.

For `query` action, you pass `-f`, `-c` or `-e` as `<option>`
to indicate the following `<name>` is a file name, command name or environment name.
For example,

- `texfindpkg query -f array.sty` means querying package with file `array.sty`;
- `texfindpkg query -c fakeverb` means querying package with command `\fakeverb`;
- `texfindpkg query -e frame` means querying package with environment `{frame}`.

The only difference between `query` and `install` actions is that
with `install` action TeXFindPkg will install missing TeXLive or MiKTeX packages at the end.

With `help` action, TeXFindPkg prints help message and exit.
With `version` action, TeXFindPkg prints version information and exit.

## 4\. Building

TeXFindPkg uses completion files of TeXstudio editor which are in `completion` folder of TeXstudio [repository](https://github.com/texstudio-org/texstudio).

After putting `completion` folder into current folder, you can execute `texlua tfpbuild.lua generate` to generate `texfindpkg.json` and `texfindpkg.json.gz` files.

## 5\. Contributing

Any updates of dependencies, commands or environments for packages should be contributed directly to TeXstudio project.
