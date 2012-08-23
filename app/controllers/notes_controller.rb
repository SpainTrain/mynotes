class NotesController < ApplicationController

  before_filter :check_session, :except =>[:new]
  before_filter :check_token

	#Get list of all notes
	def index
	  #TODO if logged in
      #get from PAPI, place into session
		respond_to do |format|
      format.json { render :json => session[:notes] }
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
		_new_id = (0...31).map{ "%01x" % rand(2**4) }.join
		session[:notes][_new_id] = {
      :title => params[:new_note_title], 
      :body => "", 
      :url => note_path(_new_id),
      :last_saved => Time.now
      #:last_saved => (Time.now.to_f * 1000).to_i
    }

		#TODO if logged in
			#create it via API

		respond_to do |format|
			format.json { render :json => :session['notes'][_new_id] }
			format.html { redirect_to edit_note_path(_new_id) }
		end
	end
	
  #Display html with existing note
	def show
		#params[:id]
    id = params[:id]
    
    #TODO if logged in
      #pull from PAPI, place into session

    #Check for uninitialized notes hash or no item found
    if not defined? session[:notes][id] then
      redirect_to new_note_path, :notice => "We don't appear to know a note by that name here."
    end

    #populate controller vars
    @note = session[:notes][id]
    @note_id = id

    #render
		respond_to do |format|
			format.html	# show.html.haml
		end
	end
  
  #Display html for editing note
	def edit
		#params[:id]
    id = params[:id]
    
    #Controller vars
    @note_id = id;
    @note = session[:notes][id]
		
    respond_to do |format|
			format.html	# edit.html.haml
		end
	end

  #Update note from provided data
	def update
		#params[:id]
    id = params[:id]

    #copy updated info into session[:notes][params[:id]]
    note = session[:notes][id]
    note[:title] = params[:note][:title] || note[:title]
    note[:body] = params[:note][:body] || note[:body]
    note[:url] = note_url(id)
    note[:last_saved] = Time.now
    #note[:last_saved] = (Time.now.to_f * 1000).to_i

    #TODO if params[:hard_save] and logged in
      #Update via PAPI

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

    #TODO if signed in
      #remove using PAPI

		#render
    respond_to do |format|
			format.json { render :json => deleted_item }
      format.html { redirect_to new_note_path, :notice => notice }
		end
	end

  protected
    def check_session
      if not defined? session[:notes]
        session[:notes] = {}
      end
    end

    def check_token
      if defined? params[:code]
        debugger
        session[:code] = params[:code]
      end
    end
end
