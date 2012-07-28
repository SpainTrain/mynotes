class NotesController < ApplicationController
	
	#Get list of all notes
	def index
		@notes = []
		respond_to do |format|
			format.json { render :json => @notes }
		end
	end

	#Return html page for creating a new photo
	def new
		respond_to do |format|
			format.html	# new.html.erb
		end
	end

	#create a new note
	def create
	end
	
	def show
		#params[:id]
	end

	def edit
		#params[:id]
	end

	def update
		#params[:id]
	end

	def destroy
		#params[:id]
	end
end
