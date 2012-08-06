#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2012 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

package Apache::Authn::ChiliProject;

=head1 Apache::Authn::ChiliProject

ChiliProject - A mod_perl module to authenticate webdav and git
smart-HTTP users against a ChiliProject instance

=head1 SYNOPSIS

This module allows anonymous users to browse public project and
registred users to browse and commit to their projects. Authentication
is done against a ChiliProject instance.

=head1 INSTALLATION

Sorry Ruby users but you need some Perl for your Apache, at least mod_perl2.
On debian/ubuntu you can install it with:

  aptitude install libapache2-mod-perl2

=head1 CONFIGURATION

  ## This module has to be in your perl path
  ## eg:  /usr/lib/perl5/Apache/Authn/ChiliProject.pm
  PerlLoadModule Apache::Authn::ChiliProject
  <Location /svn>
    DAV svn
    SVNParentPath "/var/svn"

    AuthType Basic
    AuthName ChiliProject
    Require valid-user

    PerlAccessHandler Apache::Authn::ChiliProject::access_handler
    PerlAuthenHandler Apache::Authn::ChiliProject::authen_handler

    # The full URL to your ChiliProject instance
    ChiliProjectBaseUrl "http://your.server/chiliproject"

    # The key as enterd in your ChiliProject in
    # Administration -> Settings -> Repositories -> API key
    ChiliProjectApiKey "supersecretsupersecret"

    ## Optional Settings

    ## Overwrite the permissions to check for read and write access
    # ChiliProjectReadPermission "browse_repository"
    # ChiliProjectWritePermission "commit_access"

    ## Activate support for the git smart HTTP protocol (see below)
    # ChiliProjectGitSmartHttp yes
  </Location>

To be able to browse repository inside ChiliProject, you can add something
like this:

  <Location /svn-private>
    DAV svn
    SVNParentPath "/var/svn"
    Order deny,allow
    Deny from all
    # only allow reading orders
    <Limit GET PROPFIND OPTIONS REPORT>
      Allow from chiliproject.server.ip
    </Limit>
  </Location>

and you will have to use this reposman.rb command line to create repository :

  reposman.rb --redmine your.chiliproject.server --svn-dir /var/svn --owner www-data -u http://svn.server/svn-private/

=head1 GIT SMART HTTP SUPPORT

Git's smart HTTP protocol (available since Git 1.7.0) will not work with the
above settings. ChiliProject.pm by default does access control depending on
the HTTP method used: read-only methods are OK for everyone in public projects
and members with read rights in private projects. The rest require membership
with commit rights in the project.

However, this scheme doesn't work for Git's smart HTTP protocol, as it will use
POST even for a simple clone. Instead, read-only requests must be detected using
the full URL (including the query string): anything that doesn't belong to the
git-receive-pack service is read-only.

To activate this mode of operation, add this line inside your <Location /git>
block:

  ChiliProjectGitSmartHttp yes

Here's a sample Apache configuration which integrates git-http-backend with
this new option:

    SetEnv GIT_PROJECT_ROOT /var/www/git/
    SetEnv GIT_HTTP_EXPORT_ALL
    ScriptAlias /git/ /usr/libexec/git-core/git-http-backend/
    <Location /git>
      Order allow,deny
      Allow from all

      AuthType Basic
      AuthName Git
      Require valid-user

      PerlAccessHandler Apache::Authn::ChiliProject::access_handler
      PerlAuthenHandler Apache::Authn::ChiliProject::authen_handler

      ChiliProjectBaseUrl "http://your.server/chiliproject"
      ChiliProjectApiKey "supersecretsupersecret"

       ChiliProjectGitSmartHttp yes
    </Location>

Make sure that all the names of the repositories under /var/www/git/ match
exactly the identifier for some project: /var/www/git/myproject.git won't work,
due to the way this module extracts the identifier from the URL.
/var/www/git/myproject will work, though. You can put both bare and non-bare
repositories in /var/www/git, though bare repositories are strongly
recommended. You should create them with the rights of the user running
ChiliProject, like this:

  cd /var/www/git
  sudo -u user-running-chiliproject mkdir myproject
  cd myproject
  sudo -u user-running-chiliproject git init --bare

Once you have activated this option, you have three options when cloning a
repository:

- Cloning using "http://user@host/git/repo" works, but will ask for the password
  all the time.

- Cloning with "http://user:pass@host/git/repo" does not have this problem, but
  this could reveal accidentally your password to the console in some versions
  of Git, and you would have to ensure that .git/config is not readable except
  by the owner for each of your projects.

- Use "http://host/git/repo", and store your credentials in the ~/.netrc
  file. This is the recommended solution when using Git <= 1.7.9 on the client,
  as you only have one file to protect and passwords will not be leaked
  accidentally to the console.

  IMPORTANT NOTE: It is *very important* that the file cannot be read by other
  users, as it will contain the sys in cleartext. To create the file, you
  can use the following commands, replacing yourhost, youruser and yourpassword
  with the right values:

    touch ~/.netrc
    chmod 600 ~/.netrc
    echo -e "machine yourhost\nlogin youruser\npassword yourpassword" > ~/.netrc

- Use "http://host/git/repo" and use the Git >= 1.7.9 on the client.
  This version introduced a new credential API wich allows to cache
  credentials safely on disk. Using this is the best compromise between
  password security and usability.

  See https://github.com/blog/1104-credential-caching-for-wrist-friendly-git-usage
  for more information

