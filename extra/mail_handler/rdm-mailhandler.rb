#!/usr/bin/env ruby
#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

# == Synopsis
#
# Reads an email from standard input and forward it to a Redmine server
# through a HTTP request.
#
# == Usage
#
#    rdm-mailhandler [options] --url=<Redmine URL> --key=<API key>
#
# == Arguments
#
#   -u, --url                      URL of the Redmine server
#   -k, --key                      Redmine API key
#
# General options:
#       --unknown-user=ACTION      how to handle emails from an unknown user
#                                  ACTION can be one of the following values:
#                                  ignore: email is ignored (default)
#                                  accept: accept as anonymous user
#                                  create: create a user account
#       --no-permission-check      disable permission checking when receiving
#                                  the email
#   -h, --help                     show this help
#   -v, --verbose                  show extra information
#   -V, --version                  show version information and exit
#
# Issue attributes control options:
#   -p, --project=PROJECT          identifier of the target project
#   -s, --status=STATUS            name of the target status
#   -t, --tracker=TRACKER          name of the target tracker
#       --category=CATEGORY        name of the target category
#       --priority=PRIORITY        name of the target priority
#   -o, --allow-override=ATTRS     allow email content to override attributes
#                                  specified by previous options
#                                  ATTRS is a comma separated list of attributes
#
# == Examples
# No project specified. Emails MUST contain the 'Project' keyword:
#
#   rdm-mailhandler --url http://redmine.domain.foo --key secret
#
# Fixed project and default tracker specified, but emails can override
# both tracker and priority attributes using keywords:
#
#   rdm-mailhandler --url https://domain.foo/redmine --key secret \\
#                   --project foo \\
#                   --tracker bug \\
#                   --allow-override tracker,priority

require 'net/http'
require 'net/https'
require 'uri'
require 'optparse'

module Net
  class HTTPS < HTTP
    def self.post_form(url, params, headers)
      request = Post.new(url.path)
      request.form_data = params
      request.basic_auth url.user, url.password if url.user
      request.initialize_http_header(headers)
      http = new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')
      http.start {|h| h.request(request) }
    end
  end
end

class RedmineMailHandler
  VERSION = '0.2'

  attr_accessor :verbose, :issue_attributes, :allow_override, :unknown_user, :no_permission_check, :url, :key
      @allow_override = []
  def initialize

    self.issue_attributes = {}

    optparse = OptionParser.new do |opts|
      
      
      opts.banner = "rdm-mailhandler [options] --url=<Redmine URL> --key=<API key>"
      opts.separator("")
      opts.separator("Required arguments:")
      opts.on("-u", "--url URL",            "URL of the Redmine server") {|v| self.url = v}
      opts.on("-k", "--key KEY",            "Redmine API key") {|v| self.key = v}
      opts.separator("")
      opts.separator("Options:")
      opts.on("--unknown-user",             "how to handle emails from an unknown user",
                                            "ACTION can be one of the following values:",
                                            "ignore: email is ignored (default)",
                                            "accept: accept as anonymous user",
                                            "create: create a user account") {|v| self.unknown_user = v}
      opts.on("--no-permission-check",      "disable permission checking when receiving",
                                            "the email") {self.no_permission_check= '1'}
      opts.on("-v", "--verbose",            "verbose") {self.verbose = true}
      opts.on("-V", "--version",            "show version and exit") {puts VERSION; exit}
      opts.separator("")
      opts.separator("Issue attributes control options:")
      opts.on("-p", "--project PROJECT",    "identifier of the target project") {|v| self.project = v}
      opts.on("-s", "--status STATUS",      "name of the target status") {|v| self.status = v}
      opts.on("-t", "--tracker TRACKER",    "name of the target tracker") {|v| self.tracker = v}
      opts.on("--category CATEGORY",        "name of the target category") {|v| self.category = v}
      opts.on("--priority PRIORITY",        "name of the target priority") {|v| self.priority = v}
      opts.on("--allow-override OVERRIDE",  "allow email content to override attributes",
                                            "ATTRS is a comma separated list of attributes") {|v| self.allow_override = v}
      opts.on("-h", "--help",               "show help and exit") do
        puts opts
        exit 1
      end
    end
    optparse.parse!

  end

  def submit(email)
    uri = url.gsub(%r{/*$}, '') + '/mail_handler'

    headers = { 'User-Agent' => "Redmine mail handler/#{VERSION}" }

    data = { 'key' => key, 'email' => email,
                           'allow_override' => allow_override,
                           'unknown_user' => unknown_user,
                           'no_permission_check' => no_permission_check}
    issue_attributes.each { |attr, value| data["issue[#{attr}]"] = value }

    debug "Posting to #{uri}..."
    response = Net::HTTPS.post_form(URI.parse(uri), data, headers)
    debug "Response received: #{response.code}"

    case response.code.to_i
      when 403
        warn "Request was denied by your Redmine server. " +
             "Make sure that 'WS for incoming emails' is enabled in application settings and that you provided the correct API key."
        return 77
      when 422
        warn "Request was denied by your Redmine server. " +
             "Possible reasons: email is sent from an invalid email address or is missing some information."
        return 77
      when 400..499
        warn "Request was denied by your Redmine server (#{response.code})."
        return 77
      when 500..599
        warn "Failed to contact your Redmine server (#{response.code})."
        return 75
      when 201
        debug "Proccessed successfully"
        return 0
      else
        return 1
    end
  end

  private

  def debug(msg)
    puts msg if verbose
  end
end

handler = RedmineMailHandler.new
exit(handler.submit(STDIN.read))