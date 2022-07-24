# Sake

A simple static site generator built with make.

>NOTE: No markdown support yet.

# Deps

## make
`make` is used for building everything.
- Official website: https://www.gnu.org/software/make/

`make` can be installed from various distro repos.

## jinja2
`jinja2` is used for processing template files (*.j2).

It's a python library, but I'm using a standalone command-line implementation.
- Official website: https://jinja.palletsprojects.com
- CLI website: https://github.com/mattrobenolt/jinja2-cli

`jinja2-cli` can be installed from source using `pip`:
```shell
pip install jinja2-cli
```

## fd
`fd` is used for finding project resources recursively.

It's an user-friendly alternative to `find`.
- Official website: https://github.com/sharkdp/fd

`fd` can be installed from various distro repos.

It can also be installed from source using `cargo`:
```shell
cargo install fd-find
```

## jq
`jq` is used for parsing JSON data.
- Official website: https://stedolan.github.io/jq/

`jq` can be installed from various distro repos.

## yj
`yj` is used for converting data from YAML to JSON.
- Official website: https://github.com/bruceadams/yj

`yj` can be installed from source using `cargo`:
```shell
cargo install yj
```

# Basic Usage

After installing all deps, just copy/link the `Makefile` to your project directory.

Run `init` task to initialize a sample with basic configs:
```shell
make init
```

Then build the project running the default task:
```shell
make
```

All processed files will be saved to `out/` directory.

# Project Structure

>TODO
