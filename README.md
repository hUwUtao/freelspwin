# LSP Plugins for Windows

This repository builds the official LSP Plugins source release on a GitHub-hosted Windows runner with the MinGW-w64 toolchain.

The workflow downloads the source archive linked from the [official download page](https://lsp-plug.in/?page=download&section=source), builds the CLAP, LADSPA, LV2, VST2, and VST3 plugins with UI support, then publishes the generated `INSTALL` directory as a GitHub Actions artifact. It omits HTML documentation, so PHP is not required.

Pushes to `main` and pull requests build version 1.2.35. To build another source release, run **Build LSP Plugins for Windows** from the Actions tab and provide its release version. The resulting x86_64 plugin bundle is available under the run's **Artifacts** section.
