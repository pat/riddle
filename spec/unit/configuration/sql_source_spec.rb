require 'spec_helper'

describe Riddle::Configuration::SQLSource do
  it "should be invalid without a host, user, database, and query if there's no parent" do
    source = Riddle::Configuration::SQLSource.new("src1", "mysql")
    source.should_not be_valid
    
    source.sql_host   = "localhost"
    source.sql_user   = "test"
    source.sql_db     = "test"
    source.sql_query  = "SELECT * FROM tables"
    source.should be_valid
    
    [:name, :type, :sql_host, :sql_user, :sql_db, :sql_query].each do |setting|
      value = source.send(setting)
      source.send("#{setting}=".to_sym, nil)
      source.should_not be_nil
      source.send("#{setting}=".to_sym, value)
    end
  end
  
  it "should be invalid without only a name and type if there is a parent" do
    source = Riddle::Configuration::SQLSource.new("src1", "mysql")
    source.should_not be_valid

    source.parent = "sqlparent"
    source.should be_valid

    source.name = nil
    source.should_not be_valid

    source.name = "src1"
    source.type = nil
    source.should_not be_valid
  end

  it "should raise a ConfigurationError if rendering when not valid" do
    source = Riddle::Configuration::SQLSource.new("src1", "mysql")
    lambda { source.render }.should raise_error(Riddle::Configuration::ConfigurationError)
  end

  it "should render correctly when valid" do
    source = Riddle::Configuration::SQLSource.new("src1", "mysql")
    source.sql_host = "localhost"
    source.sql_user = "test"
    source.sql_pass = ""
    source.sql_db = "test"
    source.sql_port = 3306
    source.sql_sock = "/tmp/mysql.sock"
    source.mysql_connect_flags = 32
    source.sql_query_pre << "SET NAMES utf8" << "SET SESSION query_cache_type=OFF"
    source.sql_query = "SELECT id, group_id, UNIX_TIMESTAMP(date_added) AS date_added, title, content FROM documents WHERE id >= $start AND id <= $end"
    source.sql_query_range = "SELECT MIN(id), MAX(id) FROM documents"
    source.sql_range_step = 1000
    source.sql_query_killlist = "SELECT id FROM documents WHERE edited>=@last_reindex"
    source.sql_attr_uint << "author_id" << "forum_id:9" << "group_id"
    source.sql_attr_bool << "is_deleted"
    source.sql_attr_bigint << "my_bigint_id"
    source.sql_attr_timestamp << "posted_ts" << "last_edited_ts" << "date_added"
    source.sql_attr_str2ordinal << "author_name"
    source.sql_attr_float << "lat_radians" << "long_radians"
    source.sql_attr_multi << "uint tag from query; select id, tag FROM tags"
    source.sql_query_post = ""
    source.sql_query_post_index = "REPLACE INTO counters (id, val) VALUES ('max_indexed_id', $maxid)"
    source.sql_ranged_throttle = 0
    source.sql_query_info = "SELECT * FROM documents WHERE id = $id"
    source.mssql_winauth = 1
    source.mssql_unicode = 1
    source.unpack_zlib << "zlib_column"
    source.unpack_mysqlcompress << "compressed_column" << "compressed_column_2"
    source.unpack_mysqlcompress_maxsize = "16M"

    source.render.should == <<-SQLSOURCE
