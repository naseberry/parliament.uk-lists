require 'rails_helper'

RSpec.describe People::ContactPointsController, vcr: true do
  describe "GET index" do
    before(:each) do
      get :index, params: { person_id: '7KNGxTli' }
    end

    it 'should have a response with http status ok (200)' do
      expect(response).to have_http_status(:ok)
    end

    it 'assigns @person and @contact_points' do
      expect(assigns(:person)).to be_a(Grom::Node)
      expect(assigns(:person).type).to eq('https://id.parliament.uk/schema/Person')
      assigns(:contact_points).each do |contact_point|
        expect(contact_point).to be_a(Grom::Node)
        expect(contact_point.type).to eq('https://id.parliament.uk/schema/ContactPoint')
      end
    end

    it 'renders the contact_points template' do
      expect(response).to render_template('index')
    end
  end

  describe '#data_check' do
    context 'an available data format is requested' do
      before(:each) do
        headers = { 'Accept' => 'application/rdf+xml' }
        request.headers.merge(headers)
        get :index, params: { person_id: '7KNGxTli' }
      end

      it 'should have a response with http status redirect (302)' do
        expect(response).to have_http_status(302)
      end

      it 'redirects to the data service' do
        expect(response).to redirect_to("#{ENV['PARLIAMENT_BASE_URL']}/person_contact_points?person_id=7KNGxTli")
      end
    end
  end
end
