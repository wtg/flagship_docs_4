##
# Rake task to import data from a Flagship Rails 2 Database 
#  
# Procedure:
# 1. Export the Rails 2 database as a YAML file
# 2. Place this YAML file in the 'db' directory 
#    of the Rails 4 application
# 3. Run 'rake import:legacy_rails_2' to import the data
# 
# This task imports data in the following order to ensure success:
#   1. Users
#   2. Groups
#   3. GroupsUsers (now called memberships)
#   4. Categories
#   5. Documents
#   6. Revisions
#
##
namespace :import_rails2 do

  def load_parse_yaml(name)
    begin
      # Load YAML file containing Rails 2 Data from db folder
      legacy_yaml = YAML.load_file(Rails.root + "db/#{name}.yml")
      return legacy_yaml
    rescue Exception => e
      # An error has occured while importing data
      puts e.message
      puts e.backtrace.inspect
    end
  end

  desc 'Import Rails 2 Legacy Users.'
  task users: :environment do 
    require 'yaml'
    legacy_db = load_parse_yaml("rails2_users")
    # Map legacy user id to new created user id
    mapping = {}

    legacy_db.each do |user|
      # Build new user with the imported yaml data
      new_user = User.new(
        username: user["username"],
        email: user["username"] + "@rpi.edu",
        full_name: user["full_name"],
        is_admin: user["is_admin"],
        updated_at: user["updated_at"],
        created_at: user["created_at"]
        )
      if new_user.save
        # Successfully saved our new user to the Flagship 4 database
        mapping[user["id"]] = new_user.id
        puts "[SUCCESS] Created user: #{user["username"]}: #{new_user.id}"
      else
        # Error: unable to save this record
        puts "[ERROR] Unable to save user: #{user["username"]}"
      end
    end
  end
  
end