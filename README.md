# FindPkg tool for installing TeX packages

```
Description: Install TeX packages and their dependencies
Copyright: 2023 (c) Jianrui Lyu <tolvjr@163.com>
Repository: https://github.com/lvjr/findpkg
License: GNU General Public License v3.0
```

## Introduction

FindPkg makes it easy to install TeX packages and their dependencies by file names, command names or environment names.

- To install a package by its file name you can run `texlua findpkg.lua install array.sty`;
- To install a package by some command name you can run `texlua findpkg.lua install \fakeverb`;
- To install a package by some environment name you can run `texlua findpkg.lua install {frame}`.

FindPkg supports both TeXLive and MiKTeX distributions. At present it focuses mainly on LaTeX packages, but may extend to ConTeXt packages if anyone would like to contribute.

## Building

FindPkg uses completion files of TeXstudio editor which are in `completion` folder of TeXstudio [repository](https://github.com/texstudio-org/texstudio).

After putting `completion` folder into current folder, you can run `texlua findpkg.lua generate` to generate `findpkg.json` file.

## Contributing

Any updates of dependencies, commands or environments for packages should be contributed directly to TeXstudio project.
