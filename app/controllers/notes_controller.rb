require 'haml/html'
require 'securerandom'

class NotesController < ApplicationController
  before_filter :check_logout
  before_filter :check_session, :except =>[:new]
  before_filter :check_token

	#Get list of all notes
	def index
    if @logged_in
      session[:oauth_sess].merge_gems session[:notes], session[:oauth_sess].gem_list
      session[:notes].each do |id,note| 
        if note[:url] != note_url(id)
          note[:url] = note_url id
          session[:oauth_sess].update_gem note
        end
      end
    end

  rescue => err
    handle_err err
  
  ensure
    respond_to do |format|
      format.json { render :json => session[:notes] }
      format.html { redirect_to new_note_path }
		end
	end

	#Return html page for creating a new note
	def new
		respond_to do |format|
			format.html	# new.html.haml
		end
	end

	#create a new note
	def create
		#add new note to session
    _new_id = ""
    _note_hash = {
      :title => params[:new_note_title], 
      :body => "", 
      :last_saved => Time.now
    }

    if @logged_in
      _new_note = session[:oauth_sess].create_gem _note_hash
      _new_id = _new_note[:gem_instance_id]
      _new_note[:url] = note_url(_new_id),
      session[:notes][_new_id] = _new_note
    else
		  _new_id = (0...32).map{ "%01x" % rand(2**4) }.join
		  _new_id.insert(-25, '-').insert(-21, '-').insert(-17, '-').insert(-13,'-')
      _note_hash[:url] = note_url(_new_id)
      session[:notes][_new_id] = _note_hash
    end

  rescue => err
    handle_err err
  
  ensure
	  respond_to do |format|
		  format.json { render :json => session[:notes][_new_id] }
		  format.html { redirect_to edit_note_path(_new_id) }
	  end
	end

  #Display html with existing note
	def show
		#params[:id]
    id = params[:id]
    redirected = false

    #Check for uninitialized notes hash or no item found
    if not session[:notes].key?id then
      redirect_to new_note_path, :notice => "We don't appear to know a note by that name here."
      redirected = true
      return
    end

    #Check for an unmerged note
    if @logged_in and not session[:notes][id].key?:gem_instance_id
      redirect_to note_path swap_gem id
      redirected = true
      return
    end

    #Update via API
    if @logged_in
      session[:notes][id] = session[:oauth_sess].get_gem session[:notes][id][:gem_instance_id]
    end

    #populate controller vars
    @note = session[:notes][id].dup
    @note_id = id
    
    #render note body from haml to html
    if @note.key?:body and @note[:body] != nil
      eng = Haml::Engine.new(@note[:body])
      @note[:body] = eng.render
    end

  rescue => err
    handle_err err
  
  ensure
    #render
    if not redirected
  		respond_to do |format|
	  		format.html	# show.html.haml
        format.json { render :json => @note }
		  end
    end
	end

  #Display html for editing note
	def edit
		#params[:id]
    id = params[:id]
    redirected = false

    #If this was created before logging in, we need to merge
    if @logged_in and not session[:notes][id].key?:gem_instance_id
      redirect_to edit_note_path swap_gem id
      redirected = true
      return
    end
    
    if @logged_in
      session[:notes][id] = session[:oauth_sess].get_gem session[:notes][id][:gem_instance_id]
    end

    #populate controller vars
    @note = session[:notes][id].dup
    @note_id = id
    
    #render note body from haml to html
    if @note.key?:body and @note[:body] != nil
      eng = Haml::Engine.new(@note[:body])
      @note[:body] = eng.render
    end
		
  rescue => err
    handle_err err
  
  ensure
    if not redirected
      respond_to do |format|
	  		format.html	# edit.html.haml
		  end
    end
	end

  #Update note from provided data
	def update
		#params[:id]
    id = params[:id]
    note = session[:notes][id]

    #haml-fy body if provided
    body_data = note[:body]
    if params[:note].key?:body
      doc = Hpricot(params[:note][:body])
      eng = Haml::HTML.new(doc)
      body_data = eng.render
    end

    #copy updated info into session[:notes][params[:id]]
    note[:title] = params[:note][:title] || note[:title]
    note[:body] = body_data
    note[:url] = note_url(id)
    note[:last_saved] = Time.now

    if @logged_in
      note = session[:oauth_sess].update_gem note
      session[:notes][id] = note
    end

  rescue => err
    handle_err err
  
  ensure
    #render
		respond_to do |format|
			format.json { render :json => note }
      format.html { redirect_to note_path(id) }
		end
	end

  #Remove a note
	def destroy
		#params[:id]
		id = params[:id]
    
    #Default to note not found
    deleted_item = nil
    notice = "You cannot kill that which doesn not live (i.e., note not found)"

		#remove from session[:notes]
    if defined? session[:notes][id] then
      deleted_item = session[:notes].delete(id)
      notice = "Note '#{deleted_item[:title]}' successfully deleted"
    end

    if @logged_in and deleted_item.key?:gem_instance_id
      session[:oauth_sess].destroy_gem deleted_item[:gem_instance_id]
    end

  rescue => err
    handle_err err
  
  ensure
		#render
    respond_to do |format|
			format.json { render :json => deleted_item }
      format.html { redirect_to new_note_path, :notice => notice }
		end
	end

  protected
  #DRY for handling errors (particularly OAuthSessionError)
  def handle_err err
    session.delete "oauth_sess"
    flash[:notice] = "You have been logged out."
    puts err.message
    puts err.backtrace
  end

  def check_logout
    expired = false
    if session.key?:expiration
      expired = Time.now > session[:expiration]
    end
    
    if params.key?:logout or expired
      session.delete('notes')
      session.delete('code')
      session.delete('oauth_sess')
    end
  end

  def check_session
    if not session.key?:notes
      session[:notes] = {}
    end
  end

  def check_token
    if  params.key?:code and 
        params[:code] != session[:code] and 
        session.key?:redirect_uri and 
        session.key?:state_nonce and 
        session[:state_nonce] == params[:state]
      session[:code] = params[:code]
      session[:oauth_sess] = OauthSession.new params[:code], session[:redirect_uri]
      session.delete "redirect_uri"
      session.delete "state_nonce"
    end
    if session.key?:oauth_sess
      @logged_in = true
      session.delete "state_nonce"
      session[:expiration] = 1.day.from_now
    else
      session[:expiration] = 1.hour.from_now
    end
  end
  
  def swap_gem old_id
    _new_note = session[:oauth_sess].create_gem session[:notes][old_id]
    _new_id = _new_note[:gem_instance_id]
    if _new_note[:url] != note_url(_new_id)
      _new_note[:url] = note_url _new_id
      _new_note = session[:oauth_sess].update_gem _new_note
    end
    session[:notes][_new_id] = _new_note
    session[:notes].delete(old_id)
    return _new_id
  end
end
