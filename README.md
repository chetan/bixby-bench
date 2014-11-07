# bixby-bench

A simple wrapper around the stdlib Benchmark with allocation tracing mixed in

## Installation and Usage

```bash
gem install bixby-bench
```

Usage is very similar to `Benchmark.bm`:

```ruby
Bixby::Bench.run(10_000) do |b| # 10,000 = number of sample runs
  b.sample('test_method') do
    Test.method()
  end
  b.divider
  b.sample('test_method2') do
    Test.method2()
  end
end
```

You can see some sample output from an actual test here: 
https://gist.github.com/chetan/d613e8f7d45600e1ca34

## Contributing to bixby-bench
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2014 Chetan Sarva. See LICENSE.txt for
further details.
