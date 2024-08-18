# Issues may occurs


## nvim-treesitter 
### error when compilation
- The treesitter need gcc, clang... to compile lib for languages.
1. install LLVM (clang)
```powershell
winget install LLVM
```
2. set $PATH environment variable. LLVM usually installed in "Program Files\LLVM"
- Sometimes LLVM will not work (windows 11, nvim v0.10.1). 
You can try using x64devkit (gcc)
1. downloads from github https://github.com/skeeto/w64devkit
2. extract to folder
3. set $PATH environment variable



