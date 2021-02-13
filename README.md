# Handcar

A Rack-based Ruby web framework.

> "Like Rails, if 'opinionated' meant 'non-functional.'"

I made this framework to follow along with Noah Gibb's lovely book [Rebuilding Rails](https://rebuilding-rails.com/). While I'm sure you could probably use it in production, don't.


## Getting Started

    $ gem build handcar.gemspec
    $ gem install handcar-0.0.5.gem
    $ handcar new my_app
    $ cd my_app
    $ bundle install
    $ rackup -p 3001


## License

This code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT). It's very much derived from the [original project](https://github.com/noahgibbs/rulers), which is also available under the MIT license at the time of writing.