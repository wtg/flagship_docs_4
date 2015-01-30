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

  ## 
  # Mapping code and concept courtesy of (@bamnet) https://github.com/bamnet 
  # https://github.com/concerto/concerto/commits/master/lib/tasks/import.rake?author=bamnet
  ## 
  def load_mapping(object, filename="mapping.csv")
    require 'csv'
    mapping = {}
    # Iterate through each row of the mapping csv
    #  only storing the requested object's mapping (ex: user, group, document, etc.)
    CSV.foreach(filename) do |row|
      obj, old_id, new_id = row
      if obj != object
        # requested object mapping does not match this row
        next
      else
        # store the requested object's new id using the old id as a key
        mapping[old_id.to_i] = new_id.to_i
      end
    end
    return mapping
  end

  def save_mapping(object, mapping, filename="mapping.csv")
    require 'csv'
    # Save each mapping between legacy id and newly created object id
    CSV.open(filename, 'ab') do |csv|
      mapping.each do |old_id, new_id|
        csv << [object, old_id, new_id]
      end
    end
  end

  def load_parse_yaml(name)
    begin
      # Load YAML file containing Rails 2 data from db folder
      legacy_yaml = YAML.load_file(Rails.root + "db/#{name}.yml")
      return legacy_yaml
    rescue Exception => e
      # An error has occured while importing data
      puts e.message
      puts e.backtrace.inspect
    end
  end

  ##
  # Task to import users from a Rails 2 to Rails 4 deployment
  ##
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
    # Save user mappings ['user', old_id, new_id]
    save_mapping('user', mapping)
  end

  ##
  # Task to import groups from a Rails 2 to Rails 4 deployment
  ##
  desc 'Import Rails 2 Legacy Groups.'
  task groups: :environment do
    require 'yaml'
    legacy_db = load_parse_yaml("rails2_groups")
    # Map legacy group id to new created group id
    mapping = {}

    legacy_db.each do |group| 
      # Build new group with the imported yaml data
      new_group = Group.new(
        name: group["name"],
        updated_at: group["updated_at"],
        created_at: group["created_at"]
        )
      if new_group.save
        # Successfully saved our new group to the Flagship 4 database
        mapping[group["id"]] = new_group.id
        puts "[SUCCESS] Created group: #{group["name"]}: #{new_group.id}"
      else
        # Error: unable to save this record
        puts "[ERROR] Unable to save group: #{group["name"]}"
      end
    end
    # Save group mappings ['group', old_id, new_id]
    save_mapping('group', mapping)
  end
  
end