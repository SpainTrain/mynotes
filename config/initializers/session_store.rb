# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mynotes_session',
  :secret      => 'c63e74c61b2de3a4c13512c1dbfed45987599b184a75a9cb150444ddf92f8ba076f63bba905f565b73f7ef638dd49cb773e95c8a8f0be4c5a0e39fe30917c348'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
