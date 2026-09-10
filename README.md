# fuzin - Package Manager Wrapper

A lightning-fast, cross-platform terminal wrapper that unifies package management under a single, interactive fuzzy-finding interface.


<table width="100%">
  <tr>
  <td width="50%" align="center">
      <b> Linux </b><br><br>
      <img src="img/linux-demo.gif" width="100%" alt="Linux Demo">
    </td>
    <td width="50%" align="center">
      <b> MacOS </b><br><br>
      <img src="img/macos-demo.gif" width="100%" alt="macOS Demo">
    </td>
  </tr>
</table>

## Features

* **Auto-Detection:** Seamlessly adapts to `apt`, `pacman`, `dnf`, `zypper`, or `brew` without any configuration required on your end.
* **Multiple Selection:** Select multiple packages by pressing `TAB`.
* **Live Previews:** Instantly view package details before installing, directly within the terminal split-screen.
* **AUR Support:** Automatically prompts Arch Linux users to search the AUR (via `yay` or `paru`) if a package isn't found in the official repositories.
* **macOS Integration:** Unifies Homebrew `formulae` and `casks` into a single, searchable list.
* **Zero Dependencies:** A standalone Bash script. If `fzf` is missing on your system, it automatically detects it and offers to install it for you.

## Usage

```bash
# Auto-detect the package manager and install packages
fuzin
fuzin -i
fuzin --install

# Auto-detect the package manager and remove packages
fuzin -r
fuzin --remove

# Use yay
fuzin -y
fuzin --yay
fuzin -r -y

# Use paru
fuzin -p
fuzin --paru
fuzin -r -p

# Show help
fuzin -h
fuzin --help
```

`--yay` and `--paru` can be combined with `--install` or `--remove`.

## Installation

```bash
git clone https://github.com/Deniz-13/fuzin.git
cd fuzin
chmod +x fuzin
sudo mv fuzin /usr/local/bin/fuzin
```
