# Sake

A simple static site generator built with make.

>NOTE: No markdown support yet.

## Deps

### make
`make` is used for building everything.
- Official website: https://www.gnu.org/software/make/

`make` can be installed from various distro repos.

### jinja2
`jinja2` is used for processing template files (*.j2).

It's a python library, but I'm using a standalone command-line implementation.
- Official website: https://jinja.palletsprojects.com
- CLI website: https://github.com/mattrobenolt/jinja2-cli

`jinja2-cli` can be installed from source using `pip`:
```shell
pip install jinja2-cli
```

### fd
`fd` is used for finding project resources recursively.

It's an user-friendly alternative to `find`.
- Official website: https://github.com/sharkdp/fd

`fd` can be installed from various distro repos.

It can also be installed from source using `cargo`:
```shell
cargo install fd-find
```

### jq
`jq` is used for parsing JSON data.
- Official website: https://stedolan.github.io/jq/

`jq` can be installed from various distro repos.

### yj
`yj` is used for converting data from YAML to JSON.
- Official website: https://github.com/bruceadams/yj

`yj` can be installed from source using `cargo`:
```shell
cargo install yj
```

## Basic Usage

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

## Project Structure

### Basic directory structure

- `/`: project root
 - `Makefile`: all build processes are defined here
 - `src/`: all static resources (html, js, css etc) and templates (*.j2) are stored here
 - `site.yml`: all site variables are defined in this file (equivalent to jekyll's `_config.yml`)
 - `build.mk`: optional Makefile to define custom build settings like input/output directories, includes and excludes (this file is automatically included in the main `Makefile`)

### Source directory

All files in the `src/` directory are processed as follows:
- If the file ends with `*.j2`, it will be processed by the template engine and saved in the output directory using the same path structure, but without the .j2 extension.
 - Eg: The file `src/page01/index.html.j2` will be processed and saved to `out/page01/index.html`
- All other files (any extension other than `*.j2` and `*.meta`) will be copied to the output directory as is.

### Includes

Includes are optional.

All layouts and other utils must be stored outside of the `src/` directory.

The includes directories can have any structure, just make sure they are registered in the `build.mk` file.

Eg: If you have two include folders, `layouts/` and `utils/`, add the following line to the `build.mk` file:
```make
INCLUDES := layouts utils
```

>NOTE: the layouts and other includes are equivalent to jekyll's `_layouts` and `_includes` directories.

### Layouts

Layouts are optional.

You can create layouts by creating templates (`.j2`) that follow the Jinja2 Child Template format.

See more about Jinja2 Child Template here: https://jinja.palletsprojects.com/en/2.11.x/templates/#child-template

Store all layouts outside of the `src/` directory. Follow the rules for `includes` mentioned above.

## Data

### Site data

All data added to the `site.yml` file can be accessed within any template (`.j2`) using the `site` object.

Eg: If you want to print the site title:
```jinja2
<title>{{ site.title }}</title>
```

>NOTE: the `site.yml` file is equivalent to the jekyll's `_config.yml` file.

### Template Metadata

Template metadata is optional.

Templates can have metadata such as page title, date, tags etc.

Metadata is accessible within the template (`.j2`) and is most useful if you are using layouts.

Metadata is stored in a .meta file along with the template files.

It uses the same YAML syntax as `site.yml`.

Eg: If you want to add metadata to a template called `index.html.j2`:
- Create a file called `index.html.j2.meta` in the same directory.

Metadata example:

```yaml
title: About Me
tags: [page, about]
```

Metadata variables are accessed within the template using the `page` object.

Eg: If you want to print the page title:
```jinja2
<h1>{{ page.title }}</h1>
```

>NOTE: metadata files are equivalent to jekyll's front matter.

### Custom Data

Custom data are optional.

You can create custom data files that can be accessed in any template.

Custom data can be stored in any directory outside the `src/` directory, just make sure it's registered in the `build.mk` file.

Eg: If your custom data directory is called `data/`, add the following line to the `build.mk` file:
```make
DATA := data
```

All custom data must be created using YAML syntax and stored with the `.yml` extension.

All custom data can be accessed within any template (`.j2`) using the `data` object.

Eg: If you have custom data saved as `data/authors.yml`, you can access it like this:
```jinja2
{% for author in data.authors %}
<p>{{ author.name }}</p>
{% endfor %}
```
>NOTE: custom data files are equivalent to jekyll's data files.
