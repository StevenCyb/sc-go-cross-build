# sc-go-cross-build
A golang cross build docker action. 

## Inputs

### `github-token`
**Required** Set this to `${{ secrets.GITHUB_TOKEN }}`.

### `platform`
**Required** The platform (GOOS and GOARCH), choose one of:
* aix: `aix/ppc64`
* android: `android/386` `android/amd64` `android/arm` `android/arm64`
* darwin: `darwin/amd64` `darwin/arm64`
* dragonfly: `dragonfly/amd64`
* freebsd: `freebsd/386` `freebsd/amd64` `freebsd/arm` `freebsd/arm64`
* illumos: `illumos/amd64`
* ios: `ios/amd64` `ios/arm64`
* js: `js/wasm`
* linux: `linux/386` `linux/amd64` `linux/arm` `linux/arm64` `linux/mips` `linux/mips64` `linux/mips64le` `linux/mipsle` `linux/ppc64` `linux/ppc64le` `linux/riscv64` `linux/s390x`
* netbsd: `netbsd/386` `netbsd/amd64` `netbsd/arm` `netbsd/arm64`
* openbsd: `openbsd/386` `openbsd/amd64` `openbsd/arm` `openbsd/arm64` `openbsd/arm64` `openbsd/mips64`
* plan9: `plan9/386` `plan9/amd64` `plan9/arm`
* solaris: `solaris/amd64`
* windows: `windows/386` `windows/amd64` `windows/arm`

There may be some more. Run `go tool dist list` to get a list of supported platforms.

### `include-files`
**Optional** A comma separated list of files that should be included in release archive, e.g. `"README.md LICENSE"`.

## Example usage
```yaml
# Only work on publish (otherwise no upload URL is provided by Github events)
on:
  release:
    types: [published]

jobs:
  release-linux-386:
    name: release linux/386
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Compile and upload release
      uses: StevenCyb/sc-go-cross-build@0.1.0
      with: 
        github-token: ${{ secrets.GITHUB_TOKEN }}
        platform: "linux/386"
        include-files: "README.md"
  release-linux-amd64:
    name: release linux/amd64
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Compile and upload release
      uses: StevenCyb/sc-go-cross-build@0.1.0
      with: 
        github-token: ${{ secrets.GITHUB_TOKEN }}
        platform: "linux/amd64"
        include-files: "README.md"
  release-linux-arm:
    name: release linux/arm
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Compile and upload release
      uses: StevenCyb/sc-go-cross-build@0.1.0
      with: 
        github-token: ${{ secrets.GITHUB_TOKEN }}
        platform: "linux/arm"
        include-files: "README.md"
  release-windows-386:
    name: release windows/386
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Compile and upload release
      uses: StevenCyb/sc-go-cross-build@0.1.0
      with: 
        github-token: ${{ secrets.GITHUB_TOKEN }}
        platform: "windows/386"
        include-files: "README.md"
  release-windows-amd64:
    name: release windows/amd64
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Compile and upload release
      uses: StevenCyb/sc-go-cross-build@0.1.0
      with: 
        github-token: ${{ secrets.GITHUB_TOKEN }}
        platform: "windows/amd64"
        include-files: "README.md"
```