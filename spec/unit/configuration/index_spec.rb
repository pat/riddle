require 'spec_helper'

describe Riddle::Configuration::DistributedIndex do
  it "should be invalid without a name, sources or path if there's no parent" do
    index = Riddle::Configuration::Index.new(nil)
    index.should_not be_valid
    
    index.name = "test1"
    index.should_not be_valid
    
    index.sources << Riddle::Configuration::SQLSource.new("source", "mysql")
    index.should_not be_valid
    
    index.path = "a/path"
    index.should be_valid
    
    index.name = nil
    index.should_not be_valid
    
    index.name = "test1"
    index.sources.clear
    index.should_not be_valid
  end
  
  it "should be invalid without a name but not sources or path if it has a parent" do
    index = Riddle::Configuration::Index.new(nil)
    index.should_not be_valid
    
    index.name = "test1stemmed"
    index.should_not be_valid
    
    index.parent = "test1"
    index.should be_valid
  end
  
  it "should raise a ConfigurationError if rendering when not valid" do
    index = Riddle::Configuration::Index.new("test1")
    lambda { index.render }.should raise_error(Riddle::Configuration::ConfigurationError)
  end
  
  it "should render correctly if supplied settings are valid" do
    source = Riddle::Configuration::XMLSource.new("src1", "xmlpipe")
    source.xmlpipe_command = "ls /dev/null"
    
    index = Riddle::Configuration::Index.new("test1", source)
    index.path                      = "/var/data/test1"
    index.docinfo                   = "extern"
    index.mlock                     = 0
    index.morphologies             << "stem_en" << "stem_ru" << "soundex"
    index.min_stemming_len          = 1
    index.stopword_files           << "/var/data/stopwords.txt" << "/var/data/stopwords2.txt"
    index.wordform_files           << "/var/data/wordforms.txt"
    index.exception_files          << "/var/data/exceptions.txt"
    index.min_word_len              = 1
    index.charset_type              = "utf-8"
    index.charset_table             = "0..9, A..Z->a..z, _, a..z, U+410..U+42F->U+430..U+44F, U+430..U+44F"
    index.ignore_characters        << "U+00AD"
    index.min_prefix_len            = 0
    index.min_infix_len             = 0
    index.prefix_field_names       << "filename"
    index.infix_field_names        << "url" << "domain"
    index.enable_star               = true
    index.ngram_len                 = 1
    index.ngram_characters         << "U+3000..U+2FA1F"
    index.phrase_boundaries        << "." << "?" << "!" << "U+2026"
    index.phrase_boundary_step      = 100
    index.html_strip                = 0
    index.html_index_attrs          = "img=alt,title; a=title"
    index.html_remove_element_tags << "style" << "script"
    index.preopen                   = 1
    index.ondisk_dict               = 1
    index.inplace_enable            = 1
    index.inplace_hit_gap           = 0
    index.inplace_docinfo_gap       = 0
    index.inplace_reloc_factor      = 0.1
    index.inplace_write_factor      = 0.1
    index.index_exact_words         = 1
    
    index.render.should == <<-INDEX
source src1
{
  type = xmlpipe
  xmlpipe_command = ls /dev/null
}

index test1
{
  source = src1
  path = /var/data/test1
  docinfo = extern
  mlock = 0
  morphology = stem_en, stem_ru, soundex
  min_stemming_len = 1
  stopwords = /var/data/stopwords.txt /var/data/stopwords2.txt
  wordforms = /var/data/wordforms.txt
  exceptions = /var/data/exceptions.txt
  min_word_len = 1
  charset_type = utf-8
  charset_table = 0..9, A..Z->a..z, _, a..z, U+410..U+42F->U+430..U+44F, U+430..U+44F
  ignore_chars = U+00AD
  min_prefix_len = 0
  min_infix_len = 0
  prefix_fields = filename
  infix_fields = url, domain
  enable_star = 1
  ngram_len = 1
  ngram_chars = U+3000..U+2FA1F
  phrase_boundary = ., ?, !, U+2026
  phrase_boundary_step = 100
  html_strip = 0
  html_index_attrs = img=alt,title; a=title
  html_remove_elements = style, script
  preopen = 1
  ondisk_dict = 1
  inplace_enable = 1
  inplace_hit_gap = 0
  inplace_docinfo_gap = 0
  inplace_reloc_factor = 0.1
  inplace_write_factor = 0.1
  index_exact_words = 1
}
    INDEX
  end
end