# doxygenize
Minimalist GitHub Action to automatically generate [Doxygen](http://doxygen.nl) code documentation and publish it to GitHub Pages. The generator only supporta HTML format, and currently it cannot handle LaTeX and Graph.

![Doxygenize Octocat](./image/doxygenize-octocat.png)

## Setup

- Enable GitHub Pages branch (gh-pages) on your repository using [this tutorial](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site);
- Set `./doc/html` as HTML output folder in the `doxygen.conf` file;
- Copy `/doxygen.conf` file to `./doc/` path in your repository;
- Add following step to your respository workflow script:
```yaml
uses: langroodi/doxygenize@[version/tag/commit hash (e.g., v1)]
```
- In case of different configuration file path and/or HTML output folder, please refer to the [Inputs](#inputs) section.

### Inputs

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| doxygenconf | string | `./doc/doxygen.conf` | Doxygen configuration file path |
| htmloutput | string | `./doc/html` | Doxygen-generated HTML files output folder defined in the configuration file  |

```yaml
uses: langroodi/doxygenize@[version/tag/commit hash (e.g., v1)]
with:
    doxygenconf: '[Configuration file path (e.g., ./doc/doxygen.conf)]'
    htmloutput: '[HTML output folder (e.g., ./doc/html)]'
```
