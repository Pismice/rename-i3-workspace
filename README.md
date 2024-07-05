# Change i3 workspace name blazingly fast ⚡🚀
## Installation
### 1. Clone the repository
```bash
git clone https://github.com/Pismice/rename-i3-workspace
```

### 2. Build it using Zig 0.12.0
Might work with other Zig versions but that is unlikely.
```bash
zig build
```

### 3. Move the binary to your PATH
```bash
mv ./zig-out/bin/rename-i3-workspace /usr/local/bin
```

## Usage
Now from anywhere in your system, you can from your terminal use *rename-i3-workspace*.

This script takes 2 parameters:
1. The workspace number you want to change
2. The new name of the workspace

Exemple:
You had a workspace named "1: Terminal" or even "1" and you want to change it to "1: Code"
```bash
rename-i3-workspace 1 Code
```

## Comparaison between Python, Bash and Zig
You can find the [comparaisons between the solutions](https://pismice.github.io/HEIG_ZIG/docs/scripting/) I did.

## Possible improvements
- [ ] Check the arguments passed to the program
- [ ] Add the possibility to rename a workspace to a multi-word name
- [ ] Nicer looking codes, using comptime to read the structure instead of raw going after specific chains of character :)

## Alternative(s)
For education purposes, I have also implemented this in Python. You can find it in the *other* folder.
