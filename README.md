# crep.nvim

## `c`<lone|reate>`rep`o

This is a telescope extension for neovim.

This extension will use the `gh` command line tool to vim cd or clone a repo for a provided GitHub org. It works by storing the JSON representation of the organization's repos in a text file, which can then later be saved and used to load the results instantly without making any network requests. Because an organization's repos will change over time, this file is stored in the `/tmp` directory so that it will be removed upon reboot. This has been a decent frequency for updates for my personal working style.

## gh

* use this to get list of json fields:
```
gh repo list --json 2>&1 | v -
```

## Install

* Add something such as this to your packer install
```
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      '~/code/crep.nvim',
    },
  }
```

* Set up `crep`:
```
require("telescope").setup {
  extensions = {
    crep = {
      destination_dir = "/path/to/your/code",
      organization = "your-github-org",
      dynamic_preview_title = true,
    },
  },
}
require 'telescope'.load_extension 'crep'
```

## Usage

* `<leader><leader>C` - Generate list of all repos within org, and allow user to select one to clone (if it doesn't already exist locally) and browse
