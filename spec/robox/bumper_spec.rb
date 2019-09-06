# encoding: UTF-8
# frozen_string_literal: true

require 'robox/bumper'
require 'ostruct'

describe Bumper do
  let!(:params) {
    {
      branch:     'master',
      repository: 'rubykube/robox',
      password:   'fake_github_api_key',
      name:       'Test',
      email:      'test@example.com',
      username:   'kite-bot'
    }
  }

  before(:each) do
    expect_any_instance_of(Git::Base).to receive(:config).with('user.name', 'Test')
    expect_any_instance_of(Git::Base).to receive(:config).with('user.email', 'test@example.com')
  end

  context 'new' do
    it 'should configure git user' do
      Bumper.new(params)
    end
  end

  context 'bump' do
    let(:bumper) { Bumper.new(params) }

    it 'should bump patch by default' do
      expect(Bump::Bump).to receive(:run).with('patch', bundle: false, commit: false, tag: false)
      bumper.bump
    end

    it 'should call bump with specified level' do
      expect(Bump::Bump).to receive(:run).with('major', bundle: false, commit: false, tag: false)
      bumper.bump(level: 'major')
    end

    it 'should call bump with specified level' do
      expect(Bump::Bump).to receive(:run).with('major', bundle: false, commit: false, tag: false)
      bumper.bump(level: 'major')
    end

    it 'should respect named params' do
      expect(Bump::Bump).to receive(:run).with('major', bundle: true, commit: true, tag: true)
      bumper.bump(level: 'major', bundle: true, commit: true, tag: true)
    end
  end

  context 'tag_n_commit' do
    let(:bumper) { Bumper.new(params) }

    before(:each) do
      expect(Bump::Bump).to receive(:run).with('patch', bundle: false, commit: false, tag: false)
    end

    it 'should raise an exception in case of unexpected branch name' do
      bumper.bump
      bumper.branch = 'invalid_branch'
      expect { bumper.tag_n_commit }.to raise_error(RuntimeError, "Unexprected branch #{bumper.branch}")
    end

    it 'should use v prefix on master branch' do
      expect(Bump::Bump).to receive(:current).and_return('2.9.1').exactly(4).times
      expect(bumper.git).to receive(:add_tag).with('v2.9.1', message: 'Release new version 2.9.1')
      expect(bumper.git).to receive(:commit_all).with('[ci skip] Release new version 2.9.1')
      bumper.bump
      bumper.tag_n_commit
    end

    it 'should use customer name as prefix on customer branch' do
      expect(Bump::Bump).to receive(:current).and_return('2.9.1').exactly(4).times
      expect(bumper.git).to receive(:add_tag).with('test-v2.9.1', message: 'Release new version 2.9.1')
      expect(bumper.git).to receive(:commit_all).with('[ci skip] Release new version 2.9.1')
      bumper.branch = 'customer/test'
      bumper.bump
      bumper.tag_n_commit
    end

    it 'should respect custom commit messages' do
      expect(Bump::Bump).to receive(:current).and_return('1.3.99').exactly(4).times
      expect(bumper.git).to receive(:add_tag).with('v1.3.99', message: 'Test me, baby 1.3.99')
      expect(bumper.git).to receive(:commit_all).with('[ci skip] Test me, baby 1.3.99')
      bumper.bump
      bumper.tag_n_commit(text: 'Test me, baby')
    end
  end

  context 'push' do
    let(:bumper) { Bumper.new(params) }
    let(:origin) { OpenStruct.new(name: 'origin') }
    let(:authenticated_origin) { OpenStruct.new(name: 'authenticated-origin') }

    it 'should create remote if not exist' do
      expect(bumper.git).to receive(:remotes).and_return([origin])
      expect(bumper.git).to receive(:add_remote)
      expect(bumper.git).to receive(:remote).and_return(origin)
      expect(bumper.git).to receive(:push).with(origin, 'master', true)
      bumper.push
    end

    it 'should not create remote if exist' do
      expect(bumper.git).to receive(:remotes).and_return([authenticated_origin])
      expect(bumper.git).to receive(:remote).and_return(authenticated_origin)
      expect(bumper.git).to receive(:push).with(authenticated_origin, 'master', true)
      bumper.push
    end
  end

  context 'save' do
    let(:bumper) { Bumper.new(params) }

    it 'should save version into .tags file' do
      buffer = StringIO.new()
      expect(bumper).to receive(:version).and_return('1.2.3')
      allow(File).to receive(:open).and_yield(buffer)
      bumper.save
      expect(buffer.string).to eq('1.2.3')
    end
  end
end
