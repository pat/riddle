require 'spec_helper'

describe "Sphinx Excepts" do
  before :each do
    @client = Riddle::Client.new("localhost", 9313)
  end
  
  it "should highlight a single word multiple times in a document" do
    @client.excerpts(
      :index  => "people",
      :words  => "Mary",
      :docs   => ["Mary, Mary, quite contrary."]
    ).should == [
      '<span class="match">Mary</span>, <span class="match">Mary</span>, quite contrary.'
    ]
  end
  
  it "should use specified word markers" do
    @client.excerpts(
      :index        => "people",
      :words        => "Mary",
      :docs         => ["Mary, Mary, quite contrary."],
      :before_match => "<em>",
      :after_match  => "</em>"
    ).should == [
      "<em>Mary</em>, <em>Mary</em>, quite contrary."
    ]
  end
  
  it "should separate matches that are far apart by an ellipsis by default" do
    excerpts = @client.excerpts(
      :index        => "people",
      :words        => "Pat",
      :docs         => [
        <<-SENTENCE
This is a really long sentence written by Pat. It has to be over 256
characters long, between keywords. But what is the keyword? Well, I 
can't tell you just yet... wait patiently until we've hit the 256 mark.
It'll take a bit longer than you think. We're probably just hitting the
200 mark at this point. But I think we've now arrived - so I can tell
you what the keyword is. I bet you're really interested in finding out,
yeah? Excerpts are particularly riveting. This keyword, however, is
not. It's just my name: Pat.
        SENTENCE
        ],
      :before_match => "<em>",
      :after_match  => "</em>"
    )
    
    
    case Riddle.loaded_version
    when '0.9.9'
      excerpts.should == [
        <<-SENTENCE
This is a really long sentence written by <em>Pat</em>. It has to be over 256
characters long, between keywords. But what is the  &#8230; 're really interested in finding out,
yeah? Excerpts are particularly riveting. This keyword, however, is
not. It's just my name: <em>Pat</em>.
        SENTENCE
      ]
    when '1.10'
      excerpts.should == [" &#8230;  really long sentence written by <em>Pat</em>. It has to be over &#8230; . This keyword, however, is\nnot. It's just my name: <em>Pat</em> &#8230; "]
    else
      excerpts.should == [
        <<-SENTENCE
This is a really long sentence written by <em>Pat</em>. It has to be over 256
characters long, between keywords. But what is the keyword?  &#8230;  interested in finding out,
yeah? Excerpts are particularly riveting. This keyword, however, is
not. It's just my name: <em>Pat</em>.
        SENTENCE
      ]
    end
  end
  
  it "should use the provided separator" do
    excerpts = @client.excerpts(
      :index           => "people",
      :words           => "Pat",
      :docs            => [
        <<-SENTENCE
This is a really long sentence written by Pat. It has to be over 256
characters long, between keywords. But what is the keyword? Well, I 
can't tell you just yet... wait patiently until we've hit the 256 mark.
It'll take a bit longer than you think. We're probably just hitting the
200 mark at this point. But I think we've now arrived - so I can tell
you what the keyword is. I bet you're really interested in finding out,
yeah? Excerpts are particularly riveting. This keyword, however, is
not. It's just my name: Pat.
        SENTENCE
        ],
      :before_match    => "<em>",
      :after_match     => "</em>",
      :chunk_separator => " --- "
    )
    
    case Riddle.loaded_version
    when '0.9.9'
      excerpts.should == [
        <<-SENTENCE
This is a really long sentence written by <em>Pat</em>. It has to be over 256
characters long, between keywords. But what is the  --- 're really interested in finding out,
yeah? Excerpts are particularly riveting. This keyword, however, is
not. It's just my name: <em>Pat</em>.
        SENTENCE
      ]
    when '1.10'
      excerpts.should == [" ---  really long sentence written by <em>Pat</em>. It has to be over --- . This keyword, however, is\nnot. It's just my name: <em>Pat</em> --- "]
    else
      excerpts.should == [
        <<-SENTENCE
This is a really long sentence written by <em>Pat</em>. It has to be over 256
characters long, between keywords. But what is the keyword?  ---  interested in finding out,
yeah? Excerpts are particularly riveting. This keyword, however, is
not. It's just my name: <em>Pat</em>.
        SENTENCE
      ]
    end
  end
  
  it "should return multiple results for multiple documents" do
     @client.excerpts(
        :index        => "people",
        :words        => "Mary",
        :docs         => [
          "Mary, Mary, quite contrary.",
          "The epithet \"Bloody Mary\" is associated with a number of historical and fictional women, most notably Queen Mary I of England"
        ],
        :before_match => "<em>",
        :after_match  => "</em>"
      ).should == [
        "<em>Mary</em>, <em>Mary</em>, quite contrary.",
        "The epithet \"Bloody <em>Mary</em>\" is associated with a number of historical and fictional women, most notably Queen <em>Mary</em> I of England"
      ]
  end
end