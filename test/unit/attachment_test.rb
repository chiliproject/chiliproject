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
require File.expand_path('../../test_helper', __FILE__)

class AttachmentTest < ActiveSupport::TestCase
  fixtures :issues, :projects, :users, :issue_statuses, :trackers, :projects_trackers

  def setup
  end

  def test_create
    a = Attachment.new(:container => Issue.find(1),
                       :file => uploaded_test_file("testfile.txt", "text/plain"),
                       :author => User.find(1))
    assert a.save
    assert_equal 'testfile.txt', a.filename
    assert_equal 59, a.filesize
    assert_equal 'text/plain', a.content_type
    assert_equal 0, a.downloads
    assert_equal '1478adae0d4eb06d35897518540e25d6', a.digest
    assert File.exist?(a.diskfile)
  end

  def test_create_should_auto_assign_content_type
    a = Attachment.new(:container => Issue.find(1),
                       :file => uploaded_test_file("testfile.txt", ""),
                       :author => User.find(1))
    assert a.save
    assert_equal 'text/plain', a.content_type
  end

  def test_identical_attachments_at_the_same_time_should_not_overwrite
    a1 = Attachment.create!(:container => Issue.find(1),
                            :file => uploaded_test_file("testfile.txt", ""),
                            :author => User.find(1))
    a2 = Attachment.create!(:container => Issue.find(1),
                            :file => uploaded_test_file("testfile.txt", ""),
                            :author => User.find(1))
    assert a1.disk_filename != a2.disk_filename
  end

  def test_diskfilename
    assert Attachment.disk_filename("test_file.txt") =~ /^\d{12}_test_file.txt$/
    assert_equal 'test_file.txt', Attachment.disk_filename("test_file.txt")[13..-1]
    assert_equal '770c509475505f37c2b8fb6030434d6b.txt', Attachment.disk_filename("test_accentué.txt")[13..-1]
    assert_equal 'f8139524ebb8f32e51976982cd20a85d', Attachment.disk_filename("test_accentué")[13..-1]
    assert_equal 'cbb5b0f30978ba03731d61f9f6d10011', Attachment.disk_filename("test_accentué.ça")[13..-1]
  end

  context "Attachmnet#attach_files" do
    should "add unsaved files to the object as unsaved attachments" do
      # Max size of 0 to force Attachment creation failures
      with_settings(:attachment_max_size => 0) do
        @project = Project.generate!
        response = Attachment.attach_files(@project, {
                                             '1' => {'file' => mock_file, 'description' => 'test'},
                                             '2' => {'file' => mock_file, 'description' => 'test'}
                                           })

        assert response[:unsaved].present?
        assert_equal 2, response[:unsaved].length
        assert response[:unsaved].first.new_record?
        assert response[:unsaved].second.new_record?
        assert_equal response[:unsaved], @project.unsaved_attachments
      end
    end
  end

  context "Attachment#increment_download" do
    should "not create a journal entry" do
      issue = Issue.generate!(:status_id => 1, :tracker_id => 1, :project_id => 1)
      attachment = Attachment.create!(:container => issue,
                              :file => mock_file,
                              :author => User.find(1))

      assert_equal 0, attachment.downloads
      # just the initial journal
      assert_equal 1, attachment.journals.count

      attachment.reload
      attachment.increment_download

      assert_equal 1, attachment.downloads
      # no added journal
      assert_equal 1, attachment.journals.count
    end
  end
end
