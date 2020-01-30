@echo off
pushd "./build"
for %%f in (*.sln) do (
    start %%f
)
popd