source src1
{
  type = mysql
  sql_host = localhost
  sql_user = test
  sql_pass = 
  sql_db = test
  sql_port = 3306
  sql_sock = /tmp/mysql.sock
  mysql_connect_flags = 32
  sql_query_pre = SET NAMES utf8
  sql_query_pre = SET SESSION query_cache_type=OFF
  sql_query = SELECT id, group_id, UNIX_TIMESTAMP(date_added) AS date_added, title, content FROM documents WHERE id >= $start AND id <= $end
  sql_query_range = SELECT MIN(id), MAX(id) FROM documents
  sql_range_step = 1000
  sql_query_killlist = SELECT id FROM documents WHERE edited>=@last_reindex
  sql_attr_uint = author_id
  sql_attr_uint = forum_id:9
  sql_attr_uint = group_id
  sql_attr_bool = is_deleted
  sql_attr_bigint = my_bigint_id
  sql_attr_timestamp = posted_ts
  sql_attr_timestamp = last_edited_ts
  sql_attr_timestamp = date_added
  sql_attr_str2ordinal = author_name
  sql_attr_float = lat_radians
  sql_attr_float = long_radians
  sql_attr_multi = uint tag from query; select id, tag FROM tags
  sql_query_post = 
  sql_query_post_index = REPLACE INTO counters (id, val) VALUES ('max_indexed_id', $maxid)
  sql_ranged_throttle = 0
  sql_query_info = SELECT * FROM documents WHERE id = $id
  mssql_winauth = 1
  mssql_unicode = 1
  unpack_zlib = zlib_column
  unpack_mysqlcompress = compressed_column
  unpack_mysqlcompress = compressed_column_2
  unpack_mysqlcompress_maxsize = 16M
}
    SQLSOURCE
  end
  
  it "should insert a backslash-newline into an sql_query when greater than 8178 characters" do
    source = Riddle::Configuration::SQLSource.new("src1", "mysql")
    source.sql_query = big_query_string[0, 8200]
    source.parent = 'src0'
    
    source.render.should match(/sql_query\s=\s[^\n]+\\\n/)
  end
  
  it "should insert two backslash-newlines into an sql_query when greater than 16,356 characters" do
    source = Riddle::Configuration::SQLSource.new("src1", "mysql")
    source.sql_query = big_query_string
    source.parent = 'src0'
    
    source.render.should match(/sql_query\s=\s[^\n]+\\\n[^\n]+\\\n/)    
  end
  
  def big_query_string
    return <<-SQL
