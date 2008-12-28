TabTab::Definition.register("searchd") do |c|
  c.flag :help, :h
  c.flag :config, :c
  c.flag :stop
  c.flag :pidfile
  c.flag :console
  c.flag :iostats
  c.flag :port, :p
  c.flag :index, :i
  c.flag :nodetach
  c.flag :install
  c.flag :delete
  c.flag :servicename
  c.flag :ntservice
end

TabTab::Definition.register("indexer") do |c|
  c.flag :config, :c
  c.flag :all
  c.flag :rotate
  c.flag :quiet
  c.flag :noprogress
  c.flag :buildstops
  c.flag :buildfreqs
  c.flag :merge
  c.flag :"merge-dst-range"
end

TabTab::Definition.register("search") do |c|
  c.flag :config, :c
  c.flag :index, :i
  c.flag :stdin
  c.flag :any, :a
  c.flag :phrase, :p
  c.flag :boolean, :b
  c.flag :ext, :e
  c.flag :ext2, :e2
  c.flag :filter, :f
  c.flag :limit, :l
  c.flag :offset, :o
  c.flag :group, :g
  c.flag :groupsort, :gs
  c.flag :sortby, :s
  c.flag :sortexpr, :S
  c.flag :"sort=date"
  c.flag :"rsort=date"
  c.flag :"sort=ts"
  c.flag :noinfo, :q
  c.flag :dumpheader
end

TabTab::Definition.register("spelldump") do |c|
  c.flag :c
end
