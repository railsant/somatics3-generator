require 'active_record/diff'
ActiveRecord::Base.send(:include, ActiveRecord::Diff)