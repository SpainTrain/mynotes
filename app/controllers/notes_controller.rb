require 'haml/html'

class NotesController < ApplicationController
  before_filter :check_logout, :only => [:new]
  before_filter :check_session, :except =>[:new]
  before_filter :check_token

	#Get list of all notes
	def index
    if @logged_in
      session[:oauth_sess].merge_gems session[:notes], session[:oauth_sess].gem_list
    end

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
      _new_id = _new_note[:gem_instance_id].split('#')[2]
      _new_note[:url] = note_url(_new_id),
      session[:notes][_new_id] = _new_note
      redirect_to view_context.oauth_url edit_note_url(_new_id)
    else
		  _new_id = (0...32).map{ "%01x" % rand(2**4) }.join
		  _new_id.insert(-25, '-').insert(-21, '-').insert(-17, '-').insert(-13,'-')
      _note_hash[:url] = note_url(_new_id)
      session[:notes][_new_id] = _note_hash

		  respond_to do |format|
			  format.json { render :json => :session['notes'][_new_id] }
			  format.html { redirect_to edit_note_path(_new_id) }
		  end
    end
	end
	
  #Display html with existing note
	def show
		#params[:id]
    id = params[:id]
    
    if @logged_in
      #need to handle edge case of being redirected here from login w/ unprimed session
      #(in other cases a merge would have already happened)
    end

    #Check for uninitialized notes hash or no item found
    if not session[:notes].key?id then
      redirect_to new_note_path, :notice => "We don't appear to know a note by that name here."
    end

    #populate controller vars
    @note = session[:notes][id].dup
    @note_id = id
    
    #render note body from haml to html
    if @note.key?:body
      eng = Haml::Engine.new(@note[:body])
      @note[:body] = eng.render
    end

    #render
		respond_to do |format|
			format.html	# show.html.haml
		end
	end
  
  #Display html for editing note
	def edit
		#params[:id]
    id = params[:id]
    
    if @logged_in
      #need to handle edge case of being redirected here from login with unprimed session
      #(in other cases a merge would have already happened)
    end

    #populate controller vars
    @note = session[:notes][id].dup
    @note_id = id
    
    #render note body from haml to html
    if @note.key?:body
      eng = Haml::Engine.new(@note[:body])
      @note[:body] = eng.render
    end
		
    respond_to do |format|
			format.html	# edit.html.haml
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
    end

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
      deleted_item = session[:notes][id]
      session[:notes].delete(id)
      notice = "Note '#{deleted_item[:title]}' successfully deleted"
    end

    if @logged_in and deleted_item.key?:gem_instance_id
      session[:oauth_sess].destroy_gem deleted_item[:gem_instance_id]
    end

		#render
    respond_to do |format|
			format.json { render :json => deleted_item }
      format.html { redirect_to new_note_path, :notice => notice }
		end
	end

  protected
    def check_logout
      if params.key?:logout
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
      if params.key?:code and params[:code] != session[:code]
        session[:code] = params[:code]
        session[:oauth_sess] = OauthSession.new params[:code], "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
      end
      if session.key?:oauth_sess
        @logged_in = true
      end
    end
end
