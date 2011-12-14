# Riddle

This client has been written to interface with [Sphinx](http://sphinxsearch.com/). It is written by
[Pat Allan](http://freelancing-gods.com), and has been influenced by both Dmytro Shteflyuk's Ruby
client and the original PHP client - credit where credit's due, after all.

It does not follow the same syntax as those two, though (not much point writing this otherwise) -
opting for a more Ruby-like structure.

## Installation

    sudo gem install riddle --source http://gemcutter.org

### Usage

As of version 1.0.0, Riddle now supports multiple versions of Sphinx in the one gem - you'll need to require your specific version after a normal require, though.

    require 'riddle'
    require 'riddle/0.9.9'

To get started, just instantiate a Client object:

    client = Riddle::Client.new # defaults to localhost and port 3312
    client = Riddle::Client.new "sphinxserver.domain.tld", 3333 # custom settings

And then set the parameters to what you want, before running a query:

    client.match_mode = :extended
    client.query "Pat Allan @state Victoria"

The results from a query are similar to the other clients - but here's the details. It's a hash with
the following keys:

* :matches
* :fields
* :attributes
* :attribute_names
* :words
* :total
* :total_found
* :time
* :status
* :warning (if appropriate)
* :error (if appropriate)

The key `:matches` returns an array of hashes - the actual search results. Each hash has the
document id (`:doc`), the result weighting (`:weight`), and a hash of the attributes for
the document (`:attributes`).

The `:fields` and `:attribute_names` keys return list of fields and attributes for the
documents. The key `:attributes` will return a hash of attribute name and type pairs, and
`:words` returns a hash of hashes representing the words from the search, with the number of
documents and hits for each, along the lines of:

    results[:words]["Pat"] #=> {:docs => 12, :hits => 15}

`:total`, `:total_found` and `:time` return the number of matches available, the
total number of matches (which may be greater than the maximum available), and the time in milliseconds
that the query took to run.

`:status` is the error code for the query - and if there was a related warning, it will be under
the `:warning` key. Fatal errors will be described under `:error`.

If you've installed the gem and wondering why there's no tests - check out the
git version. I've kept the specs out of the gem as I have a decent amount of
test data in there, which really isn't needed unless you want to submit
patches.

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
