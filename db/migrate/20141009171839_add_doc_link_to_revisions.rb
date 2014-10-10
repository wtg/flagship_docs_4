class AddDocLinkToRevisions < ActiveRecord::Migration
  def change
    add_column :revisions, :doc_link, :string
  end
end
