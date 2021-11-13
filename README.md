# NoTBJ

No more `Terminate Batch Job (Y/N)` prompts!  
This gem is only for windows.

## Installation

Execute this:
```
> gem install no_tbj
```

<!--
This gem is not on rubygems.org, so you need to install it manually.

```
git clone git@github.com:sevenc-nanashi/no_tbj.git
cd no_tbj
rake go
gem build no_tbj.gemspec
gem install no_tbj-x.x.x.gem
```
-->

## Usage

`no_tbj install` to install the executable.  
`no_tbj uninstall` to uninstall the executable.  
Just it, you won't be prompted to terminate the batch job!

## Development

To build executable, execute `rake go`. Note `no_tbj` is added at the last of executable.

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sevenc-nanashi/no_tbj

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
