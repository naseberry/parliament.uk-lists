require 'rails_helper'

RSpec.describe Constituencies::MembersController, vcr: true do

  describe 'GET index' do
    before(:each) do
      get :index, params: { constituency_id: 'MiTIE0wv' }
    end

    it 'should have a response with a http status ok (200)' do
      expect(response).to have_http_status(:ok)
    end

    it 'assigns @constituency, @seat_incumbencies and @current_incumbency' do
      expect(assigns(:constituency)).to be_a(Grom::Node)
      expect(assigns(:constituency).type).to eq('https://id.parliament.uk/schema/ConstituencyGroup')

      assigns(:seat_incumbencies).each do |seat_incumbency|
        expect(seat_incumbency).to be_a(Grom::Node)
        expect(seat_incumbency.type).to eq('https://id.parliament.uk/schema/SeatIncumbency')
      end

      expect(assigns(:current_incumbency)).to be_a(Grom::Node)
      expect(assigns(:current_incumbency).type).to eq('https://id.parliament.uk/schema/SeatIncumbency')
      expect(assigns(:current_incumbency).current?).to be(true)
    end

    it 'assigns @seat_incumbencies in reverse chronological order' do
      expect(assigns(:seat_incumbencies)[0].start_date).to eq(DateTime.new(2015, 5, 7))
    end

    it 'assigns @current_incumbency to be the current incumbency' do
      expect(assigns(:current_incumbency).start_date).to eq(DateTime.new(2017, 6, 8))
    end

    it 'renders the members template' do
      expect(response).to render_template('index')
    end
  end

  describe 'GET current' do
    before(:each) do
      get :current, params: { constituency_id: 'MiTIE0wv' }
    end

    it 'should have a response with a http status ok (200)' do
      expect(response).to have_http_status(:ok)
    end

    it 'assigns @constituency and @seat_incumbency' do
      expect(assigns(:constituency)).to be_a(Grom::Node)
      expect(assigns(:constituency).type).to eq('https://id.parliament.uk/schema/ConstituencyGroup')

      expect(assigns(:seat_incumbency)).to be_a(Grom::Node)
      expect(assigns(:seat_incumbency).type).to eq('https://id.parliament.uk/schema/SeatIncumbency')
    end

    it 'renders the current_member template' do
      expect(response).to render_template('current')
    end
  end

  describe '#data_check' do
    context 'an available data format is requested' do
      methods = [
        {
          route: 'index',
          parameters: { constituency_id: 'vUPobpVT' },
          data_url: "#{ENV['PARLIAMENT_BASE_URL']}/constituency_members?constituency_id=vUPobpVT"
        },
        {
          route: 'current',
          parameters: { constituency_id: 'vUPobpVT' },
          data_url: "#{ENV['PARLIAMENT_BASE_URL']}/constituency_current_member?constituency_id=vUPobpVT"
        }
        ]

      before(:each) do
        headers = { 'Accept' => 'application/rdf+xml' }
        request.headers.merge(headers)
      end

      it 'should have a response with http status redirect (302)' do
        methods.each do |method|
          if method.include?(:parameters)
            get method[:route].to_sym, params: method[:parameters]
          else
            get method[:route].to_sym
          end
          expect(response).to have_http_status(302)
        end
      end

      it 'redirects to the data service' do
        methods.each do |method|
          if method.include?(:parameters)
            get method[:route].to_sym, params: method[:parameters]
          else
            get method[:route].to_sym
          end
          expect(response).to redirect_to(method[:data_url])
        end
      end
    end

  end
end
