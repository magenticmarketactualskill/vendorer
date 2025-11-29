# Vendorer

A Ruby gem for managing vendored dependencies in your Ruby and Rails projects. Vendorer helps you clone gems from GitHub into your `./vendor` directory, track local changes, and push updates back to remote repositories.

## Features

- **Vendor gems from GitHub**: Clone any gem repository into your project's vendor directory
- **Track changes**: See which vendored gems have uncommitted changes
- **Push updates**: Commit and push your local changes back to remote repositories
- **Gemfile management**: Automatically updates your Gemfile to use vendored gems
- **Clean unvendoring**: Remove vendored gems and restore standard gem declarations

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vendorer'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install vendorer
```

## Usage

### List Vendored Gems

See all gems currently vendored in your project:

```bash
vendorer list
```

This will show:
- Gem name and path
- Remote repository URL
- Current branch
- Whether there are uncommitted changes
- Count of modified, added, deleted, and untracked files

### Vendor a Gem

Clone a gem from GitHub into your vendor directory:

```bash
vendorer vendor GEM_NAME --url=GITHUB_URL
```

Example:

```bash
vendorer vendor rails --url=https://github.com/rails/rails.git
```

Vendor a specific branch or tag:

```bash
vendorer vendor rails --url=https://github.com/rails/rails.git --branch=7-0-stable
```

This will:
1. Clone the repository to `./vendor/GEM_NAME`
2. Update your Gemfile to use the vendored version: `gem 'GEM_NAME', path: './vendor/GEM_NAME'`
3. Preserve any existing Gemfile formatting

### Unvendor a Gem

Remove a vendored gem and restore the standard gem declaration:

```bash
vendorer unvendor GEM_NAME
```

By default, this will fail if there are uncommitted changes. To force removal:

```bash
vendorer unvendor GEM_NAME --keep-changes
```

### Push Changes

After making changes to a vendored gem, commit and push them:

```bash
vendorer push GEM_NAME
```

With a custom commit message:

```bash
vendorer push GEM_NAME --message="Fix bug in authentication"
```

Push to a specific branch:

```bash
vendorer push GEM_NAME --branch=feature/my-changes
```

### Check Status

View the status of a specific vendored gem:

```bash
vendorer status GEM_NAME
```

Or check all vendored gems:

```bash
vendorer status
```

### Version

Display the vendorer version:

```bash
vendorer version
```

## Workflow Example

Here's a typical workflow for contributing to an open-source gem:

1. **Vendor the gem**:
   ```bash
   vendorer vendor devise --url=https://github.com/heartcombo/devise.git
   ```

2. **Make your changes**:
   Edit files in `./vendor/devise`

3. **Test your changes**:
   ```bash
   bundle install
   # Run your application tests
   ```

4. **Check status**:
   ```bash
   vendorer status devise
   ```

5. **Push your changes**:
   ```bash
   vendorer push devise --branch=feature/my-improvement --message="Add new feature"
   ```

6. **Create a pull request**:
   Use GitHub's web interface or the `gh` CLI to create a PR from your branch

7. **Clean up** (after PR is merged):
   ```bash
   vendorer unvendor devise
   ```

## Configuration

Vendorer uses sensible defaults, but you can configure paths in your code:

```ruby
Vendorer.configure do |config|
  config.vendor_path = File.join(Dir.pwd, "vendor")
  config.gemfile_path = File.join(Dir.pwd, "Gemfile")
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Running Tests

Run RSpec tests:

```bash
bundle exec rspec
```

Run Cucumber features:

```bash
bundle exec cucumber
```

Run all tests:

```bash
bundle exec rake
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vendorer/vendorer.

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## FAQ

### Why vendor gems?

Vendoring gems is useful when you need to:
- Debug issues in a gem
- Make temporary patches while waiting for upstream fixes
- Contribute features or bug fixes to open-source gems
- Maintain a fork with custom modifications

### How is this different from using `bundle config local`?

Bundler's local override feature requires you to manually manage the git repository and Gemfile separately. Vendorer automates this process and provides additional features like change tracking and pushing updates.

### Can I vendor private repositories?

Yes, as long as you have git access configured (SSH keys or HTTPS credentials). Vendorer uses standard git commands, so any repository you can clone manually can be vendored.

### What happens to my Gemfile when I vendor a gem?

Vendorer will replace the existing gem declaration with a path-based declaration:

Before:
```ruby
gem 'rails', '~> 7.0'
```

After:
```ruby
gem 'rails', path: './vendor/rails'
```

### Can I vendor multiple gems at once?

Currently, you need to vendor gems one at a time. This is intentional to ensure each vendoring operation is explicit and traceable.

## Troubleshooting

### "Gem has uncommitted changes"

If you try to unvendor a gem with uncommitted changes, vendorer will prevent accidental data loss. Either commit your changes with `vendorer push`, or use `--keep-changes` to force removal.

### "Failed to push changes"

Make sure you have write access to the remote repository and that your local branch is tracking a remote branch. You may need to create a new branch first:

```bash
cd vendor/GEM_NAME
git checkout -b feature/my-changes
cd ../..
vendorer push GEM_NAME
```

### Gemfile conflicts

If vendorer's Gemfile modifications conflict with your existing setup, you can manually edit the Gemfile. Vendorer uses simple pattern matching and should work with most Gemfile formats.

## Roadmap

- [ ] Support for multiple vendor directories
- [ ] Automatic PR creation via GitHub API
- [ ] Dependency conflict detection
- [ ] Integration with CI/CD pipelines
- [ ] Support for GitLab and Bitbucket
- [ ] Interactive mode for bulk operations
- [ ] Configuration file (`.vendorer.yml`)
- [ ] Hooks for custom pre/post operations

## Credits

Created by the Vendorer Team. Inspired by the needs of Ruby developers who contribute to open-source gems.
