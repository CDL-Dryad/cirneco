require 'spec_helper'

describe Cirneco::Work, vcr: true, :order => :defined do
  let(:doi) { "10.23725/0000-03VC" }
  let(:creators) { [{ given_name: "Elizabeth", family_name: "Miller", orcid: "0000-0001-5000-0007", affiliation: "DataCite" }] }
  let(:title) { "Full DataCite XML Example" }
  let(:publisher) { "DataCite" }
  let(:publication_year) { 2014 }
  let(:resource_type) { { value: "XML", resource_type_general: "Software" } }
  let(:url) { "http://www.datacite.org" }
  let(:media) { [{ mime_type: "application/pdf", url:"http://www.datacite.org/cirneco-test.pdf" }]}
  let(:username) { ENV['MDS_USERNAME'] }
  let(:password) { ENV['MDS_PASSWORD'] }
  let(:options) { { username: username, password: password, sandbox: true } }
  let(:fixture_path) { "spec/fixtures/" }
  let(:samples_path) { "resources/kernel-4.0/samples/" }

  subject { Cirneco::Work.new(doi: doi,
                                    creators: creators,
                                    title: title,
                                    publisher: publisher,
                                    publication_year: publication_year,
                                    resource_type: resource_type,
                                    url: url,
                                    media: media,
                                    username: username,
                                    password: password) }

  describe "Metadata API" do
    describe "get" do
      it 'should get metadata' do
        response = subject.get_metadata(doi, options)
        expect(response.body["data"]).to eq(subject.data)
      end
    end

    describe "delete" do
      it 'should delete metadata' do
        response = subject.delete_metadata(doi, options)
        expect(response.body["data"]).to eq("OK")
        expect(response.status).to eq(200)
      end
    end

    describe "post" do
      it 'should post metadata' do
        response = subject.post_metadata(subject.data, options)
        expect(response.body["data"]).to eq("OK (10.23725/0000-03VC)")
        expect(response.status).to eq(201)
        expect(response.headers["Location"]).to eq("https://mds.test.datacite.org/metadata/10.23725/0000-03VC")
      end
    end
  end

  describe "DOI API" do
    describe "put" do
      it 'should put doi' do
        response = subject.put_doi(doi, url, options)
        expect(response.body["data"]).to eq("OK")
        expect(response.status).to eq(201)
      end
    end

    describe "get" do
      it 'should get all dois' do
        response = subject.get_dois(options)
        dois = response.body["data"]
        expect(dois.length).to eq(12)
        expect(dois.first).to eq("10.23725/0000-03VC")
      end

      it 'should get doi' do
        response = subject.get_doi(doi, options)
        expect(response.body["data"]).to eq("http://www.datacite.org")
      end

      it 'username missing' do
        options = { username: username, sandbox: true }
        response = subject.get_doi(doi, options)
        expect(response.body).to eq("errors"=>[{"title"=>"Username or password missing"}])
      end
    end
  end

  describe "Media API" do
    describe "post" do
      it 'should post media' do
        response = subject.post_media(doi, media, options)
        expect(response.body["data"]).to eq("OK")
        expect(response.status).to eq(200)
      end
    end

    describe "get" do
      it 'should get media' do
        response = subject.get_media(doi, options)
        media = response.body["data"]
        expect(media.length).to eq(1)
        expect(media.first).to eq(:mime_type=>"application/pdf", :url=>"http://www.datacite.org/cirneco-test.pdf")
      end
    end
  end
end
