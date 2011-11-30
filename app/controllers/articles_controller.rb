require 'daylife'
require 'open-uri'
require 'will_paginate/array' 
require 'tactful_tokenizer'

class ArticlesController < ApplicationController
  # GET /articles
  # GET /articles.json
  def index
    @articles = Article.all.paginate :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @articles }
    end
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    @article = Article.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @article }
    end
  end

  # GET /articles/new
  # GET /articles/new.json
  def new
    @events = Event.all
    @sources = Source.all
    @article = Article.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @article }
    end
  end

  # GET /articles/1/edit
  def edit
    @article = Article.find(params[:id])
  end

  # POST /articles
  # POST /articles.json
  def create
    @daylife = daylife_helper
    m = TactfulTokenizer::Model.new
    num_articles = 0
    params[:event_checkbox].each do |event_key, event_value|
      if event_value == "yes"
        @event = Event.find(event_key)
        str = "source_" + @event.id.to_s()
        params[str.to_sym].each do |source_key, source_value|
          if source_value == "yes"
            @source = Source.find(source_key)
            r = @daylife.execute('search', 'getRelatedArticles', :query => @event.search_string, :limit => 100, :source_whitelist => @source.daylife_id, :start_time => @event.from_date, :end_time => @event.to_date, :sort => 'relevance')
            if(r.success?)
              logger.info 'aditya'
              r.articles.each do |a| 
              
 #               logger.info enrich_data(Readability::Document.new(source).content)
                #              logger.info a.url
                #                logger.info a.nil?
                begin
                  source =   open(a.url).read
                  
                  @article = Article.new
                  @article.headline = a.headline
                  @article.url = a.url
                  content = Readability::Document.new(source).content
                  logger.info m.tokenize_text(content).count
                  @article.content =  enrich_data(content)
                  @article.sentence_count = m.tokenize_text(@article.content).count
                  @article.source_id = @source.id
                  @article.event_id = @event.id
                  #  logger.info @article.content

                  # Save the article only if the sentence count 
                  # count is greater that 10, since small articles are 
                  # of no use to us.
                  if @article.sentence_count > 10
                    if @article.save
                      num_articles += 1
                    else
                      logger.info 'Could not save the article ' + a.url
                    end
                  end

                rescue => e
                    logger.info "error is: #{e}"
                end
              end
            else 
              # output the error message 
              logger.info "Error: #{r.code}: #{r.message}" 
            end 
          end
        end
        logger.info @event.name
      end
    end
    respond_to do |format|
        format.html { redirect_to articles_url , notice: num_articles.to_s() + ' number of articles was successfully created.' }
       # format.json { render json: @article, status: :created, location: @article }
    end
  end

  # PUT /articles/1
  # PUT /articles/1.json
  def update
    @article = Article.find(params[:id])

    respond_to do |format|
      if @article.update_attributes(params[:article])
        format.html { redirect_to @article, notice: 'Article was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to articles_url }
      format.json { head :ok }
    end
  end

  # Return a daylife api object
  def daylife_helper
    raw_config = File.read(Rails.root + "config/daylife.yaml")
    daylife_config = YAML.load(raw_config)[Rails.env]
    logger.info 'aditya'
    logger.info daylife_config["api_key"]
    Daylife::API.new(daylife_config["api_key"],daylife_config["shared_secret"]) 
  end

  # Enrich the given html data to give the purest form of text data
  def enrich_data(a)
    b = a.scan(/<p>(.*)<\/p>/)
    b  = b.join("")
    b = b.gsub(/\(.*?\)/,"")
    b = b.gsub(/<.*?>/,"")
   b = b.gsub(/^.*?\(.*?\).*?--/,"")

    # Replace 
    # ? => ?.
    # ! => !.
    # ... => <blank>
    # so that the text is suitable for pcfg parsers
    b = b.gsub(/\?/,"?.")
    b = b.gsub(/\!/,"!.")
    b = b.gsub(/\.\.\./, "")
  end
end
