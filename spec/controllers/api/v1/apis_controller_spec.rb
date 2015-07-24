require 'spec_helper'

describe Api::V1::ApisController do
  before(:all) do
    @admin = FactoryGirl.create(:admin)
    @google_admin = FactoryGirl.create(:limited_admin, :groups => [FactoryGirl.create(:google_admin_group, :backend_manage_permission)])
    @unauthorized_google_admin = FactoryGirl.create(:limited_admin, :groups => [FactoryGirl.create(:google_admin_group, :backend_publish_permission)])
    @bing_single_all_scope_admin = FactoryGirl.create(:limited_admin, :groups => [FactoryGirl.create(:bing_admin_group_single_all_scope, :backend_manage_permission)])
    @bing_single_restricted_scope_admin = FactoryGirl.create(:limited_admin, :groups => [FactoryGirl.create(:bing_admin_group_single_restricted_scope, :backend_manage_permission)])
    @bing_multi_scope_admin = FactoryGirl.create(:limited_admin, :groups => [FactoryGirl.create(:bing_admin_group_multi_scope, :backend_manage_permission)])
  end

  before(:each) do
    Api.delete_all

    @api = FactoryGirl.create(:api, {
      :settings => FactoryGirl.attributes_for(:api_setting, {
        :required_roles => [
          "test-write",
        ],
        :headers => [
          {
            :key => "X-Add1",
            :value => "test1",
          },
          {
            :key => "X-Add2",
            :value => "test2",
          },
        ],
        :default_response_headers => [
          {
            :key => "X-Default-Add1",
            :value => "test1",
          },
          {
            :key => "X-Default-Add2",
            :value => "test2",
          },
        ],
        :override_response_headers => [
          {
            :key => "X-Override-Add1",
            :value => "test1",
          },
        ],
      }),
    })
    @google_api = FactoryGirl.create(:google_api)
    @google2_api = FactoryGirl.create(:google_api, {
      :settings => FactoryGirl.attributes_for(:api_setting, {
        :required_roles => [
          "google2-write",
        ],
      }),
    })
    @google_extra_url_match_api = FactoryGirl.create(:google_extra_url_match_api)
    @yahoo_api = FactoryGirl.create(:yahoo_api)
    @bing_api = FactoryGirl.create(:bing_api)
    @bing_search_api = FactoryGirl.create(:bing_search_api)
    @empty_url_prefixes_api = FactoryGirl.build(:google_api, {
      :url_matches => [],
    })
    @empty_url_prefixes_api.save!(:validate => false)
  end

  shared_examples "validates nested attributes presence - create" do |field|
    it "returns a validation error if #{field} is set to nil" do
      admin_token_auth(@admin)
      attributes = FactoryGirl.attributes_for(:api, {
        field => nil,
      })

      expect do
        post :create, :format => "json", :api => attributes
        response.status.should eql(422)
        data = MultiJson.load(response.body)
        data.keys.should eql(["errors"])
        data["errors"].should eql({
          "base" => ["must have at least one #{field}"],
        })
      end.to_not change { Api.count }
    end

    it "returns a validation error if #{field} is set to an empty array" do
      admin_token_auth(@admin)
      attributes = FactoryGirl.attributes_for(:api, {
        field => [],
      })

      expect do
        post :create, :format => "json", :api => attributes
        response.status.should eql(422)
        data = MultiJson.load(response.body)
        data.keys.should eql(["errors"])
        data["errors"].should eql({
          "base" => ["must have at least one #{field}"],
        })
      end.to_not change { Api.count }
    end

    it "accepts the input if at least one url prefix exists" do
      admin_token_auth(@admin)
      attributes = FactoryGirl.attributes_for(:api, {
        field => [FactoryGirl.attributes_for(:"api_#{field.to_s.singularize}")],
      })

      expect do
        post :create, :format => "json", :api => attributes
        response.status.should eql(201)
        data = MultiJson.load(response.body)
        data["api"]["name"].should eql(attributes[:name])
      end.to change { Api.count }.by(1)
    end
  end

  shared_examples "validates nested attributes presence - update" do |field|
    it "returns a validation error if #{field} is set to nil" do
      admin_token_auth(@admin)
      attributes = @api.serializable_hash
      attributes[field.to_s] = nil

      put :update, :format => "json", :id => @api.id, :api => attributes
      response.status.should eql(422)
      data = MultiJson.load(response.body)
      data.keys.should eql(["errors"])
      data["errors"].should eql({
        "base" => ["must have at least one #{field}"],
      })
    end

    it "returns a validation error if #{field} is set to an empty array" do
      admin_token_auth(@admin)
      attributes = @api.serializable_hash
      attributes[field.to_s] = []

      put :update, :format => "json", :id => @api.id, :api => attributes
      response.status.should eql(422)
      data = MultiJson.load(response.body)
      data.keys.should eql(["errors"])
      data["errors"].should eql({
        "base" => ["must have at least one #{field}"],
      })
    end

    it "accepts the input if at least one #{field} exists" do
      admin_token_auth(@admin)
      attributes = @api.serializable_hash
      attributes[field.to_s] = [FactoryGirl.attributes_for(:"api_#{field.to_s.singularize}")]

      put :update, :format => "json", :id => @api.id, :api => attributes
      response.status.should eql(204)
      @api = Api.find(@api.id)
      @api[field].length.should eql(1)
    end
  end

  shared_examples "api settings header fields - show" do |field|
    it "returns no headers as an empty string" do
      api = FactoryGirl.create(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
        }),
      })

      admin_token_auth(@admin)
      get :show, :format => "json", :id => api.id

      response.status.should eql(200)
      data = MultiJson.load(response.body)
      data["api"]["settings"]["#{field}_string"].should eql("")
    end

    it "returns a single header as a string" do
      api = FactoryGirl.create(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
          :"#{field}" => [
            FactoryGirl.attributes_for(:api_header, { :key => "X-Add1", :value => "test1" }),
          ],
        }),
      })

      admin_token_auth(@admin)
      get :show, :format => "json", :id => api.id

      response.status.should eql(200)
      data = MultiJson.load(response.body)
      data["api"]["settings"]["#{field}_string"].should eql("X-Add1: test1")
    end

    it "returns multiple headers as a new-line separated string" do
      api = FactoryGirl.create(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
          :"#{field}" => [
            FactoryGirl.attributes_for(:api_header, { :key => "X-Add1", :value => "test1" }),
            FactoryGirl.attributes_for(:api_header, { :key => "X-Add2", :value => "test2" }),
          ],
        }),
      })

      admin_token_auth(@admin)
      get :show, :format => "json", :id => api.id

      response.status.should eql(200)
      data = MultiJson.load(response.body)
      data["api"]["settings"]["#{field}_string"].should eql("X-Add1: test1\nX-Add2: test2")
    end
  end

  shared_examples "api settings header fields - create" do |field|
    it "accepts a nil value" do
      admin_token_auth(@admin)
      attributes = FactoryGirl.attributes_for(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
          :"#{field}_string" => nil,
        }),
      })

      expect do
        post :create, :format => "json", :api => attributes
        response.status.should eql(201)
        data = MultiJson.load(response.body)
        data["api"]["settings"]["#{field}_string"].should eql("")

        api = Api.find(data["api"]["id"])
        api.settings.send(field).length.should eql(0)
      end.to change { Api.count }.by(1)
    end

    it "accepts an empty string" do
      admin_token_auth(@admin)
      attributes = FactoryGirl.attributes_for(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
          :"#{field}_string" => "",
        }),
      })

      expect do
        post :create, :format => "json", :api => attributes
        response.status.should eql(201)
        data = MultiJson.load(response.body)
        data["api"]["settings"]["#{field}_string"].should eql("")

        api = Api.find(data["api"]["id"])
        api.settings.send(field).length.should eql(0)
      end.to change { Api.count }.by(1)
    end

    it "parses a single header from a string" do
      admin_token_auth(@admin)
      attributes = FactoryGirl.attributes_for(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
          :"#{field}_string" => "X-Add1: test1",
        }),
      })

      expect do
        post :create, :format => "json", :api => attributes
        response.status.should eql(201)
        data = MultiJson.load(response.body)
        data["api"]["settings"]["#{field}_string"].should eql("X-Add1: test1")

        api = Api.find(data["api"]["id"])
        api.settings.send(field).length.should eql(1)
      end.to change { Api.count }.by(1)
    end

    it "parses a multiple headers from a string" do
      admin_token_auth(@admin)
      attributes = FactoryGirl.attributes_for(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
          :"#{field}_string" => "X-Add1: test1\nX-Add2: test2",
        }),
      })

      expect do
        post :create, :format => "json", :api => attributes
        response.status.should eql(201)
        data = MultiJson.load(response.body)
        data["api"]["settings"]["#{field}_string"].should eql("X-Add1: test1\nX-Add2: test2")

        api = Api.find(data["api"]["id"])
        api.settings.send(field).length.should eql(2)
      end.to change { Api.count }.by(1)
    end

    it "strips extra whitespace from the string" do
      admin_token_auth(@admin)
      attributes = FactoryGirl.attributes_for(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
          :"#{field}_string" => "\n\n  X-Add1:test1\n\n\nX-Add2:     test2   \n\n",
        }),
      })

      expect do
        post :create, :format => "json", :api => attributes
        response.status.should eql(201)
        data = MultiJson.load(response.body)
        data["api"]["settings"]["#{field}_string"].should eql("X-Add1: test1\nX-Add2: test2")

        api = Api.find(data["api"]["id"])
        api.settings.send(field).length.should eql(2)
      end.to change { Api.count }.by(1)
    end

    it "only parses to the first colon for the header name" do
      admin_token_auth(@admin)
      attributes = FactoryGirl.attributes_for(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
          :"#{field}_string" => "X-Add1: test1:test2",
        }),
      })

      expect do
        post :create, :format => "json", :api => attributes
        response.status.should eql(201)
        data = MultiJson.load(response.body)
        data["api"]["settings"]["#{field}_string"].should eql("X-Add1: test1:test2")

        api = Api.find(data["api"]["id"])
        api.settings.send(field).length.should eql(1)
      end.to change { Api.count }.by(1)
    end
  end

  shared_examples "api settings header fields - update" do |field|
    it "clears existing headers when passed nil" do
      admin_token_auth(@admin)

      api = FactoryGirl.create(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
          :"#{field}" => [
            FactoryGirl.attributes_for(:api_header, { :key => "X-Add1", :value => "test1" }),
          ],
        }),
      })

      api.settings.send(field).length.should eql(1)

      attributes = api.serializable_hash
      attributes["settings"].delete(field.to_s)
      attributes["settings"]["#{field}_string"] = nil
      put :update, :format => "json", :id => api.id, :api => attributes

      response.status.should eql(204)
      api = Api.find(api.id)
      api.settings.send(field).length.should eql(0)
    end

    it "clears existing headers when passed an empty string" do
      admin_token_auth(@admin)

      api = FactoryGirl.create(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
          :"#{field}" => [
            FactoryGirl.attributes_for(:api_header, { :key => "X-Add1", :value => "test1" }),
          ],
        }),
      })

      api.settings.send(field).length.should eql(1)

      attributes = api.serializable_hash
      attributes["settings"].delete(field.to_s)
      attributes["settings"]["#{field}_string"] = ""
      put :update, :format => "json", :id => api.id, :api => attributes

      response.status.should eql(204)
      api = Api.find(api.id)
      api.settings.send(field).length.should eql(0)
    end

    it "replaces existing headers when passed the headers string" do
      admin_token_auth(@admin)

      api = FactoryGirl.create(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
          :"#{field}" => [
            FactoryGirl.attributes_for(:api_header, { :key => "X-Add1", :value => "test1" }),
          ],
        }),
      })

      api.settings.send(field).length.should eql(1)
      api.settings.send(field).map { |h| h.key }.should eql(["X-Add1"])

      attributes = api.serializable_hash
      attributes["settings"].delete(field.to_s)
      attributes["settings"]["#{field}_string"] = "X-New1: test1\nX-New2: test2"
      put :update, :format => "json", :id => api.id, :api => attributes

      response.status.should eql(204)
      api = Api.find(api.id)
      api.settings.send(field).length.should eql(2)
      api.settings.send(field).map { |h| h.key }.should eql(["X-New1", "X-New2"])
    end
  end

  shared_examples "api settings error data yaml strings" do |method, action|
    it "returns validation error for invalid yaml" do
      attributes = FactoryGirl.attributes_for(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
          :error_data_yaml_strings => {
            :api_key_invalid => "foo: &",
            :api_key_missing => "foo: bar\nhello: `world",
          },
        }),
      })

      admin_token_auth(@admin)
      send(method, action, params.merge(:api => attributes))
      response.status.should eql(422)
      data = MultiJson.load(response.body)
      data.keys.should eql(["errors"])
      data["errors"].should eql({
        "settings.error_data_yaml_strings.api_key_invalid" => ["YAML parsing error: (<unknown>): did not find expected alphabetic or numeric character while scanning an anchor at line 1 column 6"],
        "settings.error_data_yaml_strings.api_key_missing" => ["YAML parsing error: (<unknown>): found character that cannot start any token while scanning for the next token at line 2 column 8"],
      })
    end

    it "returns validation error for yaml that isn't a hash" do
      attributes = FactoryGirl.attributes_for(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
          :error_data_yaml_strings => {
            :api_key_invalid => "foo",
          },
        }),
      })

      admin_token_auth(@admin)
      send(method, action, params.merge(:api => attributes))
      response.status.should eql(422)
      data = MultiJson.load(response.body)
      data.keys.should eql(["errors"])
      data["errors"].should eql({
        "settings.error_data.api_key_invalid" => ["unexpected type (must be a hash)"],
      })
    end

    it "accepts a yaml of hash data" do
      attributes = FactoryGirl.attributes_for(:api, {
        :settings => FactoryGirl.attributes_for(:api_setting, {
          :error_data_yaml_strings => {
            :api_key_invalid => "status_code: 422\nfoo: bar",
          },
        }),
      })

      admin_token_auth(@admin)
      send(method, action, params.merge(:api => attributes))
      response.status.should eql(if(action == :create) then 201 else 204 end)

      api = Api.desc(:updated_at).first
      api.settings.error_data.should eql({
        "api_key_invalid" => {
          "status_code" => 422,
          "foo" => "bar",
        },
      })
    end
  end

  describe "GET index" do
    it "returns datatables output fields" do
      admin_token_auth(@admin)
      get :index, :format => "json"

      data = MultiJson.load(response.body)
      data.keys.sort.should eql([
        "data",
        "draw",
        "recordsFiltered",
        "recordsTotal",
      ])
    end

    it "paginates results" do
      admin_token_auth(@admin)
      get :index, :format => "json", :length => "2"

      api_count = Api.count
      api_count.should be > 2

      data = MultiJson.load(response.body)
      data["recordsTotal"].should eql(api_count)
      data["recordsFiltered"].should eql(api_count)
      data["data"].length.should eql(2)
    end

    describe "admin permissions" do
      it "includes all apis for superuser admins" do
        admin_token_auth(@admin)
        get :index, :format => "json"

        data = MultiJson.load(response.body)
        api_ids = data["data"].map { |api| api["id"] }
        api_ids.length.should eql(8)
        api_ids.should include(@api.id)
        api_ids.should include(@google_api.id)
        api_ids.should include(@google2_api.id)
        api_ids.should include(@google_extra_url_match_api.id)
        api_ids.should include(@yahoo_api.id)
        api_ids.should include(@bing_api.id)
        api_ids.should include(@bing_search_api.id)
        api_ids.should include(@empty_url_prefixes_api.id)
      end

      it "includes apis the admin has access to" do
        admin_token_auth(@google_admin)
        get :index, :format => "json"

        data = MultiJson.load(response.body)
        api_ids = data["data"].map { |api| api["id"] }
        api_ids.should include(@google_api.id)
      end

      it "excludes apis the admin does not have access to" do
        admin_token_auth(@google_admin)
        get :index, :format => "json"

        data = MultiJson.load(response.body)
        api_ids = data["data"].map { |api| api["id"] }
        api_ids.should_not include(@yahoo_api.id)
      end

      it "excludes apis the admin only has partial access to" do
        admin_token_auth(@google_admin)
        get :index, :format => "json"

        data = MultiJson.load(response.body)
        api_ids = data["data"].map { |api| api["id"] }
        api_ids.should_not include(@google_extra_url_match_api.id)
      end

      it "excludes all apis for admins without proper access" do
        admin_token_auth(@unauthorized_google_admin)
        get :index, :format => "json"

        data = MultiJson.load(response.body)
        data["data"].length.should eql(0)
      end

      it "grants access to apis for any apis falling under the prefix of the scope" do
        admin_token_auth(@bing_single_all_scope_admin)
        get :index, :format => "json"

        data = MultiJson.load(response.body)
        api_ids = data["data"].map { |api| api["id"] }
        api_ids.length.should eql(2)
        api_ids.should include(@bing_api.id)
        api_ids.should include(@bing_search_api.id)
      end

      it "grants access to apis with multiple prefixes when the admin has permissions to each prefix via separate scopes and groups" do
        admin_token_auth(@bing_multi_scope_admin)
        get :index, :format => "json"

        data = MultiJson.load(response.body)
        api_ids = data["data"].map { |api| api["id"] }
        api_ids.length.should eql(2)
        api_ids.should include(@bing_api.id)
        api_ids.should include(@bing_search_api.id)
      end

      it "only grants access to apis when the admin has permission to all of the url prefixes" do
        admin_token_auth(@bing_single_restricted_scope_admin)
        get :index, :format => "json"

        data = MultiJson.load(response.body)
        api_ids = data["data"].map { |api| api["id"] }
        api_ids.should_not include(@bing_api.id)
        api_ids.length.should eql(1)
        api_ids.should include(@bing_search_api.id)
      end
    end
  end

  describe "GET show" do
    describe "admin permissions" do
      it "allows superuser admins to view any api" do
        admin_token_auth(@admin)
        get :show, :format => "json", :id => @api.id

        response.status.should eql(200)
        data = MultiJson.load(response.body)
        data["api"]["id"].should eql(@api.id)
      end

      it "allows admins to view apis within the scope it has access to" do
        admin_token_auth(@google_admin)
        get :show, :format => "json", :id => @google_api.id

        response.status.should eql(200)
        data = MultiJson.load(response.body)
        data["api"]["id"].should eql(@google_api.id)
      end

      it "prevents admins from viewing apis outside the scope it has access to" do
        admin_token_auth(@google_admin)
        get :show, :format => "json", :id => @google_extra_url_match_api.id

        response.status.should eql(403)
        data = MultiJson.load(response.body)
        data.keys.should eql(["errors"])
      end

      it "forbids admins without proper access" do
        admin_token_auth(@unauthorized_google_admin)
        get :show, :format => "json", :id => @google_api.id

        response.status.should eql(403)
        data = MultiJson.load(response.body)
        data.keys.should eql(["errors"])
      end

      it "prevents limited admins from viewing incomplete apis without url prefixes" do
        admin_token_auth(@google_admin)
        get :show, :format => "json", :id => @empty_url_prefixes_api.id

        response.status.should eql(403)
        data = MultiJson.load(response.body)
        data.keys.should eql(["errors"])
      end
    end

    describe "request headers" do
      it_behaves_like "api settings header fields - show", :headers
    end

    describe "response default headers" do
      it_behaves_like "api settings header fields - show", :default_response_headers
    end

    describe "response override headers" do
      it_behaves_like "api settings header fields - show", :override_response_headers
    end
  end

  describe "POST create" do
    let(:params) do
      {
        :format => "json",
      }
    end

    describe "admin permissions" do
      it "allows superuser admins to create any api" do
        admin_token_auth(@admin)
        attributes = FactoryGirl.attributes_for(:api)

        expect do
          post :create, :format => "json", :api => attributes
          response.status.should eql(201)
          data = MultiJson.load(response.body)
          data["api"]["name"].should eql(attributes[:name])
        end.to change { Api.count }.by(1)
      end

      it "allows admins to create apis within the scope it has access to" do
        admin_token_auth(@google_admin)
        attributes = FactoryGirl.attributes_for(:google_api)

        expect do
          post :create, :format => "json", :api => attributes
          response.status.should eql(201)
          data = MultiJson.load(response.body)
          data["api"]["name"].should eql(attributes[:name])
        end.to change { Api.count }.by(1)
      end

      it "prevents admins from creating apis outside the scope it has access to" do
        admin_token_auth(@google_admin)
        attributes = FactoryGirl.attributes_for(:google_extra_url_match_api)

        expect do
          post :create, :format => "json", :api => attributes
          response.status.should eql(403)
          data = MultiJson.load(response.body)
          data.keys.should eql(["errors"])
        end.to_not change { Api.count }
      end

      it "forbids admins without proper access" do
        admin_token_auth(@unauthorized_google_admin)
        attributes = FactoryGirl.attributes_for(:google_api)

        expect do
          post :create, :format => "json", :api => attributes
          response.status.should eql(403)
          data = MultiJson.load(response.body)
          data.keys.should eql(["errors"])
        end.to_not change { Api.count }
      end

      it "returns a list of scopes the admin does have access to in the error response" do
        admin_token_auth(@bing_multi_scope_admin)
        attributes = FactoryGirl.attributes_for(:google_api)

        expect do
          post :create, :format => "json", :api => attributes
          response.status.should eql(403)
          data = MultiJson.load(response.body)
          data["errors"].should eql([
            {
              "code" => "FORBIDDEN",
              "message" => "You are not authorized to perform this action. You are only authorized to perform actions for APIs in the following areas:\n\n- localhost/bing/images\n- localhost/bing/maps\n- localhost/bing/search\n\nContact your API Umbrella administrator if you need access to new APIs.",
            }
          ])
        end.to_not change { Api.count }
      end
    end

    describe "admin role permissions" do
      it "allows superuser admins to assign any roles" do
        existing_roles = ApiUserRole.all
        existing_roles.should include("test-write")
        existing_roles.should include("google-write")
        existing_roles.should include("yahoo-write")
        existing_roles.should_not include("new-write")

        admin_token_auth(@admin)
        attributes = FactoryGirl.attributes_for(:api, {
          :settings => FactoryGirl.attributes_for(:api_setting, {
            :required_roles => [
              "test-write",
              "google-write",
              "yahoo-write",
              "new-write",
              "new-write#{rand(999_999)}",
            ],
          }),
          :sub_settings => [
            FactoryGirl.attributes_for(:api_sub_setting, {
              :settings => FactoryGirl.attributes_for(:api_setting, {
                :required_roles => [
                  "test-write",
                  "google-write",
                  "yahoo-write",
                  "new-write",
                  "new-write#{rand(999_999)}",
                ],
              })
            }),
          ],
        })

        expect do
          post :create, :format => "json", :api => attributes
          response.status.should eql(201)
          data = MultiJson.load(response.body)
          data["api"]["settings"]["required_roles"].should eql(attributes[:settings][:required_roles])
          data["api"]["sub_settings"][0]["settings"]["required_roles"].should eql(attributes[:sub_settings][0][:settings][:required_roles])
        end.to change { Api.count }.by(1)
      end

      it "allows limited admins to assign any unused role" do
        admin_token_auth(@google_admin)
        attributes = FactoryGirl.attributes_for(:google_api, {
          :settings => FactoryGirl.attributes_for(:api_setting, {
            :required_roles => [
              "new-settings-role#{rand(999_999)}",
            ],
          }),
          :sub_settings => [
            FactoryGirl.attributes_for(:api_sub_setting, {
              :settings => FactoryGirl.attributes_for(:api_setting, {
                :required_roles => [
                  "new-sub-settings-role#{rand(999_999)}",
                ],
              }),
            }),
          ],
        })

        expect do
          post :create, :format => "json", :api => attributes
          response.status.should eql(201)
          data = MultiJson.load(response.body)
          data["api"]["settings"]["required_roles"].should eql(attributes[:settings][:required_roles])
          data["api"]["sub_settings"][0]["settings"]["required_roles"].should eql(attributes[:sub_settings][0][:settings][:required_roles])
        end.to change { Api.count }.by(1)
      end

      it "allows limited admins to assign an existing role that exists within its scope" do
        existing_roles = ApiUserRole.all
        existing_roles.should include("google-write")

        admin_token_auth(@google_admin)
        attributes = FactoryGirl.attributes_for(:google_api, {
          :settings => FactoryGirl.attributes_for(:api_setting, {
            :required_roles => [
              "google-write",
            ],
          }),
          :sub_settings => [
            FactoryGirl.attributes_for(:api_sub_setting, {
              :settings => FactoryGirl.attributes_for(:api_setting, {
                :required_roles => [
                  "google-write",
                ],
              }),
            }),
          ],
        })

        expect do
          post :create, :format => "json", :api => attributes
          response.status.should eql(201)
          data = MultiJson.load(response.body)
          data["api"]["name"].should eql(attributes[:name])
        end.to change { Api.count }.by(1)
      end

      it "forbids limited admins from assigning an existing role that exists outside its scope at the settings level" do
        existing_roles = ApiUserRole.all
        existing_roles.should include("yahoo-write")

        admin_token_auth(@google_admin)
        attributes = FactoryGirl.attributes_for(:google_api, {
          :settings => FactoryGirl.attributes_for(:api_setting, {
            :required_roles => [
              "yahoo-write",
            ],
          }),
        })

        expect do
          post :create, :format => "json", :api => attributes
          response.status.should eql(403)
          data = MultiJson.load(response.body)
          data.keys.should eql(["errors"])
        end.to_not change { Api.count }
      end

      it "forbids limited admins from assigning an existing role that exists outside its scope at the sub-settings level" do
        existing_roles = ApiUserRole.all
        existing_roles.should include("yahoo-write")

        admin_token_auth(@google_admin)
        attributes = FactoryGirl.attributes_for(:google_api, {
          :sub_settings => [
            FactoryGirl.attributes_for(:api_sub_setting, {
              :settings => FactoryGirl.attributes_for(:api_setting, {
                :required_roles => [
                  "yahoo-write",
                ],
              }),
            }),
          ],
        })

        expect do
          post :create, :format => "json", :api => attributes
          response.status.should eql(403)
          data = MultiJson.load(response.body)
          data.keys.should eql(["errors"])
        end.to_not change { Api.count }
      end

      it "forbids limited admins from assigning an existing role that exists in an api the admin only has partial access to" do
        existing_roles = ApiUserRole.all
        existing_roles.should include("google-extra-write")

        admin_token_auth(@google_admin)
        attributes = FactoryGirl.attributes_for(:google_api, {
          :sub_settings => [
            FactoryGirl.attributes_for(:api_sub_setting, {
              :settings => FactoryGirl.attributes_for(:api_setting, {
                :required_roles => [
                  "google-extra-write",
                ],
              }),
            }),
          ],
        })

        expect do
          post :create, :format => "json", :api => attributes
          response.status.should eql(403)
          data = MultiJson.load(response.body)
          data.keys.should eql(["errors"])
        end.to_not change { Api.count }
      end

      it "forbids limited admins from assigning a new role beginning with 'api-umbrella'" do
        admin_token_auth(@google_admin)
        attributes = FactoryGirl.attributes_for(:api, {
          :settings => FactoryGirl.attributes_for(:api_setting, {
            :required_roles => [
              "api-umbrella#{rand(999_999)}",
            ],
          }),
        })

        expect do
          post :create, :format => "json", :api => attributes
          response.status.should eql(403)
          data = MultiJson.load(response.body)
          data.keys.should eql(["errors"])
        end.to_not change { Api.count }
      end

      it "allows superuser admins to assign a new role beginning with 'api-umbrella'" do
        admin_token_auth(@admin)
        attributes = FactoryGirl.attributes_for(:api, {
          :settings => FactoryGirl.attributes_for(:api_setting, {
            :required_roles => [
              "api-umbrella#{rand(999_999)}",
            ],
          }),
        })

        expect do
          post :create, :format => "json", :api => attributes
          response.status.should eql(201)
          data = MultiJson.load(response.body)
          data["api"]["name"].should eql(attributes[:name])
        end.to change { Api.count }.by(1)
      end
    end

    describe "servers" do
      it_behaves_like "validates nested attributes presence - create", :servers
    end

    describe "matching url prefixes" do
      it_behaves_like "validates nested attributes presence - create", :url_matches
    end

    describe "request headers" do
      it_behaves_like "api settings header fields - create", :headers
    end

    describe "response default headers" do
      it_behaves_like "api settings header fields - create", :default_response_headers
    end

    describe "response override headers" do
      it_behaves_like "api settings header fields - create", :override_response_headers
    end

    it_behaves_like "api settings error data yaml strings", :post, :create

    describe "sort order" do
      before(:each) do
        Api.delete_all
      end

      it "starts the sort_order at 0 and increments by 10,000" do
        admin_token_auth(@admin)

        attributes = FactoryGirl.attributes_for(:api)
        3.times do |i|
          post :create, :format => "json", :api => attributes
          response.status.should eql(201)
          data = MultiJson.load(response.body)
          data["api"]["sort_order"].should eql(i * 10_000)
        end
      end

      it "allows saving when sort_order is pre-set to nil" do
        admin_token_auth(@admin)

        expect do
          attributes = FactoryGirl.attributes_for(:api, :sort_order => nil)
          post :create, :format => "json", :api => attributes
          response.status.should eql(201)
          data = MultiJson.load(response.body)
          data["api"]["sort_order"].should eql(0)
        end.to change { Api.count }.by(1)
      end

      it "allows saving when sort_order is pre-set to number" do
        admin_token_auth(@admin)

        expect do
          attributes = FactoryGirl.attributes_for(:api, :sort_order => 8)
          post :create, :format => "json", :api => attributes
          response.status.should eql(201)
          data = MultiJson.load(response.body)
          data["api"]["sort_order"].should eql(8)
        end.to change { Api.count }.by(1)
      end

      it "fills in the sort_order when approaching the maximum integer range" do
        FactoryGirl.create(:api, :sort_order => 2_147_483_600)

        admin_token_auth(@admin)
        attributes = FactoryGirl.attributes_for(:api)

        post :create, :format => "json", :api => attributes
        response.status.should eql(201)
        data = MultiJson.load(response.body)
        data["api"]["sort_order"].should eql(2_147_483_624)

        post :create, :format => "json", :api => attributes
        response.status.should eql(201)
        data = MultiJson.load(response.body)
        data["api"]["sort_order"].should eql(2_147_483_636)

        post :create, :format => "json", :api => attributes
        response.status.should eql(201)
        data = MultiJson.load(response.body)
        data["api"]["sort_order"].should eql(2_147_483_642)
      end

      it "re-shuffles the sort_order when the maximum integer range will be exceeded" do
        api1 = FactoryGirl.create(:api, :sort_order => 2_147_483_000)
        api2 = FactoryGirl.create(:api, :sort_order => 2_147_483_645)

        admin_token_auth(@admin)
        attributes = FactoryGirl.attributes_for(:api)

        post :create, :format => "json", :api => attributes
        response.status.should eql(201)
        data = MultiJson.load(response.body)
        api3_id = data["api"]["id"]
        data["api"]["sort_order"].should eql(2_147_483_646)

        post :create, :format => "json", :api => attributes
        response.status.should eql(201)
        data = MultiJson.load(response.body)
        api4_id = data["api"]["id"]
        data["api"]["sort_order"].should eql(2_147_483_647)

        post :create, :format => "json", :api => attributes
        response.status.should eql(201)
        data = MultiJson.load(response.body)
        api5_id = data["api"]["id"]
        data["api"]["sort_order"].should eql(2_147_483_647)

        api1.reload
        api2.reload
        api3 = Api.find(api3_id)
        api4 = Api.find(api4_id)
        api5 = Api.find(api5_id)
        api1.sort_order.should eql(2_147_483_000)
        api2.sort_order.should eql(2_147_483_644)
        api3.sort_order.should eql(2_147_483_645)
        api4.sort_order.should eql(2_147_483_646)
        api5.sort_order.should eql(2_147_483_647)
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @update_api = FactoryGirl.create(:api)
    end

    let(:params) do
      {
        :format => "json",
        :id => @update_api.id,
      }
    end

    describe "admin permissions" do
      it "allows superuser admins to update any api" do
        admin_token_auth(@admin)
        attributes = @api.serializable_hash
        attributes["name"] = "Example Updated #{rand(999_999)}"
        put :update, :format => "json", :id => @api.id, :api => attributes

        response.status.should eql(204)
        @api = Api.find(@api.id)
        @api.name.should eql(attributes["name"])
      end

      it "allows admins to update apis within the scope it has access to" do
        admin_token_auth(@google_admin)
        attributes = @google_api.serializable_hash
        attributes["name"] = "Google Updated #{rand(999_999)}"
        put :update, :format => "json", :id => @google_api.id, :api => attributes

        response.status.should eql(204)
        @google_api = Api.find(@google_api.id)
        @google_api.name.should eql(attributes["name"])
      end

      it "prevents admins from updating apis outside the scope it has access to" do
        admin_token_auth(@google_admin)
        attributes = @google_extra_url_match_api.serializable_hash
        attributes["name"] = "Google Updated #{rand(999_999)}"
        put :update, :format => "json", :id => @google_extra_url_match_api.id, :api => attributes

        response.status.should eql(403)
        data = MultiJson.load(response.body)
        data.keys.should eql(["errors"])
        @google_extra_url_match_api = Api.find(@google_extra_url_match_api.id)
        @google_extra_url_match_api.name.should_not eql(attributes["name"])
      end

      it "prevents admins from updating apis within its scope to contain routing outside its scope" do
        admin_token_auth(@google_admin)
        attributes = @google_api.serializable_hash
        attributes["name"] = "Google Updated #{rand(999_999)}"
        attributes["url_matches"] << FactoryGirl.attributes_for(:api_url_match, :frontend_prefix => "/foo", :backend_prefix => "/")
        put :update, :format => "json", :id => @google_api.id, :api => attributes

        response.status.should eql(403)
        data = MultiJson.load(response.body)
        data.keys.should eql(["errors"])
        @google_api = Api.find(@google_api.id)
        @google_api.name.should_not eql(attributes["name"])
        @google_api.url_matches.length.should eql(1)
      end

      it "forbids admins without proper access" do
        admin_token_auth(@unauthorized_google_admin)
        attributes = @google_api.serializable_hash
        attributes["name"] = "Google Updated #{rand(999_999)}"
        put :update, :format => "json", :id => @google_api.id, :api => attributes

        response.status.should eql(403)
        data = MultiJson.load(response.body)
        data.keys.should eql(["errors"])
        @google_extra_url_match_api = Api.find(@google_extra_url_match_api.id)
        @google_extra_url_match_api.name.should_not eql(attributes["name"])
      end
    end

    describe "admin role permissions" do
      it "allows superuser admins to assign any roles" do
        existing_roles = ApiUserRole.all
        existing_roles.should include("test-write")
        existing_roles.should include("google-write")
        existing_roles.should include("yahoo-write")
        existing_roles.should_not include("new-write")

        admin_token_auth(@admin)
        attributes = FactoryGirl.attributes_for(:api, {
          :settings => FactoryGirl.attributes_for(:api_setting, {
            :required_roles => [
              "test-write",
              "google-write",
              "yahoo-write",
              "new-write",
              "new-write#{rand(999_999)}",
            ],
          }),
          :sub_settings => [
            FactoryGirl.attributes_for(:api_sub_setting, {
              :settings => FactoryGirl.attributes_for(:api_setting, {
                :required_roles => [
                  "test-write",
                  "google-write",
                  "yahoo-write",
                  "new-write",
                  "new-write#{rand(999_999)}",
                ],
              })
            }),
          ],
        })
        put :update, :format => "json", :id => @api.id, :api => attributes

        response.status.should eql(204)
        @api = Api.find(@api.id)
        @api.settings.required_roles.should eql(attributes[:settings][:required_roles])
        @api.sub_settings[0].settings.required_roles.should eql(attributes[:sub_settings][0][:settings][:required_roles])
      end

      it "allows limited admins to assign any unused role" do
        admin_token_auth(@google_admin)
        attributes = FactoryGirl.attributes_for(:google_api, {
          :settings => FactoryGirl.attributes_for(:api_setting, {
            :required_roles => [
              "new-settings-role#{rand(999_999)}",
            ],
          }),
          :sub_settings => [
            FactoryGirl.attributes_for(:api_sub_setting, {
              :settings => FactoryGirl.attributes_for(:api_setting, {
                :required_roles => [
                  "new-sub-settings-role#{rand(999_999)}",
                ],
              }),
            }),
          ],
        })
        put :update, :format => "json", :id => @google_api.id, :api => attributes

        response.status.should eql(204)
        @google_api = Api.find(@google_api.id)
        @google_api.settings.required_roles.should eql(attributes[:settings][:required_roles])
        @google_api.sub_settings[0].settings.required_roles.should eql(attributes[:sub_settings][0][:settings][:required_roles])
      end

      it "allows limited admins to assign an existing role that exists within its scope" do
        existing_roles = ApiUserRole.all
        existing_roles.should include("google2-write")

        admin_token_auth(@google_admin)
        attributes = FactoryGirl.attributes_for(:google_api, {
          :settings => FactoryGirl.attributes_for(:api_setting, {
            :required_roles => [
              "google2-write",
            ],
          }),
          :sub_settings => [
            FactoryGirl.attributes_for(:api_sub_setting, {
              :settings => FactoryGirl.attributes_for(:api_setting, {
                :required_roles => [
                  "google2-write",
                ],
              }),
            }),
          ],
        })
        put :update, :format => "json", :id => @google_api.id, :api => attributes

        response.status.should eql(204)
        @google_api = Api.find(@google_api.id)
        @google_api.settings.required_roles.should eql(attributes[:settings][:required_roles])
        @google_api.sub_settings[0].settings.required_roles.should eql(attributes[:sub_settings][0][:settings][:required_roles])
      end

      it "forbids limited admins from assigning an existing role that exists outside its scope at the settings level" do
        existing_roles = ApiUserRole.all
        existing_roles.should include("yahoo-write")

        admin_token_auth(@google_admin)
        attributes = FactoryGirl.attributes_for(:google_api, {
          :settings => FactoryGirl.attributes_for(:api_setting, {
            :required_roles => [
              "yahoo-write",
            ],
          }),
        })
        put :update, :format => "json", :id => @google_api.id, :api => attributes

        response.status.should eql(403)
        data = MultiJson.load(response.body)
        data.keys.should eql(["errors"])
        @google_api = Api.find(@google_api.id)
        @google_api.roles.should_not include("yahoo-write")
      end

      it "forbids limited admins from assigning an existing role that exists outside its scope at the sub-settings level" do
        existing_roles = ApiUserRole.all
        existing_roles.should include("yahoo-write")

        admin_token_auth(@google_admin)
        attributes = FactoryGirl.attributes_for(:google_api, {
          :sub_settings => [
            FactoryGirl.attributes_for(:api_sub_setting, {
              :settings => FactoryGirl.attributes_for(:api_setting, {
                :required_roles => [
                  "yahoo-write",
                ],
              }),
            }),
          ],
        })
        put :update, :format => "json", :id => @google_api.id, :api => attributes

        response.status.should eql(403)
        data = MultiJson.load(response.body)
        data.keys.should eql(["errors"])
        @google_api = Api.find(@google_api.id)
        @google_api.roles.should_not include("yahoo-write")
      end

      it "forbids limited admins from assigning an existing role that exists in an api the admin only has partial access to" do
        existing_roles = ApiUserRole.all
        existing_roles.should include("google-extra-write")

        admin_token_auth(@google_admin)
        attributes = FactoryGirl.attributes_for(:google_api, {
          :settings => FactoryGirl.attributes_for(:api_setting, {
            :required_roles => [
              "google-extra-write",
            ],
          }),
        })
        put :update, :format => "json", :id => @google_api.id, :api => attributes

        response.status.should eql(403)
        data = MultiJson.load(response.body)
        data.keys.should eql(["errors"])
        @google_api = Api.find(@google_api.id)
        @google_api.roles.should_not include("google-extra-write")
      end

      it "forbids limited admins from assigning a new role beginning with 'api-umbrella'" do
        admin_token_auth(@google_admin)
        attributes = FactoryGirl.attributes_for(:google_api, {
          :settings => FactoryGirl.attributes_for(:api_setting, {
            :required_roles => [
              "api-umbrella#{rand(999_999)}",
            ],
          }),
        })
        put :update, :format => "json", :id => @google_api.id, :api => attributes

        response.status.should eql(403)
        data = MultiJson.load(response.body)
        data.keys.should eql(["errors"])
        @google_api = Api.find(@google_api.id)
        @google_api.roles.should_not include(attributes[:settings][:required_roles][0])
      end

      it "allows superuser admins to assign a new role beginning with 'api-umbrella'" do
        admin_token_auth(@admin)
        attributes = FactoryGirl.attributes_for(:google_api, {
          :settings => FactoryGirl.attributes_for(:api_setting, {
            :required_roles => [
              "api-umbrella#{rand(999_999)}",
            ],
          }),
        })
        put :update, :format => "json", :id => @google_api.id, :api => attributes

        response.status.should eql(204)
        @google_api = Api.find(@google_api.id)
        @google_api.settings.required_roles.should eql(attributes[:settings][:required_roles])
      end
    end

    it "does not update rate limit bucket field when empty" do
      admin_token_auth(@admin)
      attributes = @api.serializable_hash
      attributes["url_matches"][0]["rate_limit_bucket_name"] = ""
      put :update, :format => "json", :id => @api.id, :api => attributes
      @api.reload
      expect(@api.url_matches[0].rate_limit_bucket_name).to be_nil
    end

    it "updates rate limit bucket field when non-empty" do
      admin_token_auth(@admin)
      attributes = @api.serializable_hash
      attributes["url_matches"][0]["rate_limit_bucket_name"] = "bouquet" 
      put :update, :format => "json", :id => @api.id, :api => attributes
      @api.reload
      expect(@api.url_matches[0].rate_limit_bucket_name).to eq "bouquet"
    end

    describe "servers" do
      it_behaves_like "validates nested attributes presence - update", :servers
    end

    describe "matching url prefixes" do
      it_behaves_like "validates nested attributes presence - update", :url_matches
    end

    describe "request headers" do
      it_behaves_like "api settings header fields - update", :headers
    end

    describe "response default headers" do
      it_behaves_like "api settings header fields - update", :default_response_headers
    end

    describe "response override headers" do
      it_behaves_like "api settings header fields - update", :override_response_headers
    end

    it_behaves_like "api settings error data yaml strings", :put, :update
  end

  describe "DELETE destroy" do
    it "performs soft-deletes" do
      admin_token_auth(@admin)
      api = FactoryGirl.create(:api)

      delete :destroy, :format => "json", :id => api.id

      Api.where(:id => api.id).first.should eql(nil)
      Api.deleted.where(:id => api.id).first.should be_kind_of(Api)
    end

    describe "admin permissions" do
      it "allows superuser admins to delete any api" do
        admin_token_auth(@admin)
        api = FactoryGirl.create(:api)

        expect do
          delete :destroy, :format => "json", :id => api.id
          response.status.should eql(204)
        end.to change { Api.count }.by(-1)
      end

      it "allows admins to delete apis within the scope it has access to" do
        admin_token_auth(@google_admin)
        api = FactoryGirl.create(:google_api)

        expect do
          delete :destroy, :format => "json", :id => api.id
          response.status.should eql(204)
        end.to change { Api.count }.by(-1)
      end

      it "prevents admins from deleting apis outside the scope it has access to" do
        admin_token_auth(@google_admin)
        api = FactoryGirl.create(:google_extra_url_match_api)

        expect do
          delete :destroy, :format => "json", :id => api.id
          response.status.should eql(403)
          data = MultiJson.load(response.body)
          data.keys.should eql(["errors"])
        end.to_not change { Api.count }
      end

      it "forbids admins without proper access" do
        admin_token_auth(@unauthorized_google_admin)
        api = FactoryGirl.create(:google_api)

        expect do
          delete :destroy, :format => "json", :id => api.id
          response.status.should eql(403)
          data = MultiJson.load(response.body)
          data.keys.should eql(["errors"])
        end.to_not change { Api.count }
      end
    end
  end

  describe "PUT move_after" do
    before(:each) do
      Api.delete_all
    end

    it "moves the sort_order to the beginning when move_after_id is null" do
      api1 = FactoryGirl.create(:api)
      api2 = FactoryGirl.create(:api)
      api3 = FactoryGirl.create(:api)
      api4 = FactoryGirl.create(:api)

      api1.sort_order.should eql(0)
      api2.sort_order.should eql(10_000)
      api3.sort_order.should eql(20_000)
      api4.sort_order.should eql(30_000)

      admin_token_auth(@admin)
      put :move_after, :format => "json", :id => api3.id, :move_after_id => nil
      response.status.should eql(204)

      api1.reload
      api2.reload
      api3.reload
      api4.reload
      api1.sort_order.should eql(0)
      api2.sort_order.should eql(10_000)
      api3.sort_order.should eql(-10_000)
      api4.sort_order.should eql(30_000)
    end

    it "creates a gap of 10,000 when shifting a record to the beginning" do
      api1 = FactoryGirl.create(:api, :sort_order => 99)
      api2 = FactoryGirl.create(:api)

      api1.sort_order.should eql(99)
      api2.sort_order.should eql(10_099)

      admin_token_auth(@admin)
      put :move_after, :format => "json", :id => api2.id, :move_after_id => nil
      response.status.should eql(204)

      api1.reload
      api2.reload
      api1.sort_order.should eql(99)
      api2.sort_order.should eql(-9_901)
    end

    it "shifts the record into place without touching the surrounding records" do
      api1 = FactoryGirl.create(:api)
      api2 = FactoryGirl.create(:api)
      api3 = FactoryGirl.create(:api)

      api1.sort_order.should eql(0)
      api2.sort_order.should eql(10_000)
      api3.sort_order.should eql(20_000)

      admin_token_auth(@admin)
      put :move_after, :format => "json", :id => api3.id, :move_after_id => api1.id
      response.status.should eql(204)

      api1.reload
      api2.reload
      api3.reload
      api1.sort_order.should eql(0)
      api2.sort_order.should eql(10_000)
      api3.sort_order.should eql(5_000)
    end

    it "doesn't change the sort_order if moving after the record that already precedes it and records are evenly distributed" do
      api1 = FactoryGirl.create(:api)
      api2 = FactoryGirl.create(:api)
      api3 = FactoryGirl.create(:api)

      api1.sort_order.should eql(0)
      api2.sort_order.should eql(10_000)
      api3.sort_order.should eql(20_000)

      admin_token_auth(@admin)
      put :move_after, :format => "json", :id => api2.id, :move_after_id => api1.id
      response.status.should eql(204)

      api1.reload
      api2.reload
      api3.reload
      api1.sort_order.should eql(0)
      api2.sort_order.should eql(10_000)
      api3.sort_order.should eql(20_000)
    end

    it "may change the sort_order if moving after the record that already precedes it and records are not evenly distributed" do
      api1 = FactoryGirl.create(:api, :sort_order => 0)
      api2 = FactoryGirl.create(:api, :sort_order => 10_000)
      api3 = FactoryGirl.create(:api, :sort_order => 100_000)

      api1.sort_order.should eql(0)
      api2.sort_order.should eql(10_000)
      api3.sort_order.should eql(100_000)

      admin_token_auth(@admin)
      put :move_after, :format => "json", :id => api2.id, :move_after_id => api1.id
      response.status.should eql(204)

      api1.reload
      api2.reload
      api3.reload
      api1.sort_order.should eql(0)
      api2.sort_order.should eql(50_000)
      api3.sort_order.should eql(100_000)
    end

    it "may change the sort_order if moving after the record that already precedes and there is no subsequent record" do
      api1 = FactoryGirl.create(:api, :sort_order => 0)
      api2 = FactoryGirl.create(:api, :sort_order => 3_000)

      api1.sort_order.should eql(0)
      api2.sort_order.should eql(3_000)

      admin_token_auth(@admin)
      put :move_after, :format => "json", :id => api2.id, :move_after_id => api1.id
      response.status.should eql(204)

      api1.reload
      api2.reload
      api1.sort_order.should eql(0)
      api2.sort_order.should eql(10_000)
    end

    it "reshuffles positive sort orders if moving in between two records that have no gap remaining" do
      api1 = FactoryGirl.create(:api, :sort_order => 0)
      api2 = FactoryGirl.create(:api, :sort_order => 1)
      api3 = FactoryGirl.create(:api, :sort_order => 2)
      api4 = FactoryGirl.create(:api, :sort_order => 3)
      api5 = FactoryGirl.create(:api, :sort_order => 10)

      api1.sort_order.should eql(0)
      api2.sort_order.should eql(1)
      api3.sort_order.should eql(2)
      api4.sort_order.should eql(3)
      api5.sort_order.should eql(10)

      admin_token_auth(@admin)
      put :move_after, :format => "json", :id => api3.id, :move_after_id => api1.id
      response.status.should eql(204)

      api1.reload
      api2.reload
      api3.reload
      api4.reload
      api5.reload
      api1.sort_order.should eql(-1)
      api2.sort_order.should eql(1)
      api3.sort_order.should eql(0)
      api4.sort_order.should eql(3)
      api5.sort_order.should eql(10)
    end

    it "reshuffles positive sort orders near integer range if moving in between two records that have no gap remaining" do
      api1 = FactoryGirl.create(:api, :sort_order => 2_147_483_640)
      api2 = FactoryGirl.create(:api, :sort_order => 2_147_483_645)
      api3 = FactoryGirl.create(:api, :sort_order => 2_147_483_646)
      api4 = FactoryGirl.create(:api, :sort_order => 2_147_483_647)

      api1.sort_order.should eql(2_147_483_640)
      api2.sort_order.should eql(2_147_483_645)
      api3.sort_order.should eql(2_147_483_646)
      api4.sort_order.should eql(2_147_483_647)

      admin_token_auth(@admin)
      put :move_after, :format => "json", :id => api2.id, :move_after_id => api4.id
      response.status.should eql(204)

      api1.reload
      api2.reload
      api3.reload
      api4.reload
      api1.sort_order.should eql(2_147_483_640)
      api2.sort_order.should eql(2_147_483_647)
      api3.sort_order.should eql(2_147_483_645)
      api4.sort_order.should eql(2_147_483_646)

      admin_token_auth(@admin)
      put :move_after, :format => "json", :id => api3.id, :move_after_id => nil
      response.status.should eql(204)

      api1.reload
      api2.reload
      api3.reload
      api4.reload
      api1.sort_order.should eql(2_147_483_640)
      api2.sort_order.should eql(2_147_483_647)
      api3.sort_order.should eql(2_147_473_640)
      api4.sort_order.should eql(2_147_483_646)
    end

    it "reshuffles negative sort orders if moving in between two records that have no gap remaining" do
      api1 = FactoryGirl.create(:api, :sort_order => -10)
      api2 = FactoryGirl.create(:api, :sort_order => -9)
      api3 = FactoryGirl.create(:api, :sort_order => -8)
      api4 = FactoryGirl.create(:api, :sort_order => -7)
      api5 = FactoryGirl.create(:api, :sort_order => 0)

      api1.sort_order.should eql(-10)
      api2.sort_order.should eql(-9)
      api3.sort_order.should eql(-8)
      api4.sort_order.should eql(-7)
      api5.sort_order.should eql(0)

      admin_token_auth(@admin)
      put :move_after, :format => "json", :id => api3.id, :move_after_id => api1.id
      response.status.should eql(204)

      api1.reload
      api2.reload
      api3.reload
      api4.reload
      api5.reload
      api1.sort_order.should eql(-10)
      api2.sort_order.should eql(-8)
      api3.sort_order.should eql(-9)
      api4.sort_order.should eql(-7)
      api5.sort_order.should eql(0)
    end

    it "reshuffles negative sort orders near integer range if moving in between two records that have no gap remaining" do
      api1 = FactoryGirl.create(:api, :sort_order => -2_147_483_648)
      api2 = FactoryGirl.create(:api, :sort_order => -2_147_483_647)
      api3 = FactoryGirl.create(:api, :sort_order => -2_147_483_646)
      api4 = FactoryGirl.create(:api, :sort_order => -2_147_483_640)

      api1.sort_order.should eql(-2_147_483_648)
      api2.sort_order.should eql(-2_147_483_647)
      api3.sort_order.should eql(-2_147_483_646)
      api4.sort_order.should eql(-2_147_483_640)

      admin_token_auth(@admin)
      put :move_after, :format => "json", :id => api3.id, :move_after_id => api1.id
      response.status.should eql(204)

      api1.reload
      api2.reload
      api3.reload
      api4.reload
      api1.sort_order.should eql(-2_147_483_648)
      api2.sort_order.should eql(-2_147_483_646)
      api3.sort_order.should eql(-2_147_483_647)
      api4.sort_order.should eql(-2_147_483_640)

      admin_token_auth(@admin)
      put :move_after, :format => "json", :id => api3.id, :move_after_id => nil
      response.status.should eql(204)

      api1.reload
      api2.reload
      api3.reload
      api4.reload
      api1.sort_order.should eql(-2_147_483_647)
      api2.sort_order.should eql(-2_147_483_646)
      api3.sort_order.should eql(-2_147_483_648)
      api4.sort_order.should eql(-2_147_483_640)
    end
  end
end
