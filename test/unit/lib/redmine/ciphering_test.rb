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
require File.expand_path('../../../../test_helper', __FILE__)

class Redmine::CipheringTest < ActiveSupport::TestCase

  def test_password_should_be_encrypted
    Redmine::Configuration.with 'database_cipher_key' => 'secret' do
      r = Repository::Subversion.generate!(:password => 'foo')
      assert_equal 'foo', r.password
      assert r.read_attribute(:password).match(/\Aaes-256-cbc:.+\Z/)
    end
  end

  def test_password_should_be_clear_with_blank_key
    Redmine::Configuration.with 'database_cipher_key' => '' do
      r = Repository::Subversion.generate!(:password => 'foo')
      assert_equal 'foo', r.password
      assert_equal 'foo', r.read_attribute(:password)
    end
  end

  def test_password_should_be_clear_with_nil_key
    Redmine::Configuration.with 'database_cipher_key' => nil do
      r = Repository::Subversion.generate!(:password => 'foo')
      assert_equal 'foo', r.password
      assert_equal 'foo', r.read_attribute(:password)
    end
  end

  def test_unciphered_password_should_be_readable
    Redmine::Configuration.with 'database_cipher_key' => nil do
      r = Repository::Subversion.generate!(:password => 'clear')
    end

    Redmine::Configuration.with 'database_cipher_key' => 'secret' do
      r = Repository.first(:order => 'id DESC')
      assert_equal 'clear', r.password
    end
  end

  def test_encrypt_all
    Repository.delete_all
    Redmine::Configuration.with 'database_cipher_key' => nil do
      Repository::Subversion.generate!(:password => 'foo')
      Repository::Subversion.generate!(:password => 'bar')
    end

    Redmine::Configuration.with 'database_cipher_key' => 'secret' do
      assert Repository.encrypt_all(:password)
      r = Repository.first(:order => 'id DESC')
      assert_equal 'bar', r.password
      assert r.read_attribute(:password).match(/\Aaes-256-cbc:.+\Z/)
    end
  end

  def test_decrypt_all
    Repository.delete_all
    Redmine::Configuration.with 'database_cipher_key' => 'secret' do
      Repository::Subversion.generate!(:password => 'foo')
      Repository::Subversion.generate!(:password => 'bar')

      assert Repository.decrypt_all(:password)
      r = Repository.first(:order => 'id DESC')
      assert_equal 'bar', r.password
      assert_equal 'bar', r.read_attribute(:password)
    end
  end
end
