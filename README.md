# EconDataReader

Up to date remote economic data access for ruby, using Polars dataframes. 

This package will fetch economic and financial information from the Federal Reserve Economic Database, and return the results as a Polars Dataframe.  You will need an API key that can be fetched from the FRED website at https://fredaccount.stlouisfed.org/apikeys .

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fred_as_dataframe'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install fred_as_dataframe


### Configuration

Some data sources will require the specification of an API key.  These keys should be provided as part of a configuration file, e.g., config/fred_as_dataframe.rb

```ruby
FredAsDataframe::Client.configure do |config|
  config.fred_api_key = '1234567890ABCDEF'
    OR
  config.fred_api_key = File.read(File.join('','home', 'user', '.fred_api_key.txt'))
end
```    

## Usage

Consider the following transcript.

``` ruby
3.1.2 :001 > a = FredAsDataframe::Client.new('UNRATE')
 => #<FredAsDataframe::Client:0x0000000105f1dbb8 @api_key="1234567890ABCDEF", @tag="UNRATE"> 
3.1.2 :002 > b = a.fetch
 => 
shape: (919, 2)                                                    
...                                                                
3.1.2 :003 > b
 => 
shape: (919, 2)                                                    
┌────────────┬────────┐                                            
│ Timestamps ┆ UNRATE │                                            
│ ---        ┆ ---    │                                            
│ date       ┆ f64    │                                            
╞════════════╪════════╡                                            
│ 1948-01-01 ┆ 3.4    │                                            
│ 1948-02-01 ┆ 3.8    │                                            
│ 1948-03-01 ┆ 4.0    │                            
│ 1948-04-01 ┆ 3.9    │                            
│ 1948-05-01 ┆ 3.5    │
│ …          ┆ …      │
│ 2024-03-01 ┆ 3.8    │
│ 2024-04-01 ┆ 3.9    │
│ 2024-05-01 ┆ 4.0    │
│ 2024-06-01 ┆ 4.1    │
│ 2024-07-01 ┆ 4.3    │
└────────────┴────────┘ 
3.1.2 :004 > a = FredAsDataframe::Client.new('AAA')
 => #<FredAsDataframe::Client:0x0000000106077d38 @api_key="1234567890ABCDEF", @tag="AAA"> 
3.1.2 :005 > b = a.fetch
 => 
shape: (1_267, 2)        
...                      
3.1.2 :006 > b
 => 
shape: (1_267, 2)        
┌────────────┬──────┐    
│ Timestamps ┆ AAA  │    
│ ---        ┆ ---  │    
│ date       ┆ f64  │    
╞════════════╪══════╡    
│ 1919-01-01 ┆ 5.35 │    
│ 1919-02-01 ┆ 5.35 │
│ 1919-03-01 ┆ 5.39 │
│ 1919-04-01 ┆ 5.44 │
│ 1919-05-01 ┆ 5.39 │
│ …          ┆ …    │
│ 2024-03-01 ┆ 5.01 │
│ 2024-04-01 ┆ 5.28 │
│ 2024-05-01 ┆ 5.25 │
│ 2024-06-01 ┆ 5.13 │
│ 2024-07-01 ┆ 5.12 │
└────────────┴──────┘ 

```

## Documentation

TBD

## Contributing

Others are welcome to contribute to the project.

The following conventions are intended for this project.
 * Different sources are intended to reside in different classes.  
 * API keys (if needed) should be able to be set in the single configuration file.  
 * Series should be able to be identified via a single unique string, provided in the constructor.
 * When fetched, the dataset may be filtered based on optional (hash) arguments.
 * Output should be provided in a consistent DataFrame format (currently Polars::DataFrame).

Bug reports and pull requests are welcome on GitHub at https://github.com/bmck/econ_data_reader.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