SELECT MARLEY was dead to begin with There is no doubtwhatever about that The register of his burial wassigned by the clergyman the clerk the undertakerand the chief mourner Scrooge signed it andScrooges name was good upon Change for anything hechose to put his hand to Old Marley was as dead as adoornailMind I dont mean to say that I know of myown knowledge what there is particularly dead abouta doornail I might have been inclined myself toregard a coffinnail as the deadest piece of ironmongeryin the trade But the wisdom of our ancestorsis in the simile and my unhallowed handsshall not disturb it or the Countrys done for Youwill therefore permit me to repeat emphatically thatMarley was as dead as a doornailScrooge knew he was dead Of course he didHow could it be otherwise Scrooge and he werepartners for I dont know how many years Scroogewas his sole executor his sole administrator his soleassign his sole residuary legatee his sole friend andsole mourner And even Scrooge was not so dreadfullycut up by the sad event but that he was an excellentman of business on the very day of the funeraland solemnised it with an undoubted bargainThe mention of Marleys funeral brings me back tothe point I started from There is no doubt that Marleywas dead This must be distinctly understood ornothing wonderful can come of the story I am goingto relate If we were not perfectly convinced thatHamlets Father died before the play began therewould be nothing more remarkable in his taking astroll at night in an easterly wind upon his own rampartsthan there would be in any other middleagedgentleman rashly turning out after dark in a breezyspotsay Saint Pauls Churchyard for instanceliterally to astonish his sons weak mindScrooge never painted out Old Marleys nameThere it stood years afterwards above the warehousedoor Scrooge and Marley The firm was known asScrooge and Marley Sometimes people new to thebusiness called Scrooge Scrooge and sometimes Marleybut he answered to both names It was all thesame to himOh But he was a tightfisted hand at the grindstoneScrooge a squeezing wrenching grasping scrapingclutching covetous old sinner Hard and sharp as flintfrom which no steel had ever struck out generous firesecret and selfcontained and solitary as an oyster Thecold within him froze his old features nipped his pointednose shrivelled his cheek stiffened his gait made hiseyes red his thin lips blue and spoke out shrewdly in hisgrating voice A frosty rime was on his head and on hiseyebrows and his wiry chin He carried his own lowtemperature always about with him he iced his office inthe dogdays and didnt thaw it one degree at ChristmasExternal heat and cold had little influence onScrooge No warmth could warm no wintry weatherchill him No wind that blew was bitterer than heno falling snow was more intent upon its purpose nopelting rain less open to entreaty Foul weather didntknow where to have him The heaviest rain andsnow and hail and sleet could boast of the advantageover him in only one respect They often came downhandsomely and Scrooge never didNobody ever stopped him in the street to say withgladsome looks My dear Scrooge how are youWhen will you come to see me No beggars imploredhim to bestow a trifle no children asked himwhat it was oclock no man or woman ever once in allhis life inquired the way to such and such a place ofScrooge Even the blind mens dogs appeared toknow him and when they saw him coming on wouldtug their owners into doorways and up courts andthen would wag their tails as though they said Noeye at all is better than an evil eye dark masterBut what did Scrooge care It was the very thinghe liked To edge his way along the crowded pathsof life warning all human sympathy to keep its distancewas what the knowing ones call nuts to ScroogeOnce upon a timeof all the good days in the yearon Christmas Eveold Scrooge sat busy in hiscountinghouse It was cold bleak biting weather foggywithal and he could hear the people in the court outsidego wheezing up and down beating their handsupon their breasts and stamping their feet upon thepavement stones to warm them The city clocks hadonly just gone three but it was quite dark alreadyit had not been light all dayand candles were flaringin the windows of the neighbouring offices likeruddy smears upon the palpable brown air The fogcame pouring in at every chink and keyhole and wasso dense without that although the court was of thenarrowest the houses opposite were mere phantomsTo see the dingy cloud come drooping down obscuringeverything one might have thought that Naturelived hard by and was brewing on a large scaleThe door of Scrooges countinghouse was openthat he might keep his eye upon his clerk who in adismal little cell beyond a sort of tank was copyingletters Scrooge had a very small fire but the clerksfire was so very much smaller that it looked like onecoal But he couldnt replenish it for Scrooge keptthe coalbox in his own room and so surely as theclerk came in with the shovel the master predictedthat it would be necessary for them to part Whereforethe clerk put on his white comforter and tried towarm himself at the candle in which effort not beinga man of a strong imagination he failedA merry Christmas uncle God save you crieda cheerful voice It was the voice of Scroogesnephew who came upon him so quickly that this wasthe first intimation he had of his approachBah said Scrooge HumbugHe had so heated himself with rapid walking in thefog and frost this nephew of Scrooges that he wasall in a glow his face was ruddy and handsome hiseyes sparkled and his breath smoked againChristmas a humbug uncle said Scroogesnephew You dont mean that I am sureI do said Scrooge Merry Christmas Whatright have you to be merry What reason have youto be merry Youre poor enoughCome then returned the nephew gaily Whatright have you to be dismal What reason have youto be morose Youre rich enoughScrooge having no better answer ready on the spurof the moment said Bah again and followed it upwith HumbugDont be cross uncle said the nephewWhat else can I be returned the uncle when Ilive in such a world of fools as this Merry ChristmasOut upon merry Christmas Whats Christmastime to you but a time for paying bills withoutmoney a time for finding yourself a year older butnot an hour richer a time for balancing your booksand having every item in em through a round dozenof months presented dead against you If I couldwork my will said Scrooge indignantly every idiotwho goes about with Merry Christmas on his lipsshould be boiled with his own pudding and buriedwith a stake of holly through his heart He shouldUncle pleaded the nephewNephew returned the uncle sternly keep Christmasin your own way and let me keep it in mineKeep it repeated Scrooges nephew But youdont keep itLet me leave it alone then said Scrooge Muchgood may it do you Much good it has ever doneyouThere are many things from which I might havederived good by which I have not profited I daresay returned the nephew Christmas among therest But I am sure I have always thought of Christmastime when it has come roundapart from theveneration due to its sacred name and origin if anythingbelonging to it can be apart from thatas agood time a kind forgiving charitable pleasanttime the only time I know of in the long calendarof the year when men and women seem by one consentto open their shutup hearts freely and to thinkof people below them as if they really werefellowpassengers to the grave and not another raceof creatures bound on other journeys And thereforeuncle though it has never put a scrap of gold orsilver in my pocket I believe that it has done megood and will do me good and I say God bless itThe clerk in the Tank involuntarily applaudedBecoming immediately sensible of the improprietyhe poked the fire and extinguished the last frail sparkfor everLet me hear another sound from you saidScrooge and youll keep your Christmas by losingyour situation Youre quite a powerful speakersir he added turning to his nephew I wonder youdont go into ParliamentDont be angry uncle Come Dine with us tomorrowScrooge said that he would see himyes indeed hedid He went the whole length of the expressionand said that he would see him in that extremity firstBut why cried Scrooges nephew WhyWhy did you get married said ScroogeBecause I fell in loveBecause you fell in love growled Scrooge as ifthat were the only one thing in the world more ridiculousthan a merry Christmas Good afternoonNay uncle but you never came to see me beforethat happened Why give it as a reason for notcoming nowGood afternoon said ScroogeI want nothing from you I ask nothing of youwhy cannot we be friendsGood afternoon said ScroogeI am sorry with all my heart to find you soresolute We have never had any quarrel to which Ihave been a party But I have made the trial inhomage to Christmas and Ill keep my Christmashumour to the last So A Merry Christmas uncleGood afternoon said ScroogeAnd A Happy New YearGood afternoon said ScroogeHis nephew left the room without an angry wordnotwithstanding He stopped at the outer door tobestow the greetings of the season on the clerk whocold as he was was warmer than Scrooge for he returnedthem cordiallyTheres another fellow muttered Scrooge whooverheard him my clerk with fifteen shillings aweek and a wife and family talking about a merryChristmas Ill retire to BedlamThis lunatic in letting Scrooges nephew out hadlet two other people in They were portly gentlemenpleasant to behold and now stood with their hats offin Scrooges office They had books and papers intheir hands and bowed to himScrooge and Marleys I believe said one of thegentlemen referring to his list Have I the pleasureof addressing Mr Scrooge or Mr MarleyMr Marley has been dead these seven yearsScrooge replied He died seven years ago this verynightWe have no doubt his liberality is well representedby his surviving partner said the gentleman presentinghis credentialsIt certainly was for they had been two kindredspirits At the ominous word liberality Scroogefrowned and shook his head and handed the credentialsbackAt this festive season of the year Mr Scroogesaid the gentleman taking up a pen it is more thanusually desirable that we should make some slightprovision for the Poor and destitute who suffergreatly at the present time Many thousands are inwant of common necessaries hundreds of thousandsare in want of common comforts sirAre there no prisons asked ScroogePlenty of prisons said the gentleman laying downthe pen againAnd the Union workhouses demanded ScroogeAre they still in operationThey are Still returned the gentleman I wishI could say they were notThe Treadmill and the Poor Law are in full vigourthen said ScroogeBoth very busy sirOh I was afraid from what you said at firstthat something had occurred to stop them in theiruseful course said Scrooge Im very glad tohear itUnder the impression that they scarcely furnishChristian cheer of mind or body to the multitudereturned the gentleman a few of us are endeavouringto raise a fund to buy the Poor some meat and drinkand means of warmth We choose this time becauseit is a time of all others when Want is keenly feltand Abundance rejoices What shall I put you downforNothing Scrooge repliedYou wish to be anonymousI wish to be left alone said Scrooge Since youask me what I wish gentlemen that is my answerI dont make merry myself at Christmas and I cantafford to make idle people merry I help to supportthe establishments I have mentionedthey costenough and those who are badly off must go thereMany cant go there and many would rather dieIf they would rather die said Scrooge they hadbetter do it and decrease the surplus populationBesidesexcuse meI dont know thatBut you might know it observed the gentlemanIts not my business Scrooge returned Itsenough for a man to understand his own business andnot to interfere with other peoples Mine occupiesme constantly Good afternoon gentlemenSeeing clearly that it would be useless to pursuetheir point the gentlemen withdrew Scrooge resumedhis labours with an improved opinion of himselfand in a more facetious temper than was usualwith himMeanwhile the fog and darkness thickened so thatpeople ran about with flaring links proffering theirservices to go before horses in carriages and conductthem on their way The ancient tower of a churchwhose gruff old bell was always peeping slily downat Scrooge out of a Gothic window in the wall becameinvisible and struck the hours and quarters in theclouds with tremulous vibrations afterwards as ifits teeth were chattering in its frozen head up thereThe cold became intense In the main street at thecorner of the court some labourers were repairingthe gaspipes and had lighted a great fire in a brazierround which a party of ragged men and boys weregathered warming their hands and winking theireyes before the blaze in rapture The waterplugbeing left in solitude its overflowings sullenly congealedand turned to misanthropic ice The brightnessof the shops where holly sprigs and berriescrackled in the lamp heat of the windows made palefaces ruddy as they passed Poulterers and grocerstrades became a splendid joke a glorious pageantwith which it was next to impossible to believe thatsuch dull principles as bargain and sale had anythingto do The Lord Mayor in the stronghold of themighty Mansion House gave orders to his fifty cooksand butlers to keep Christmas as a Lord Mayorshousehold should and even the little tailor whom hehad fined five shillings on the previous Monday forbeing drunk and bloodthirsty in the streets stirred uptomorrows pudding in his garret while his leanwife and the baby sallied out to buy the beefFoggier yet and colder Piercing searching bitingcold If the good Saint Dunstan had but nippedthe Evil Spirits nose with a touch of such weatheras that instead of using his familiar weapons thenindeed he would have roared to lusty purpose Theowner of one scant young nose gnawed and mumbledby the hungry cold as bones are gnawed by dogsstooped down at Scrooges keyhole to regale him witha Christmas carol but at the first sound of        God bless you merry gentleman         May nothing you dismayScrooge seized the ruler with such energy of actionthat the singer fled in terror leaving the keyhole tothe fog and even more congenial frostAt length the hour of shutting up the countinghousearrived With an illwill Scrooge dismounted from hisstool and tacitly admitted the fact to the expectantclerk in the Tank who instantly snuffed his candle outand put on his hatYoull want all day tomorrow I suppose saidScroogeIf quite convenient sirIts not convenient said Scrooge and its notfair If I was to stop halfacrown for it youdthink yourself illused Ill be boundThe clerk smiled faintlyAnd yet said Scrooge you dont think me illusedwhen I pay a days wages for no workThe clerk observed that it was only once a yearA poor excuse for picking a mans pocket everytwentyfifth of December said Scrooge buttoninghis greatcoat to the chin But I suppose you musthave the whole day Be here all the earlier nextmorningThe clerk promised that he would and Scroogewalked out with a growl The office was closed in atwinkling and the clerk with the long ends of hiswhite comforter dangling below his waist for heboasted no greatcoat went down a slide on Cornhillat the end of a lane of boys twenty times inhonour of its being Christmas Eve and then ran hometo Camden Town as hard as he could pelt to playat blindmansbuffScrooge took his melancholy dinner in his usualmelancholy tavern and having read all the newspapers andbeguiled the rest of the evening with hisbankersbook went home to bed He lived inchambers which had once belonged to his deceasedpartner They were a gloomy suite of rooms in alowering pile of building up a yard where it had solittle business to be that one could scarcely helpfancying it must have run there when it was a younghouse playing at hideandseek with other housesand forgotten the way out again It was old enoughnow and dreary enough for nobody lived in it butScrooge the other rooms being all let out as officesThe yard was so dark that even Scrooge who knewits every stone was fain to grope with his handsThe fog and frost so hung about the black old gatewayof the house that it seemed as if the Genius ofthe Weather sat in mournful meditation on thethresholdNow it is a fact that there was nothing at allparticular about the knocker on the door except that itwas very large It is also a fact that Scrooge hadseen it night and morning during his whole residencein that place also that Scrooge had as little of whatis called fancy about him as any man in the city ofLondon even includingwhich is a bold wordthecorporation aldermen and livery Let it also beborne in mind that Scrooge had not bestowed onethought on Marley since his last mention of hisseven years dead partner that afternoon And thenlet any man explain to me if he can how it happenedthat Scrooge having his key in the lock of the doorsaw in the knocker without its undergoing any intermediateprocess of changenot a knocker but Marleys faceMarleys face It was not in impenetrable shadowas the other objects in the yard were but had adismal light about it like a bad lobster in a darkcellar It was not angry or ferocious but lookedat Scrooge as Marley used to look with ghostlyspectacles turned up on its ghostly forehead Thehair was curiously stirred as if by breath or hot airand though the eyes were wide open they were perfectlymotionless FROM documents
    SQL
  end
end