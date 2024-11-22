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

For `query` action, you pass `-c`, `-e`, `-f` or `-p` as `<option>`
to indicate the following `<name>` is a command name, environment name, file name or package name.
For example (for `-f` option, you can omit file extension in the name if it is `.sty`),
- `texfindpkg query -c fakeverb` means querying package with command `\fakeverb`;
- `texfindpkg query -e frame` means querying package with environment `{frame}`;
- `texfindpkg query -f array.sty` means querying package with file `array.sty`;
- `texfindpkg query -p caption` means querying LaTeX packages in TeXLive/MiKTeX package `caption`.

You can query a lot of names in one go. For example,
```
texfindpkg query -c fakeverb -e verbatim tblr -f array longtable -p caption
```

When you have a lot of names to query, you may want to list them in a file and use `-i` option to insert them.
For example, if you have a file `input.txt` of lines (comments starting with `#` characters are ignored in it)
```
-c
fakeverb
-e
verbatim
tblr
-f
array
longtable
-p
caption
```
then the following command produces the same result as the previous one does:
```
texfindpkg query -i input.txt
```

Furthermore you can save total dependent list of packages to a file with `-o` option:
```
texfindpkg query -i input.txt -o output.txt
```

With `-i` and `-o` options, it is quite easy to install a minimal TeXLive distribution with all dependencies resolved,
which is useful for you to run regression tests with GitHub Actions if you are a package writer.
Please see `latex-package.txt` and `texlive-package.txt` in [tabularray](https://github.com/lvjr/tabularray/tree/main/.github/workflows) repository for a practical example.

The only difference between `query` and `install` actions is that
with `install` action TeXFindPkg will install missing TeXLive or MiKTeX packages at the end.

With `help` action, TeXFindPkg prints help message and exit.
With `version` action, TeXFindPkg prints version information and exit.

## 4\. Building

TeXFindPkg uses completion files of TeXstudio editor which are in `completion` folder of TeXstudio [repository](https://github.com/texstudio-org/texstudio).

After putting `completion` folder into current folder, you can execute `texlua tfpbuild.lua generate` to generate `texfindpkg.json` and `texfindpkg.json.gz` files.

## 5\. Contributing

Any updates of dependencies, commands or environments for packages should be contributed directly to TeXstudio project.
