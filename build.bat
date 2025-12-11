@zig build-exe -O ReleaseSmall "%~dp0src/main.zig"
@md "%~dp0out" 2>nul
@move /y .\main.exe "%~dp0out" 1>nul
@move /y .\main.pdb "%~dp0out" 1>nul 2>nul
