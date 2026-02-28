# Sebastien Rosseau Repo Cloner

Helper script to clone all repositories from a GitHub owner into:

- `~/Code/Public/<Language>/<repo>` for public repos
- `~/Code/Private/<Language>/<repo>` for private repos

Legacy language folders in `~/Code` (for example `~/Code/Rust`) are migrated automatically.

## Usage

```bash
./clone-sebastienrousseau-repos.sh [owner] [base_dir] [limit]
```

- `owner` (optional): GitHub username/organization (default: `sebastienrousseau`)
- `base_dir` (optional): base path for output (default: `$HOME/Code`)
- `limit` (optional): repo limit for `gh repo list` (default: `1000`)

Example:

```bash
./clone-sebastienrousseau-repos.sh
```
