# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111104110134) do

  create_table "activities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "provider_id"
    t.text     "description"
    t.string   "type"
    t.decimal  "budget"
    t.decimal  "spend"
    t.text     "text_for_provider"
    t.text     "text_for_beneficiaries"
    t.integer  "data_response_id"
    t.integer  "activity_id"
    t.boolean  "approved"
    t.decimal  "spend_in_usd",                 :default => 0.0
    t.decimal  "budget_in_usd",                :default => 0.0
    t.integer  "project_id"
    t.decimal  "ServiceLevelBudget_amount",    :default => 0.0
    t.decimal  "ServiceLevelSpend_amount",     :default => 0.0
    t.boolean  "am_approved"
    t.integer  "user_id"
    t.date     "am_approved_date"
    t.boolean  "coding_budget_valid",          :default => false
    t.boolean  "coding_budget_cc_valid",       :default => false
    t.boolean  "coding_budget_district_valid", :default => false
    t.boolean  "coding_spend_valid",           :default => false
    t.boolean  "coding_spend_cc_valid",        :default => false
    t.boolean  "coding_spend_district_valid",  :default => false
    t.boolean  "planned_for_gor_q1"
    t.boolean  "planned_for_gor_q2"
    t.boolean  "planned_for_gor_q3"
    t.boolean  "planned_for_gor_q4"
  end

  add_index "activities", ["activity_id"], :name => "index_activities_on_activity_id"
  add_index "activities", ["data_response_id"], :name => "index_activities_on_data_response_id"
  add_index "activities", ["provider_id"], :name => "index_activities_on_provider_id"
  add_index "activities", ["type"], :name => "index_activities_on_type"

  create_table "activities_beneficiaries", :id => false, :force => true do |t|
    t.integer "activity_id"
    t.integer "beneficiary_id"
  end

  create_table "activities_organizations", :id => false, :force => true do |t|
    t.integer "activity_id"
    t.integer "organization_id"
  end

  create_table "code_assignments", :force => true do |t|
    t.integer  "activity_id"
    t.integer  "code_id"
    t.string   "type"
    t.decimal  "percentage"
    t.decimal  "cached_amount",        :default => 0.0
    t.decimal  "sum_of_children",      :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "cached_amount_in_usd", :default => 0.0
  end

  add_index "code_assignments", ["code_id"], :name => "index_code_assignments_on_code_id"

  create_table "codes", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "short_display"
    t.string   "long_display"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "external_id"
    t.string   "hssp2_stratprog_val"
    t.string   "hssp2_stratobj_val"
    t.string   "official_name"
    t.string   "sub_account"
    t.string   "nha_code"
    t.string   "nasa_code"
  end

  create_table "comments", :force => true do |t|
    t.text     "comment",          :default => ""
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "currencies", :force => true do |t|
    t.string   "conversion"
    t.float    "rate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_requests", :force => true do |t|
    t.integer  "organization_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "due_date"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "final_review",      :default => false
    t.boolean  "budget_by_quarter", :default => false
  end

  create_table "data_responses", :force => true do |t|
    t.integer  "data_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.string   "state"
    t.integer  "projects_count",  :default => 0
  end

  add_index "data_responses", ["data_request_id"], :name => "index_data_responses_on_data_request_id"
  add_index "data_responses", ["organization_id"], :name => "index_data_responses_on_organization_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "districts", :force => true do |t|
    t.string   "name"
    t.integer  "population"
    t.integer  "old_location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "funding_flows", :force => true do |t|
    t.integer  "organization_id_from"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "budget"
    t.decimal  "spend_q1"
    t.decimal  "spend_q2"
    t.decimal  "spend_q3"
    t.decimal  "spend_q4"
    t.text     "organization_text"
    t.integer  "self_provider_flag",   :default => 0
    t.decimal  "spend"
    t.decimal  "spend_q4_prev"
    t.decimal  "budget_q1"
    t.decimal  "budget_q2"
    t.decimal  "budget_q3"
    t.decimal  "budget_q4"
    t.decimal  "budget_q4_prev"
    t.integer  "project_from_id"
    t.decimal  "budget_in_usd",        :default => 0.0
    t.decimal  "spend_in_usd",         :default => 0.0
  end

  add_index "funding_flows", ["project_id"], :name => "index_funding_flows_on_project_id"
  add_index "funding_flows", ["self_provider_flag"], :name => "index_funding_flows_on_self_provider_flag"

  create_table "implementer_splits", :force => true do |t|
    t.integer  "activity_id"
    t.integer  "organization_id"
    t.decimal  "spend"
    t.decimal  "budget"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "double_count"
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "raw_type"
    t.string   "fosaid"
    t.integer  "users_count",                      :default => 0
    t.string   "currency"
    t.date     "fiscal_year_start_date"
    t.date     "fiscal_year_end_date"
    t.string   "contact_name"
    t.string   "contact_position"
    t.string   "contact_phone_number"
    t.string   "contact_main_office_phone_number"
    t.string   "contact_office_location"
    t.integer  "location_id"
    t.string   "implementer_type"
    t.string   "funder_type"
  end

  create_table "organizations_managers", :id => false, :force => true do |t|
    t.integer "organization_id"
    t.integer "user_id"
  end

  create_table "outputs", :force => true do |t|
    t.integer  "activity_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "currency"
    t.integer  "data_response_id"
  end

  add_index "projects", ["data_response_id"], :name => "index_projects_on_data_response_id"

  create_table "reports", :force => true do |t|
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "csv_file_name"
    t.string   "csv_content_type"
    t.integer  "csv_file_size"
    t.datetime "csv_updated_at"
    t.string   "formatted_csv_file_name"
    t.string   "formatted_csv_content_type"
    t.integer  "formatted_csv_file_size"
    t.datetime "formatted_csv_updated_at"
    t.integer  "data_request_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "targets", :force => true do |t|
    t.integer  "activity_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "roles_mask"
    t.integer  "organization_id"
    t.integer  "data_response_id_current"
    t.text     "text_for_organization"
    t.string   "full_name"
    t.string   "perishable_token",         :default => "",    :null => false
    t.boolean  "tips_shown",               :default => true
    t.string   "invite_token"
    t.boolean  "active",                   :default => false
    t.integer  "location_id"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

end
