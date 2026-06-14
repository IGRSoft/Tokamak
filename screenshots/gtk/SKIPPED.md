# gtk screenshots — SKIPPED

**Status:** skipped (best-effort phase, AC-6).
**Reason:** the GTK4 capture runs inside Docker + Xvfb (Linux toolchain). This host is
macOS; building/running `TokamakGTKDemo` natively needs GTK4 + pkg-config which are not
present, and the Docker GTK image build + Xvfb capture exceeds the best-effort time
budget for this run. (A Docker daemon binary exists at /usr/local/bin/docker, but the
GTK4 image is not built and the renderer is incomplete by design — see UNSUPPORTED.md.)

## How to produce gtk screenshots

```sh
# from the repo root, with a running Docker daemon:
bash Scripts/screenshots/gtk-docker.sh
# -> builds a Linux+GTK4+Xvfb image, runs TokamakGTKDemo, captures each window with
#    ImageMagick `import` into screenshots/gtk/<name>.png
```

`Scripts/screenshots/generate.sh gtk` pre-flights the Docker daemon and writes this
SKIPPED.md if it is unavailable. `Scripts/screenshots/gtk-docker.sh` is committed.
