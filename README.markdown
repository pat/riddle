# Riddle

[![Build Status](https://travis-ci.org/pat/riddle.svg?branch=develop)](https://travis-ci.org/pat/riddle)

Riddle is a Ruby library interfacing with the [Sphinx](http://sphinxsearch.com/) full-text search tool. It is written by [Pat Allan](http://freelancing-gods.com), and has been influenced by both Dmytro Shteflyuk's Ruby client and the original PHP client. It can be used for interactions with Sphinx's command-line tools `searchd` and `indexer`, sending search queries via the binary protocol, and programmatically generating Sphinx configuration files.

The syntax here, while closer to a usual Ruby approach than the PHP client, is quite old (Riddle was first published in 2007). While it would be nice to re-work things, it's really not a priority, given the bulk of Riddle's code is for Sphinx's deprecated binary protocol.

## Installation

Riddle is available as a gem, so you can install it directly:

    gem install riddle

Or include it in a Gemfile:

    gem 'riddle', '~> 2.4'

## Usage

As of version 1.0.0, Riddle supports multiple versions of Sphinx in the one gem - you'll need to require your specific version after a normal require, though. The latest distinct version is `2.1.0`:

	require 'riddle'
	require 'riddle/2.1.0'

The full list of versions available are `0.9.8` (the initial base), `0.9.9`, `1.10`, `2.0.1`, and `2.1.0`. If you're using something more modern than 2.1.0, then just require that, and the rest should be fine (changes to the binary protocol since then are minimal).

### Configuration

Riddle's structure for generating Sphinx configuration is very direct mapping to Sphinx's configuration options. First, create an instance of `Riddle::Configuration`:

    config = Riddle::Configuration.new

This configuration instance has methods `indexer`, `searchd` and `common`, which return separate inner-configuration objects with methods mapping to the equivalent [Sphinx settings](http://sphinxsearch.com/docs/current.html#conf-reference). So, you may want to do the following:

    config.indexer.mem_limit = '128M'
    config.searchd.log       = '/my/log/file.log'

Similarly, there are two further methods `indices` and `sources`, which are arrays meant to hold instances of index and source inner-configuration objects respectively (all of which have methods matching their Sphinx settings). The available index classes are:

* `Riddle::Configuration::DistributedIndex`
* `Riddle::Configuration::Index`
* `Riddle::Configuration::RealtimeIndex`
* `Riddle::Configuration::RemoteIndex`
* `Riddle::Configuration::TemplateIndex`

All of these index classes should be initialised with their name, and in the case of plain indices, their source objects. Remote indices take an address, port and name as their initialiser parameters.

    index = Riddle::Configuration::Index.new 'articles', article_source_a, article_source_b
    index.path    = '/path/to/index/files"
    index.docinfo = 'external'

The available source classes are:

* `Riddle::Configuration::SQLSource`
* `Riddle::Configuration::TSVSource`
* `Riddle::Configuration::XMLSource`

The initialising parameters are the name of the source, and the type of source:

    source = Riddle::Configuration::SQLSource.new 'article_source', 'mysql'
    source.sql_query = "SELECT id, title, body FROM articles"
    source.sql_host  = "127.0.0.1"

Once you have created your configuration object tree, you can then generate the string representation and perhaps save it to a file:

    File.write "sphinx.conf", configuration.render

It's also possible to parse an existing Sphinx configuration file into a configuration option tree:

    configuration = Riddle::Configuration.parse! File.read('sphinx.conf')

### Indexing and Starting/Stopping the Daemon

using Sphinx's command-line tools `indexer` and `searchd` via Riddle is all done via an instance of `Riddle::Controller`:

    configuration_file = "/path/to/sphinx.conf"
    configuration      = Riddle::Configuration.parse! File.read(configuration_file)
    controller         = Riddle::Controller.new configuration, configuration_file

    # set the path where the indexer and searchd binaries are located:
    controller.bin_path = '/usr/local/bin'

    # set different binary names if you're running a custom Sphinx installation:
    controller.searchd_binary_name = 'sphinxsearchd'
    controller.indexer_binary_name = 'sphinxindexer'

    # process all indices:
    controller.index
    # process specific indices:
    controller.index 'articles', 'books'
    # rotate old index files out for the new ones:
    controller.rotate

    # start the daemon:
    controller.start
    # start the daemon and do not detach the process:
    controller.start :nodetach => true
    # stop the daemon:
    controller.stop

The index, start and stop methods all accept a hash of options, and the :verbose option is respected in each case.

Each of these methods will return an instance of `Riddle::CommandResult` - or, if the command fails (as judged by the process status code), a `Riddle::CommandFailedError` exception is raised. These exceptions respond to the `command_result` method with the corresponding details.

### SphinxQL Queries

Riddle does not have any code to send SphinxQL queries and commands to Sphinx. Because Sphinx uses the mysql41 protocol (thus, mimicing a MySQL database server), I recommend using the [mysql2](https://github.com/brianmario/mysql2) gem instead. The [connection code](https://github.com/pat/thinking-sphinx/blob/develop/lib/thinking_sphinx/connection.rb) in Thinking Sphinx may provide some inspiration on this.

### Binary Protocol Searching

Sphinx's legacy binary protocol does not have many of the more recent Sphinx features - such as real-time indices - as these are only available in the SphinxQL/mysql41 protocol. However, Riddle can still be used for the binary protocol if you wish.

To get started, just instantiate a Client object:

	client = Riddle::Client.new # defaults to localhost and port 9312
	client = Riddle::Client.new "sphinxserver.domain.tld", 3333 # custom settings

And then set the parameters to what you want, before running a query:

	client.match_mode = :extended
	client.query "Pat Allan @state Victoria"

The results from a query are similar to the other clients - but here's the details. It's a hash with
the following keys:

* `:matches`
* `:fields`
* `:attributes`
* `:attribute_names`
* `:words`
* `:total`
* `:total_found`
* `:time`
* `:status`
* `:warning` (if appropriate)
* `:error` (if appropriate)

The key `:matches` returns an array of hashes - the actual search results. Each hash has the document id (`:doc`), the result weighting (`:weight`), and a hash of the attributes for the document (`:attributes`).

The `:fields` and `:attribute_names` keys return list of fields and attributes for the documents. The key `:attributes` will return a hash of attribute name and type pairs, and `:words` returns a hash of hashes representing the words from the search, with the number of documents and hits for each, along the lines of:

    results[:words]["Pat"] #=> {:docs => 12, :hits => 15}

`:total`, `:total_found` and `:time` return the number of matches available, the total number of matches (which may be greater than the maximum available), and the time in milliseconds that the query took to run.

`:status` is the error code for the query - and if there was a related warning, it will be under the `:warning` key. Fatal errors will be described under `:error`.

## Contributing

Please note that this project has a [Contributor Code of Conduct](http://contributor-covenant.org/version/1/0/0/). By participating in this project you agree to abide by its terms.

Riddle uses the [git-flow](http://jeffkreeftmeijer.com/2010/why-arent-you-using-git-flow/) process for development. The `master` branch is the latest released code (in a gem). The `develop` branch is what's coming in the next release. (There may be occasional feature and hotfix branches, although these are generally not pushed to GitHub.)

When submitting a patch to Riddle, please submit your pull request against the `develop` branch.

## Contributors

Thanks to the following people who have contributed to Riddle in some shape or form:

* Andrew Aksyonoff
* Brad Greenlee
* Lachie Cox
* Jeremy Seitz
* Mark Lane
* Xavier Noria
* Henrik Nye
* Kristopher Chambers
* Rob Anderton
* Dylan Egan
* Jerry Vos
* Piotr Sarnacki
* Tim Preston
* Amir Yalon
* Sam Goldstein
* Matt Todd
* Paco Guzmán
* Greg Weber
* Enrico Thierbach
* Jason Lambert
* Saberma
* James Cook
* Alexey Artamonov
* Paul Gibler
* Ngan Pham
* Aaron Gilbralter
* Steven Bristol
* Ilia Lobsanov
* Aleksey Morozov
* S\. Christoffer Eliesen
* Rob Golkosky
* Darcy Brown
