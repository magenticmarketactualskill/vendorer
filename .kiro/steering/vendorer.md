## Vendorer - Gem Vendoring Management

This project uses the `vendorer` gem to manage vendored dependencies. Vendorer helps clone gems from GitHub into the `./vendor` directory, track local changes, and push updates back to remote repositories.

### Quick Commands

List all vendored gems:
```bash
bin/vendorer list
```

Vendor a gem from GitHub:
```bash
bin/vendorer vendor GEM_NAME --url=GITHUB_URL
```

Check status of vendored gems:
```bash
bin/vendorer status
```

Push changes for a specific gem:
```bash
bin/vendorer push GEM_NAME --message="Your commit message"
```

Update all vendored gems with changes (git add, commit, push):
```bash
bin/vendorer update
```

Remove a vendored gem:
```bash
bin/vendorer unvendor GEM_NAME
```

### What Vendorer Does

- Clones gem repositories into `./vendor/GEM_NAME`
- Automatically updates Gemfile to use path-based gem declarations
- Tracks uncommitted changes in vendored gems
- Commits and pushes changes back to remote repositories
- Safely removes vendored gems and restores standard gem declarations

### Typical Workflow

1. **Vendor a gem for development**:
   ```bash
   bin/vendorer vendor some_gem --url=https://github.com/org/some_gem.git
   ```

2. **Make your changes** in `vendor/some_gem/`

3. **Test locally** - the Gemfile automatically uses your vendored version

4. **Check what changed**:
   ```bash
   bin/vendorer status some_gem
   ```

5. **Push your changes**:
   ```bash
   bin/vendorer push some_gem --branch=feature/my-fix --message="Fix issue"
   ```
   
   Or update all vendored gems at once:
   ```bash
   bin/vendorer update --message="Update all vendored gems"
   ```

6. **Create PR** on GitHub for the upstream repository

7. **Clean up after PR is merged**:
   ```bash
   bin/vendorer unvendor some_gem
   ```

### Update Command

The `update` command is a convenient way to commit and push all vendored gems that have changes:

```bash
# Update all gems with default message
bin/vendorer update

# Update with custom commit message
bin/vendorer update --message="Fix bugs in vendored gems"

# Update and push to specific branch
bin/vendorer update --branch=develop --message="Update gems"
```

The update command will:
1. Scan all vendored gems for uncommitted changes
2. For each gem with changes:
   - Run `git add -A` to stage all changes
   - Commit with the specified message (or default message)
   - Push to the remote repository
3. Report success or failure for each gem

### Integration with This Project

This project vendors several gems for local development:
- `git_steering` - Steering file symlink management
- `vendorer` - This gem itself
- `forker` - Fork management
- `submoduler_parent` - Parent submodule management
- `submoduler_child` - Child submodule management
- `submoduler_common` - Common submodule utilities

Use `bin/vendorer list` to see all currently vendored gems.

### When to Vendor a Gem

Vendor gems when you need to:
- Debug issues in a dependency
- Make temporary patches while waiting for upstream fixes
- Contribute features or bug fixes to open-source gems
- Maintain a fork with custom modifications
- Develop multiple related gems simultaneously

### Safety Features

- Prevents unvendoring gems with uncommitted changes (use `--keep-changes` to override)
- Shows clear status of all modifications before pushing
- Preserves Gemfile formatting when updating gem declarations
- Uses standard git commands for all operations
- Automatically stages all changes before committing

### Commands Reference

| Command | Description |
|---------|-------------|
| `bin/vendorer list` | List all vendored gems with status |
| `bin/vendorer vendor GEM --url=URL` | Clone and vendor a gem |
| `bin/vendorer unvendor GEM` | Remove a vendored gem |
| `bin/vendorer push GEM` | Commit and push changes for one gem |
| `bin/vendorer update` | Commit and push all gems with changes |
| `bin/vendorer status [GEM]` | Show status of vendored gems |
| `bin/vendorer version` | Show vendorer version |

### Version

Check vendorer version: `bin/vendorer version`