=cut

use strict;
use warnings FATAL => 'all'; #, NONFATAL => 'redefine';

use Apache2::Module;
use Apache2::Access;
use Apache2::ServerRec qw();
use Apache2::RequestRec qw();
use Apache2::RequestUtil qw();
use Apache2::Const qw(:common :override :cmd_how);

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;

my @directives = (
  {
    name => 'ChiliProjectBaseUrl',
    req_override => OR_AUTHCFG,
    args_how => TAKE1,
    errmsg => "URL of your (local) ChiliProject, e.g., http://localhost or http://example.com/chiliproject",
  },
  {
    name => 'ChiliProjectApiKey',
    req_override => OR_AUTHCFG,
    args_how => TAKE1,
    errmsg => "The API key as entered in Administration -> Settings -> Repositories -> API key"
  },
  {
    name => 'ChiliProjectReadPermission',
    req_override => OR_AUTHCFG,
    args_how => TAKE1,
  },
  {
    name => 'ChiliProjectWritePermission',
    req_override => OR_AUTHCFG,
    args_how => TAKE1,
  },
  {
    name => 'ChiliProjectGitSmartHttp',
    req_override => OR_AUTHCFG,
    args_how => TAKE1,
  },
);

sub ChiliProjectBaseUrl { set_val('ChiliProjectBaseUrl', @_); }
sub ChiliProjectApiKey { set_val('ChiliProjectApiKey', @_); }
sub ChiliProjectReadPermission { set_val('ChiliProjectReadPermission', @_); }
sub ChiliProjectWritePermission { set_val('ChiliProjectWritePermission', @_); }

sub ChiliProjectGitSmartHttp {
  my ($self, $parms, $arg) = @_;
  $arg = lc $arg;

  if ($arg eq "yes" || $arg eq "true") {
    $self->{ChiliProjectGitSmartHttp} = 1;
  } else {
    $self->{ChiliProjectGitSmartHttp} = 0;
  }
}

sub trim {
  my $string = shift;
  $string =~ s/\s{2,}/ /g;
  return $string;
}

sub set_val {
  my ($key, $self, $parms, $arg) = @_;
  $self->{$key} = $arg;
}

Apache2::Module::add(__PACKAGE__, \@directives);

sub access_handler {
  my $r = shift;

  unless ($r->some_auth_required) {
    $r->log_reason("No authentication has been configured");
    return FORBIDDEN;
  }

  return OK
}

sub authen_handler {
  my $r = shift;

  my ($status, $password) =  $r->get_basic_auth_pw();
  return $status unless $status == OK;

  my $login = $r->user;
  my $identifier = get_project_identifier($r);
  my $read_only = request_is_read_only($r);

  if( is_access_allowed( $login, $password, $identifier, $read_only, $r ) ) {
    return OK;
  } else {
    $r->note_auth_failure();
    return DECLINED;
  }
}

my %read_only_methods = map { $_ => 1 } qw/GET HEAD PROPFIND REPORT OPTIONS/;

sub request_is_read_only {
  my ($r) = @_;
  my $cfg = Apache2::Module::get_config(__PACKAGE__, $r->server, $r->per_dir_config);

  # Do we use Git's smart HTTP protocol, or not?
  if (defined $cfg->{ChiliProjectGitSmartHttp} and $cfg->{ChiliProjectGitSmartHttp}) {
    my $uri = $r->unparsed_uri;
    my $location = $r->location;
    my $is_read_only = $uri !~ m{^$location/*[^/]+/+(info/refs\?service=)?git\-receive\-pack$}o;
    return $is_read_only;
  } else {
    # Default behaviour: check the HTTP method
    my $method = $r->method;
    return defined $read_only_methods{$method};
  }
}

# We send a request to ChiliProject's sys API
# and use the user's given login and password for basic auth.
#
# For accessing the ChiliProject sys API an API key is needed most of the time.
sub is_access_allowed {
  my $login = shift;
  my $password = shift;
  my $identifier = shift;
  my $read_only = shift;
  my $r = shift;

  my $cfg = Apache2::Module::get_config( __PACKAGE__, $r->server, $r->per_dir_config );

  my $auth_url = $cfg->{ChiliProjectBaseUrl} . '/sys/projects/' . $identifier .'/auth';
  my $key = $cfg->{ChiliProjectApiKey};

  my $permission;
  if ($read_only) {
    $permission = (defined $cfg->{ChiliProjectReadPermission}) ? $cfg->{ChiliProjectReadPermission} : "browse_repository";
  } else {
    $permission = (defined $cfg->{ChiliProjectWritePermission}) ? $cfg->{ChiliProjectWritePermission} : "commit_access";
  }

  my $chili_req = POST $auth_url, [ key => $key, permission => $permission ];
  $chili_req->authorization_basic($login, $password);

  my $ua = LWP::UserAgent->new;
  my $response = $ua->request($chili_req);

  $r->log_reason($response->message) unless $response->is_success();
  return $response->is_success();
}

sub get_project_identifier {
  my $r = shift;

  my $cfg = Apache2::Module::get_config(__PACKAGE__, $r->server, $r->per_dir_config);
  my $location = $r->location;
  my ($identifier) = $r->uri =~ m{$location/*([^/]+)};
  $identifier =~ s/\.git$// if (defined $cfg->{ChiliProjectGitSmartHttp} and $cfg->{ChiliProjectGitSmartHttp});
  $identifier;
}

1;
