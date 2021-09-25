# doxygenize
Minimalist GitHub Action to automatically generate [Doxygen](http://doxygen.nl) code documentation and publish it to GitHub Pages. The generator only supports HTML format, and currently it cannot handle LaTeX and Graph outputs.

![Doxygenize Octocat](./image/doxygenize-octocat.png)

## Setup
- Generate a default Doxygen configuration file called `Doxyfile` (Special thanks to @MatiasLGonzalez for correcting me);
- Disable following options in the Doxygen configuration file:
```
GENERATE_LATEX         = NO
HAVE_DOT               = NO
```
- Set properly the input and output directories in the Doxygen configuration file:
```
OUTPUT_DIRECTORY       = # Relative path to root of your repository (e.g, ./)
INPUT                  = # Relative path to root of your repository (e.g, ./src)
```
- Enable GitHub Pages branch (i.e., gh-pages) on your repository using [this tutorial](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site);
- Copy the Doxygen configuration file to root of your repository;
- Call `action/checkoutv2` in the workflow to clone the repository;
- Add following step to your respository workflow script:
```yaml
uses: langroodi/doxygenize@[version/tag/commit hash (i.e., v1.2)]
```
- In case of different:
  - Doxygen configuration file name and/or path;
  - HTML output folder;
  - GitHub Pages branch name;
  - GitHUb Pages home directory which contains `index.html` file
  
 please refer to the [Inputs](#inputs) section.

### Inputs

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| doxygenconf | string | `./Doxyfile` | Doxygen configuration file path |
| htmloutput | string | `./docs/` | Doxygen-generated HTML files output folder |
| ghpagesbranch | string | `gh-pages` | Repository branch which is selected as the host of GitHub Pages  |
| ghpagesdir | string | `./` | GitHub Pages home directory in the GitHub Pages branch |

```yaml
uses: langroodi/doxygenize@[version/tag/commit hash (e.g., v1.2)]
with:
    doxygenconf: '[Configuration file path (e.g., ./doc/doxygen.conf)]'
    htmloutput: '[HTML output folder (e.g., ./doc/html/)]'
    ghpagesbranch: '[GitHub Pages branch name'(e.g., master)]'
    ghpagesdir: '[GitHub Pages directory path (e.g., ./docs/)]'
```
