require 'json'
require 'rest-client'
require 'date'

class LoginController < ApplicationController

  def callback
    # Grab the value of the authorization code returned by Procore
    @authorization_code = params["code"]

    # Populate the request body with the defined parameters from the docs
    # Reference documentation: https://developers.procore.com/reference/authentication
    request = {
      grant_type: "authorization_code",
      client_id: ENV['CLIENT_ID'],
      client_secret: ENV['CLIENT_SECRET'],
      code: @authorization_code,
      redirect_uri: ENV['REDIRECT_URI']
    }

    # Send a request for an access token to Procore and store the response in a session variable
    response = RestClient.post(ENV['OAUTH_URL'] +'/oauth/token', request.to_json, { content_type: :json, accept: :json })
    session[:oauth_response] = JSON.parse(response)

    # Redirect the user's browser to the intended home page
    redirect_to users_home_path
  end


  def refresh
    # Populate the request body with the defined parameters from the docs
    # Reference documentation: https://developers.procore.com/reference/authentication
    request = {
      grant_type: "refresh_token",
      client_id: ENV['CLIENT_ID'],
      client_secret: ENV['CLIENT_SECRET'],
      refresh_token: session[:oauth_response]['refresh_token'],
      redirect_uri: ENV['REDIRECT_URI']
    }

    # Send a request for an access token to Procore and store the response in a session variable
    response = RestClient.post(ENV['OAUTH_URL'] + '/oauth/token', request.to_json, { content_type: :json, accept: :json })
    session[:oauth_response] = JSON.parse(response)

    # Redirect the user's browser to the intended home page
    redirect_to users_home_path
  end

  def revoke
    # Populate the request body with the defined parameters from the docs
    # https://developers.procore.com/reference/authentication#revoke-token
    request = {
      client_id: ENV['CLIENT_ID'],
      client_secret: ENV['CLIENT_SECRET'],
      token: session[:oauth_response]['access_token']
    }
    # Send a request to revoke the access token to Procore and return to the Sign In page.
    response = RestClient.post(ENV['OAUTH_URL'] + '/oauth/revoke', request.to_json)
    puts response
    puts request
    # Deletes current session to clear out session variables
    reset_session
    # the user's browser to the intended home page
    redirect_to login_index_path

  end
end
