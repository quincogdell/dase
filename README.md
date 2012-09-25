# Dase

## Overview

Dase gem provides 'includes_count_of' method on a relation, which works similar to ActiveRecord's 'includes' method.

![Dase example](https://vovayartsev-home.s3.amazonaws.com/dase-mockup.png)

Calling 'includes_count_of(:articles)' on a relation object adds 'articles_count' method to each of the authors:
```
  authors = Author.includes(:publisher).includes_count_of(:articles, :conditions => {:year => 2012})  
  authors.first.name             # => 'Billy'                
  authors.first.articles_count   # => 2                
```


## Installation

Add this line to your application's Gemfile:

    gem 'dase', "~> 3.2.0"

### Note on version numbers

Dase version number correlates with the Active Record's versions number,
which it has been tested with.
E.g. the latest 3.2.* version of Dase will play nicely with the latest 3.2.* version of Active Record.
Since it's a sort of a "hack", make sure you specified the version number for "dase" gem in your Gemfile.

## Usage

### Basic usage:

```
  Author.includes_count_of(:articles).find_each do |author|
    puts "#{author.name} has #{author.articles_count} articles published"
  end
```

### Using :conditions hash
Specify a hash of options which will be passed to the underlying finder 
which retrieves the association. Valid keys are: :conditions, :group, :having, :joins, :include
```
Author.includes_count_of(:articles, :conditions => {:year => 2012})   # counts only articles in year 2012
```

### Using scope merging
```
scope = Article.where(:year => 2012)
Author.includes_count_of(:articles, :only => scope)   # counts only articles in year 2012
```

### Using block syntax
```
Author.includes_count_of(:articles){ where(:year => 2012) }        # in the block, 'self' is a Relation instance
Author.includes_count_of(:articles){ |scope| scope.where(:year => 2012) }   # 'self' is the same inside and outside the block
```

### Renaming counter column
```
sites = WebSite.includes_count_of(:users, :conditions => {:role => 'admin'}, :as => :admins_count)   
sites.each { |site| puts "Site #{site.url} has #{site.admins_count} admin users" }
```


### Known problems

Dase doesn't support :through option on associations

## How it works

Here's a pseudo-code that gives an idea on how it works internally
```
  counters_hash = Article.where(:year => 2012).count(:group => :author_id)
  Author.find_each do |author|
    puts "#{author.name} has #{counters_hash[author.id] || 0} articles published"
  end
```




## Name origin

The gem is named by the german mathematician [Johann Dase](http://en.wikipedia.org/wiki/Zacharias_Dase),
who was a mental calculator - he could count and multiply numbers very quickly. 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
