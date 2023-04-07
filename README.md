# TeXFindPkg tool for installing TeX packages

```
Description: Install TeX packages and their dependencies
Copyright: 2023 (c) Jianrui Lyu <tolvjr@163.com>
Repository: https://github.com/lvjr/texfindpkg
License: GNU General Public License v3.0
```

## Introduction

TeXFindPkg makes it easy to install TeX packages and their dependencies by file names, command names or environment names.

- To install a package by its file name you can run `texfindpkg install array.sty`;
- To install a package by some command name you can run `texfindpkg install \fakeverb`;
- To install a package by some environment name you can run `texfindpkg install {frame}`.

TeXFindPkg supports both TeXLive and MiKTeX distributions. At present it focuses mainly on LaTeX packages,
but may extend to ConTeXt packages if anyone would like to contribute.

## Installation

Your TeX distribution should have created a binary file `texfindpkg` when you install this package.
If not, you could create a symbolic link from `/usr/local/bin/texfindpkg` to `texfindpkg.lua` on Linux or MacOS,
or create a batch file `texfindpkg.bat` in binary folder of the TeX distribution with these lines on Windows:

```
@echo off
texlua path\to\texfindpkg.lua %*
```

## Usage

```
texfindpkg <action> [<options>] [<name>]
```

where `<action>` could be `install` or `query`, and `<name>` could be file name, command name or environment name.
For example:

```
texfindpkg install array.sty
texfindpkg install \fakeverb
texfindpkg install {frame}
texfindpkg query array.sty
texfindpkg query \fakeverb
texfindpkg query {frame}
```

## Building

TeXFindPkg uses completion files of TeXstudio editor which are in `completion` folder of TeXstudio [repository](https://github.com/texstudio-org/texstudio).

After putting `completion` folder into current folder, you can run `texlua texfindpkg.lua generate` to generate `texfindpkg.json` and `texfindpkg.json.gz` files.

## Contributing

Any updates of dependencies, commands or environments for packages should be contributed directly to TeXstudio project.
