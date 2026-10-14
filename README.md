# LSP Plugins for Windows

This repository builds the official LSP Plugins source release on a Blacksmith 2-vCPU Windows runner with the MinGW-w64 toolchain.

The workflow downloads the source archive linked from the [official download page](https://lsp-plug.in/?page=download&section=source), builds the CLAP, LADSPA, LV2, VST2, and VST3 plugins with UI support, bundles `libwinpthread-1.dll` from MinGW, then publishes the generated `INSTALL` directory as a GitHub Actions artifact. It omits HTML documentation, so PHP is not required.

Pushes to `main` and pull requests build version 1.2.35 with LLVM/Clang by default. Publishing a GitHub release runs the build for its tag version (with an optional leading `v`). The job uses two parallel build tasks to match the runner's vCPU count. ccache is saved between runs for the same toolchain and source release. To build another source release or select GCC, run **Build LSP Plugins for Windows** from the Actions tab and choose the release version and toolchain. The resulting x86_64 plugin bundle is available under the run's **Artifacts** section.
